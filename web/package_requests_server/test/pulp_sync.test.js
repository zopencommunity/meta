const assert = require("node:assert/strict");
const { after, before, test } = require("node:test");
const { createApp, openDatabase } = require("../server");

const repomdXml = `<?xml version="1.0"?>
<repomd><data type="primary"><location href="repodata/primary.xml" /></data></repomd>`;
const primaryXml = `<?xml version="1.0"?>
<metadata packages="2">
  <package type="rpm">
    <name>confluent-kafka</name><arch>s390x</arch>
    <version epoch="0" ver="2.13.0" rel="20260701" />
    <checksum type="sha256">old-checksum</checksum>
    <time file="1782806400" build="1782806300" />
    <location href="Packages/c/confluent-kafka-2.13.0.rpm" />
  </package>
  <package type="rpm">
    <name>confluent-kafka</name><arch>s390x</arch>
    <version epoch="0" ver="2.14.0" rel="20260730" />
    <checksum type="sha256">new-checksum</checksum>
    <time file="1785428122" build="1785427994" />
    <location href="Packages/c/confluent-kafka-2.14.0.rpm" />
  </package>
</metadata>`;
const wheelHtml = `<html><body><pre>
<a href="confluent_kafka-2.14.0-cp312-none-any.whl">confluent_kafka-2.14.0-cp312-none-any.whl</a> 30-Jul-2026 16:15 9.3 MB
</pre></body></html>`;

function pulpFetch(url) {
  const body = url.endsWith("repomd.xml") ? repomdXml : url.endsWith("primary.xml") ? primaryXml : wheelHtml;
  return Promise.resolve({ ok: true, status: 200, text: async () => body });
}

let database;
let server;
let baseUrl;
let requestId;

before(async () => {
  database = openDatabase(":memory:");
  const app = createApp({
    database,
    adminToken: "test-admin-token",
    allowedOrigins: "http://localhost:5173",
    pulpFetch,
  });
  await app.locals.ready;
  await new Promise((resolve) => { server = app.listen(0, "127.0.0.1", resolve); });
  baseUrl = `http://127.0.0.1:${server.address().port}`;
  const response = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      packageName: "confluent_kafka",
      ecosystem: "python",
      description: "This Python package is needed for Kafka applications on z/OS.",
    }),
  });
  requestId = (await response.json()).request.id;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
  await new Promise((resolve) => database.close(resolve));
});

test("discovers exact RPM and wheel matches and requires admin review", async () => {
  const unauthorized = await fetch(`${baseUrl}/api/admin/pulp/sync`, { method: "POST" });
  assert.equal(unauthorized.status, 401);

  const syncResponse = await fetch(`${baseUrl}/api/admin/pulp/sync`, {
    method: "POST",
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.equal(syncResponse.status, 200);
  const synced = await syncResponse.json();
  assert.equal(synced.run.artifactsSeen, 3);
  assert.equal(synced.run.matchesFound, 2);

  const overviewResponse = await fetch(`${baseUrl}/api/admin/pulp`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  const overview = await overviewResponse.json();
  assert.equal(overview.matches.length, 2);
  assert.equal(overview.artifactCount, 3);
  assert.equal(overview.runs[0].status, "success");
  assert.equal(overview.matches[0].source, "wheel");
  assert.equal(overview.matches[0].isPrimary, true);
  assert.equal(overview.matches[0].requestEcosystem, "python");
  assert.equal(overview.matches.find((match) => match.source === "rpm").isPrimary, false);
  assert.equal(overview.matches.find((match) => match.source === "rpm").version, "2.14.0");

  const approveResponse = await fetch(`${baseUrl}/api/admin/pulp/matches/${requestId}/wheel/approve`, {
    method: "POST",
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.equal(approveResponse.status, 200);

  const adminResponse = await fetch(`${baseUrl}/api/admin/requests`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  const request = (await adminResponse.json()).requests[0];
  assert.equal(request.status, "available");
  assert.equal(request.artifactKind, "pulp_python");
  assert.match(request.artifactUrl, /confluent_kafka-2\.14\.0-cp312-none-any\.whl$/);

  const matchStatuses = await new Promise((resolve, reject) => {
    database.all(
      "SELECT source, status FROM pulp_matches WHERE request_id = ? ORDER BY source",
      [requestId],
      (error, rows) => error ? reject(error) : resolve(rows),
    );
  });
  assert.deepEqual(matchStatuses, [
    { source: "rpm", status: "dismissed" },
    { source: "wheel", status: "approved" },
  ]);

  const reviewedOverview = await fetch(`${baseUrl}/api/admin/pulp`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.deepEqual((await reviewedOverview.json()).matches, []);
});
