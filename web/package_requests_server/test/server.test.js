const assert = require("node:assert/strict");
const { after, before, test } = require("node:test");
const { createApp, openDatabase } = require("../server");

let database;
let server;
let baseUrl;

function insertTestRequest(packageName, ecosystem = "general") {
  const normalizedName = packageName.toLowerCase().replace(/[^a-z0-9]/g, "");
  const now = new Date().toISOString();
  return new Promise((resolve, reject) => {
    database.run(
      `INSERT INTO package_requests
        (package_name, normalized_name, ecosystem, upstream_url, description, created_at, updated_at)
       VALUES (?, ?, ?, '', 'Test relationship request.', ?, ?)`,
      [packageName, normalizedName, ecosystem, now, now],
      function onInsert(error) {
        if (error) reject(error);
        else resolve({ id: this.lastID, packageName });
      },
    );
  });
}

before(async () => {
  database = openDatabase(":memory:");
  const app = createApp({
    database,
    allowedOrigins: "http://localhost:5173",
    adminToken: "test-admin-token",
    catalogEntries: [{ packageName: "catalog-tool", version: "3.2.1", description: "Published test package", url: "https://example.com/catalog-tool" }],
  });
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
      description: "OK",
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

  const emptyResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
  });
  assert.equal(emptyResponse.status, 400);

  const oneCharacterDescriptionResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ packageName: "Too Short", ecosystem: "general", description: "X" }),
  });
  assert.equal(oneCharacterDescriptionResponse.status, 400);
});

test("discovers existing requests, Pulp artifacts, and catalog packages", async () => {
  const now = new Date().toISOString();
  await new Promise((resolve, reject) => database.run(
    `INSERT INTO pulp_artifacts
      (source, package_name, normalized_name, version, release, architecture, artifact_url, checksum, first_seen_at, last_seen_at)
     VALUES ('wheel', 'wheel-tool', 'wheel-tool', '1.4.0', '', 'cp312-none-any', 'https://example.com/wheel-tool.whl', '', ?, ?)`,
    [now, now],
    (error) => error ? reject(error) : resolve(),
  ));
  const response = await fetch(`${baseUrl}/api/discovery?query=wheel_tool&ecosystem=python`);
  assert.equal(response.status, 200);
  const found = await response.json();
  assert.equal(found.artifacts[0].packageName, "wheel-tool");
  assert.equal(found.artifacts[0].match, "exact");

  const bulkResponse = await fetch(`${baseUrl}/api/discovery/bulk`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ queries: [{ query: "Example Tool", ecosystem: "rust" }, { query: "catalog_tool", ecosystem: "general" }] }),
  });
  const bulk = await bulkResponse.json();
  assert.equal(bulk.results[0].requests[0].match, "exact");
  assert.equal(bulk.results[1].catalog[0].packageName, "catalog-tool");
});

test("serves dedicated request details and manages typed relationships", async () => {
  const dependency = await insertTestRequest("Example Dependency", "rust");
  const related = await insertTestRequest("Related Example");

  const unauthorizedResponse = await fetch(`${baseUrl}/api/admin/relationships`);
  assert.equal(unauthorizedResponse.status, 401);

  const dependencyResponse = await fetch(`${baseUrl}/api/admin/requests/1/relationships`, {
    method: "POST",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ type: "depends_on", targetRequestId: dependency.id }),
  });
  assert.equal(dependencyResponse.status, 201);
  const dependencyRelationship = (await dependencyResponse.json()).relationship;
  assert.equal(dependencyRelationship.source.packageName, "Example Tool");
  assert.equal(dependencyRelationship.target.packageName, "Example Dependency");

  const relatedResponse = await fetch(`${baseUrl}/api/admin/requests/1/relationships`, {
    method: "POST",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ type: "related_to", targetRequestId: related.id }),
  });
  assert.equal(relatedResponse.status, 201);
  const relatedRelationship = (await relatedResponse.json()).relationship;

  const detailResponse = await fetch(`${baseUrl}/api/requests/1`);
  assert.equal(detailResponse.status, 200);
  const detail = await detailResponse.json();
  assert.equal(detail.request.packageName, "Example Tool");
  assert.equal(detail.relationships.dependsOn[0].id, dependency.id);
  assert.equal(detail.relationships.related[0].id, related.id);
  assert.deepEqual(detail.relationships.blocks, []);

  const reverseDetail = await fetch(`${baseUrl}/api/requests/${dependency.id}`);
  const reverse = await reverseDetail.json();
  assert.equal(reverse.relationships.blocks[0].id, 1);

  const cycleResponse = await fetch(`${baseUrl}/api/admin/requests/${dependency.id}/relationships`, {
    method: "POST",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ type: "depends_on", targetRequestId: 1 }),
  });
  assert.equal(cycleResponse.status, 409);

  const duplicateResponse = await fetch(`${baseUrl}/api/admin/requests/1/relationships`, {
    method: "POST",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ type: "depends_on", targetRequestId: dependency.id }),
  });
  assert.equal(duplicateResponse.status, 409);

  const adminRelationships = await fetch(`${baseUrl}/api/admin/relationships`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  assert.equal((await adminRelationships.json()).relationships.length, 2);

  for (const relationshipId of [dependencyRelationship.id, relatedRelationship.id]) {
    const deleteRelationshipResponse = await fetch(`${baseUrl}/api/admin/relationships/${relationshipId}`, {
      method: "DELETE",
      headers: { Authorization: "Bearer test-admin-token" },
    });
    assert.equal(deleteRelationshipResponse.status, 200);
  }
  for (const requestId of [dependency.id, related.id]) {
    const deleteRequestResponse = await fetch(`${baseUrl}/api/requests/${requestId}`, {
      method: "DELETE",
      headers: { Authorization: "Bearer test-admin-token" },
    });
    assert.equal(deleteRequestResponse.status, 200);
  }
});

