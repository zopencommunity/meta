const assert = require("node:assert/strict");
const { after, before, test } = require("node:test");
const { createApp, openDatabase } = require("../server");

let database;
let server;
let baseUrl;

before(async () => {
  database = openDatabase(":memory:");
  const app = createApp({ database, allowedOrigins: "http://localhost:5173", adminToken: "test-admin-token" });
  await app.locals.ready;
  await new Promise((resolve) => {
    server = app.listen(0, "127.0.0.1", resolve);
  });
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
  await new Promise((resolve) => database.close(resolve));
});

test("creates, lists, votes, and unvotes a package request", async () => {
  const createResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      packageName: "Example Tool",
      ecosystem: "rust",
      description: "This tool would make an important z/OS workflow easier.",
      useCase: "Used in automated builds.",
      canHelpTest: true,
      requesterName: "Example Requester",
      organization: "Example Company",
      contactEmail: "requester@example.com",
      showRequesterPublicly: false,
    }),
  });
  assert.equal(createResponse.status, 201);
  const created = await createResponse.json();
  assert.equal(created.request.packageName, "Example Tool");
  assert.equal(created.request.ecosystem, "rust");
  assert.equal(created.request.upstreamUrl, "");
  assert.equal(created.request.requesterName, "");
  assert.equal(Object.hasOwn(created.request, "contactEmail"), false);

  const voterId = "12345678-1234-4123-8123-123456789abc";
  const voteResponse = await fetch(`${baseUrl}/api/requests/${created.request.id}/vote`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ voterId }),
  });
  assert.deepEqual(await voteResponse.json(), { voted: true, voteCount: 1 });

  const listResponse = await fetch(`${baseUrl}/api/requests`, {
    headers: { "X-Voter-ID": voterId },
  });
  const listed = await listResponse.json();
  assert.equal(listed.requests[0].voteCount, 1);
  assert.equal(listed.requests[0].voted, true);
  assert.equal(listed.requests[0].organization, "");

  const unvoteResponse = await fetch(`${baseUrl}/api/requests/${created.request.id}/vote`, {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ voterId }),
  });
  assert.deepEqual(await unvoteResponse.json(), { voted: false, voteCount: 0 });
});

test("rejects duplicate package names including the port suffix", async () => {
  const response = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      packageName: "example-toolport",
      ecosystem: "rust",
      upstreamUrl: "https://example.com/tool",
      description: "A duplicate request that should not create another record.",
    }),
  });
  assert.equal(response.status, 409);
  const body = await response.json();
  assert.equal(typeof body.existingRequestId, "number");
});

test("changes status only with the admin token", async () => {
  const unauthorized = await fetch(`${baseUrl}/api/requests/1`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "accepted" }),
  });
  assert.equal(unauthorized.status, 401);

  const authorized = await fetch(`${baseUrl}/api/requests/1`, {
    method: "PATCH",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ status: "accepted" }),
  });
  assert.equal(authorized.status, 200);
  const acknowledged = await authorized.json();
  assert.equal(acknowledged.request.status, "accepted");
  assert.equal(typeof acknowledged.request.acknowledgedAt, "string");

  const availableWithoutLocation = await fetch(`${baseUrl}/api/requests/1`, {
    method: "PATCH",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ status: "available" }),
  });
  assert.equal(availableWithoutLocation.status, 400);

  const available = await fetch(`${baseUrl}/api/requests/1`, {
    method: "PATCH",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      status: "available",
      portRepositoryUrl: "https://github.com/zopencommunity/example-toolport",
      artifactKind: "pulp_python",
      artifactUrl: "https://packages.example.com/pypi/example-tool/",
      maintainerNote: "The port and Python wheel are now available.",
    }),
  });
  assert.equal(available.status, 200);
  const published = await available.json();
  assert.equal(published.request.artifactKind, "pulp_python");
  assert.equal(typeof published.request.availableAt, "string");

  const statusOnlyUpdate = await fetch(`${baseUrl}/api/requests/1`, {
    method: "PATCH",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ status: "under_review" }),
  });
  const statusOnlyBody = await statusOnlyUpdate.json();
  assert.equal(statusOnlyBody.request.artifactUrl, "https://packages.example.com/pypi/example-tool/");

  const editUserFields = await fetch(`${baseUrl}/api/requests/1`, {
    method: "PATCH",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      status: "under_review",
      packageName: "Example Tool Corrected",
      ecosystem: "python",
      upstreamUrl: "https://example.com/corrected-tool",
      description: "This corrected description explains the package request clearly.",
      useCase: "A corrected automation use case.",
      canHelpTest: false,
      requesterName: "Corrected Requester",
      organization: "Corrected Company",
      contactEmail: "corrected@example.com",
      showRequesterPublicly: true,
    }),
  });
  assert.equal(editUserFields.status, 200);
  const edited = await editUserFields.json();
  assert.equal(edited.request.packageName, "Example Tool Corrected");
  assert.equal(edited.request.contactEmail, "corrected@example.com");

  const adminList = await fetch(`${baseUrl}/api/admin/requests`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.equal(adminList.status, 200);
  const adminBody = await adminList.json();
  assert.equal(adminBody.requests[0].portRepositoryUrl, "https://github.com/zopencommunity/example-toolport");
  assert.equal(adminBody.requests[0].contactEmail, "corrected@example.com");

  const publicList = await fetch(`${baseUrl}/api/requests`);
  const publicBody = await publicList.json();
  assert.equal(publicBody.requests[0].requesterName, "Corrected Requester");
  assert.equal(publicBody.requests[0].organization, "Corrected Company");
  assert.equal(Object.hasOwn(publicBody.requests[0], "contactEmail"), false);

  const voteBeforeDelete = await fetch(`${baseUrl}/api/requests/1/vote`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ voterId: "delete-cascade-test-voter" }),
  });
  assert.equal(voteBeforeDelete.status, 200);

  const unauthorizedDelete = await fetch(`${baseUrl}/api/requests/1`, { method: "DELETE" });
  assert.equal(unauthorizedDelete.status, 401);

  const deleteResponse = await fetch(`${baseUrl}/api/requests/1`, {
    method: "DELETE",
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.equal(deleteResponse.status, 200);
  assert.deepEqual(await deleteResponse.json(), { success: true, id: 1 });

  const deletedAdminList = await fetch(`${baseUrl}/api/admin/requests`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.deepEqual((await deletedAdminList.json()).requests, []);

  const cascadeCounts = await new Promise((resolve, reject) => {
    database.get(
      "SELECT (SELECT COUNT(*) FROM votes) AS votes, (SELECT COUNT(*) FROM request_events) AS events",
      (error, row) => error ? reject(error) : resolve(row),
    );
  });
  assert.deepEqual(cascadeCounts, { votes: 0, events: 0 });
});