test("moderates community posts and publishes a verified activity timeline", async () => {
  const tooShortPostResponse = await fetch(`${baseUrl}/api/requests/1/posts`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ kind: "technical_note", body: "X" }),
  });
  assert.equal(tooShortPostResponse.status, 400);

  const createPostResponse = await fetch(`${baseUrl}/api/requests/1/posts`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      kind: "testing_offer",
      body: "OK",
      authorName: "Private Tester",
      organization: "Private Company",
      contactEmail: "tester@example.com",
      showAuthorPublicly: false,
      showGithubPublicly: true,
    }),
  });
  assert.equal(createPostResponse.status, 202);
  const created = await createPostResponse.json();
  assert.equal(created.post.moderationStatus, "pending");
  assert.equal(created.post.contactEmail, "tester@example.com");
  assert.equal(created.post.showGithubPublicly, false);
  assert.equal(created.post.githubAuthor, null);
  assert.match(created.editToken, /^[A-Za-z0-9_-]{40,}$/);

  const initialActivity = await fetch(`${baseUrl}/api/requests/1/activity`);
  const initialActivityBody = await initialActivity.json();
  assert.deepEqual(initialActivityBody.activity.map((item) => item.type), ["created"]);

  const unauthorizedOwnPost = await fetch(`${baseUrl}/api/posts/${created.post.id}`, {
    headers: { "X-Edit-Token": "incorrect-token" },
  });
  assert.equal(unauthorizedOwnPost.status, 404);

  const ownPostResponse = await fetch(`${baseUrl}/api/posts/${created.post.id}`, {
    headers: { "X-Edit-Token": created.editToken },
  });
  assert.equal(ownPostResponse.status, 200);
  assert.equal((await ownPostResponse.json()).post.authorName, "Private Tester");

  const unauthorizedModeration = await fetch(`${baseUrl}/api/admin/posts`);
  assert.equal(unauthorizedModeration.status, 401);

  const pendingResponse = await fetch(`${baseUrl}/api/admin/posts`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  const pending = await pendingResponse.json();
  assert.equal(pending.posts.length, 1);
  assert.equal(pending.posts[0].contactEmail, "tester@example.com");

  const publishResponse = await fetch(`${baseUrl}/api/admin/posts/${created.post.id}`, {
    method: "PATCH",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ moderationStatus: "published" }),
  });
  assert.equal(publishResponse.status, 200);

  const maintainerResponse = await fetch(`${baseUrl}/api/admin/requests/1/posts`, {
    method: "POST",
    headers: {
      Authorization: "Bearer test-admin-token",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      kind: "question",
      body: "Which Python and z/OS versions should the initial package target?",
    }),
  });
  assert.equal(maintainerResponse.status, 201);

  const publishedActivity = await fetch(`${baseUrl}/api/requests/1/activity`);
  const published = (await publishedActivity.json()).activity.filter((item) => item.type === "post");
  assert.equal(published.length, 2);
  const communityPost = published.find((post) => post.authorRole === "community");
  assert.equal(communityPost.authorName, "");
  assert.equal(communityPost.organization, "");
  assert.equal(Object.hasOwn(communityPost, "contactEmail"), false);
  const maintainerPost = published.find((post) => post.authorRole === "maintainer");
  assert.equal(maintainerPost.authorName, "zopen maintainer");

  const editResponse = await fetch(`${baseUrl}/api/posts/${created.post.id}`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "X-Edit-Token": created.editToken,
    },
    body: JSON.stringify({ body: "I can test the revised package on z/OS 3.1 in our automated workload." }),
  });
  assert.equal(editResponse.status, 200);
  assert.equal((await editResponse.json()).post.moderationStatus, "pending");

  const afterEditActivity = await fetch(`${baseUrl}/api/requests/1/activity`);
  const afterEditPosts = (await afterEditActivity.json()).activity.filter((item) => item.type === "post");
  assert.deepEqual(afterEditPosts.map((post) => post.authorRole), ["maintainer"]);

  const deleteResponse = await fetch(`${baseUrl}/api/posts/${created.post.id}`, {
    method: "DELETE",
    headers: { "X-Edit-Token": created.editToken },
  });
  assert.equal(deleteResponse.status, 200);
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
      resolutionKind: "upstream_compatible",
      maintainerNote: "The port and Python wheel are now available.",
    }),
  });
  assert.equal(available.status, 200);
  const published = await available.json();
  assert.equal(published.request.artifactKind, "pulp_python");
  assert.equal(published.request.resolutionKind, "upstream_compatible");
  assert.match(published.request.installCommand, /PIP_EXTRA_INDEX_URL/);
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
      description: "OK",
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
      `SELECT (SELECT COUNT(*) FROM votes) AS votes,
        (SELECT COUNT(*) FROM github_votes) AS githubVotes,
        (SELECT COUNT(*) FROM request_events) AS events,
        (SELECT COUNT(*) FROM request_posts) AS posts`,
      (error, row) => error ? reject(error) : resolve(row),
    );
  });
  assert.deepEqual(cascadeCounts, { votes: 0, githubVotes: 0, events: 0, posts: 0 });
});

test("bulk creates valid requests and reports row-level duplicates and errors", async () => {
  const tooManyResponse = await fetch(`${baseUrl}/api/requests/bulk`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ requests: Array.from({ length: 26 }, (_, index) => ({
      packageName: `Package ${index}`,
      ecosystem: "general",
      description: "This is a sufficiently detailed reason for requesting the package.",
    })) }),
  });
  assert.equal(tooManyResponse.status, 400);
  assert.match((await tooManyResponse.json()).error, /limited to 25/);

  const seedResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      packageName: "Bulk Seed",
      ecosystem: "general",
      description: "This package exists before the bulk request is submitted.",
    }),
  });
  assert.equal(seedResponse.status, 201);

  const response = await fetch(`${baseUrl}/api/requests/bulk`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      description: "These packages are needed for a shared application modernization effort.",
      requesterName: "Bulk Requester",
      organization: "Example Organization",
      contactEmail: "bulk@example.com",
      showRequesterPublicly: false,
      canHelpTest: true,
      requests: [
        { packageName: "Bulk Seedport", ecosystem: "general" },
        { packageName: "Bulk Alpha", ecosystem: "rust" },
        { packageName: "bulk-alpha", ecosystem: "rust" },
        { packageName: "Bulk Beta", ecosystem: "python", upstreamUrl: "not-a-url" },
        {
          packageName: "Bulk Gamma",
          ecosystem: "go",
          description: "This package has a more specific reason for being requested on z/OS.",
          canHelpTest: false,
        },
      ],
    }),
  });
  assert.equal(response.status, 201);
  const body = await response.json();
  assert.deepEqual(body.summary, { submitted: 5, created: 2, duplicates: 2, errors: 1 });
  assert.deepEqual(body.created.map((item) => item.packageName), ["Bulk Alpha", "Bulk Gamma"]);
  assert.equal(body.created[0].canHelpTest, true);
  assert.equal(body.created[1].canHelpTest, false);
  assert.equal(body.duplicates[0].reason, "existing");
  assert.equal(typeof body.duplicates[0].existingRequestId, "number");
  assert.equal(body.duplicates[1].reason, "batch");
  assert.equal(body.duplicates[1].duplicateOfIndex, 1);
  assert.match(body.errors[0].error, /valid upstream project URL/);

  const publicList = await fetch(`${baseUrl}/api/requests`);
  const publicBody = await publicList.json();
  assert.equal(publicBody.requests.length, 3);
  assert.equal(publicBody.requests.every((item) => item.requesterName === ""), true);
  assert.equal(publicBody.requests.every((item) => !Object.hasOwn(item, "contactEmail")), true);
});

test("resolves an upstream-compatible Python package without requiring a zopen artifact", async () => {
  const upstreamOnly = await insertTestRequest("jsonschema", "python");
  const response = await fetch(`${baseUrl}/api/requests/${upstreamOnly.id}`, {
    method: "PATCH",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({
      status: "available",
      resolutionKind: "upstream_compatible",
      upstreamUrl: "https://pypi.org/project/jsonschema/",
    }),
  });
  assert.equal(response.status, 200);
  const resolved = (await response.json()).request;
  assert.equal(resolved.resolutionKind, "upstream_compatible");
  assert.equal(resolved.installCommand, "pip install jsonschema");
});
