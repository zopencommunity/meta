const assert = require("node:assert/strict");
const { after, before, test } = require("node:test");
const { createApp, openDatabase } = require("../server");

let database;
let server;
let baseUrl;

before(async () => {
  database = openDatabase(":memory:");
  const githubFetch = async (url) => {
    if (url === "https://github.com/login/oauth/access_token") {
      return new Response(JSON.stringify({ access_token: "temporary-github-token" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }
    if (url === "https://api.github.com/user") {
      return new Response(JSON.stringify({
        id: 4242,
        login: "octo-zopen",
        avatar_url: "https://avatars.example.com/4242",
        html_url: "https://github.com/octo-zopen",
      }), { status: 200, headers: { "Content-Type": "application/json" } });
    }
    throw new Error(`Unexpected GitHub URL: ${url}`);
  };
  const app = createApp({
    database,
    allowedOrigins: "http://localhost:5173",
    adminToken: "test-admin-token",
    githubClientId: "test-client-id",
    githubClientSecret: "test-client-secret",
    githubCallbackUrl: "http://localhost:3100/api/auth/github/callback",
    siteUrl: "http://localhost:5173/PackageRequests",
    publicApiPath: "/api",
    cookieSecure: false,
    githubFetch,
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

test("uses GitHub identity to own and edit package requests and discussion posts", async () => {
  const browserVoterId = "browser-voter-id-1234567890";
  const guestRequestResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      packageName: "Guest Vote Claim",
      ecosystem: "general",
      description: "OK",
      showGithubPublicly: true,
    }),
  });
  assert.equal(guestRequestResponse.status, 401);
  assert.match((await guestRequestResponse.json()).error, /Sign in with GitHub/);
  const guestRequest = await new Promise((resolve, reject) => {
    const now = new Date().toISOString();
    database.run(
      `INSERT INTO package_requests
       (package_name, normalized_name, ecosystem, upstream_url, description, status, created_at, updated_at)
       VALUES ('Guest Vote Claim', 'guest-vote-claim', 'general', '', 'Existing request for vote claiming.', 'proposed', ?, ?)`,
      [now, now],
      function inserted(error) { if (error) reject(error); else resolve({ id: this.lastID }); },
    );
  });
  const guestVoteResponse = await fetch(`${baseUrl}/api/requests/${guestRequest.id}/vote`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ voterId: browserVoterId }),
  });
  assert.equal((await guestVoteResponse.json()).voteCount, 1);

  const configResponse = await fetch(`${baseUrl}/api/auth/config`);
  assert.deepEqual(await configResponse.json(), { githubEnabled: true });

  const returnTo = "http://localhost:5173/PackageRequest?request=1-example";
  const loginResponse = await fetch(`${baseUrl}/api/auth/github?returnTo=${encodeURIComponent(returnTo)}`, { redirect: "manual" });
  assert.equal(loginResponse.status, 302);
  const authorizationUrl = new URL(loginResponse.headers.get("location"));
  assert.equal(authorizationUrl.origin, "https://github.com");
  assert.equal(authorizationUrl.searchParams.get("client_id"), "test-client-id");
  assert.equal(authorizationUrl.searchParams.has("scope"), false);
  const state = authorizationUrl.searchParams.get("state");
  const loginCookies = loginResponse.headers.get("set-cookie");
  const stateCookie = loginCookies.match(/zopen_oauth_state=([^;]+)/)[1];
  const returnCookie = loginCookies.match(/zopen_oauth_return=([^;]+)/)[1];

  const callbackResponse = await fetch(
    `${baseUrl}/api/auth/github/callback?code=temporary-code&state=${encodeURIComponent(state)}`,
    { headers: { Cookie: `zopen_oauth_state=${stateCookie}; zopen_oauth_return=${returnCookie}` }, redirect: "manual" },
  );
  assert.equal(callbackResponse.status, 302);
  assert.equal(callbackResponse.headers.get("location"), `${returnTo}&auth=success`);
  const setCookie = callbackResponse.headers.get("set-cookie");
  assert.match(setCookie, /HttpOnly/);
  assert.match(setCookie, /SameSite=Lax/);
  const sessionToken = setCookie.match(/zopen_request_session=([^;]+)/)[1];
  const sessionCookie = `zopen_request_session=${sessionToken}`;

  const meResponse = await fetch(`${baseUrl}/api/auth/me`, { headers: { Cookie: sessionCookie } });
  const me = await meResponse.json();
  assert.deepEqual(me.user, {
    id: 4242,
    login: "octo-zopen",
    avatarUrl: "https://avatars.example.com/4242",
    profileUrl: "https://github.com/octo-zopen",
  });

  const claimResponse = await fetch(`${baseUrl}/api/me/votes/claim`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ voterId: browserVoterId }),
  });
  assert.deepEqual(await claimResponse.json(), { success: true, claimed: 1 });
  const duplicateClaimResponse = await fetch(`${baseUrl}/api/me/votes/claim`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ voterId: browserVoterId }),
  });
  assert.deepEqual(await duplicateClaimResponse.json(), { success: true, claimed: 0 });
  const signedVoteResponse = await fetch(`${baseUrl}/api/requests/${guestRequest.id}/vote`, {
    method: "PUT",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ voterId: "different-browser-voter-12345" }),
  });
  assert.deepEqual(await signedVoteResponse.json(), { voted: true, voteCount: 1 });
  const signedListResponse = await fetch(`${baseUrl}/api/requests`, {
    headers: { Cookie: sessionCookie, "X-Voter-ID": "different-browser-voter-12345" },
  });
  const signedList = await signedListResponse.json();
  assert.equal(signedList.requests.find((item) => item.id === guestRequest.id).voted, true);

  const createResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({
      packageName: "GitHub Owned",
      ecosystem: "go",
      description: "OK",
      showGithubPublicly: true,
    }),
  });
  assert.equal(createResponse.status, 201);
  const created = (await createResponse.json()).request;
  assert.equal(created.ownedByCurrentUser, true);
  assert.deepEqual(created.githubRequester, {
    login: "octo-zopen",
    profileUrl: "https://github.com/octo-zopen",
  });
  const publicOwnedResponse = await fetch(`${baseUrl}/api/requests`);
  const publicOwned = (await publicOwnedResponse.json()).requests.find((item) => item.id === created.id);
  assert.deepEqual(publicOwned.githubRequester, {
    login: "octo-zopen",
    profileUrl: "https://github.com/octo-zopen",
  });

  const anonymousPostResponse = await fetch(`${baseUrl}/api/requests/${created.id}/posts`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ kind: "question", body: "Anonymous comment" }),
  });
  assert.equal(anonymousPostResponse.status, 401);

  const anonymousEdit = await fetch(`${baseUrl}/api/me/requests/${created.id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ description: "No" }),
  });
  assert.equal(anonymousEdit.status, 401);

  const editResponse = await fetch(`${baseUrl}/api/me/requests/${created.id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ description: "Updated through GitHub ownership", canHelpTest: true }),
  });
  assert.equal(editResponse.status, 200);
  assert.equal((await editResponse.json()).request.description, "Updated through GitHub ownership");

  const postResponse = await fetch(`${baseUrl}/api/requests/${created.id}/posts`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ kind: "technical_note", body: "Owned note", showGithubPublicly: true }),
  });
  assert.equal(postResponse.status, 201);
  const post = (await postResponse.json()).post;
  assert.equal(post.ownedByCurrentUser, true);
  assert.equal(post.moderationStatus, "published");
  assert.deepEqual(post.githubAuthor, {
    login: "octo-zopen",
    profileUrl: "https://github.com/octo-zopen",
  });

  const adminPostsResponse = await fetch(`${baseUrl}/api/admin/posts?status=published`, {
    headers: { Authorization: "Bearer test-admin-token" },
  });
  const adminPublishedPost = (await adminPostsResponse.json()).posts.find((item) => item.id === post.id);
  assert.equal(adminPublishedPost.ownerGithubId, 4242);
  assert.equal(adminPublishedPost.ownerGithubLogin, "octo-zopen");
  const publishedActivityResponse = await fetch(`${baseUrl}/api/requests/${created.id}/activity`);
  const publishedPost = (await publishedActivityResponse.json()).activity.find((item) => item.id === post.id);
  assert.deepEqual(publishedPost.githubAuthor, {
    login: "octo-zopen",
    profileUrl: "https://github.com/octo-zopen",
  });

  const hideAttributionResponse = await fetch(`${baseUrl}/api/posts/${post.id}/attribution`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ showGithubPublicly: false }),
  });
  const hiddenPost = (await hideAttributionResponse.json()).post;
  assert.equal(hiddenPost.moderationStatus, "published");
  assert.equal(hiddenPost.githubAuthor, null);
  const hiddenActivityResponse = await fetch(`${baseUrl}/api/requests/${created.id}/activity`);
  const publiclyHiddenPost = (await hiddenActivityResponse.json()).activity.find((item) => item.id === post.id);
  assert.equal(publiclyHiddenPost.githubAuthor, null);
  assert.equal(Object.hasOwn(publiclyHiddenPost, "ownerGithubId"), false);
  const anonymousAttributionResponse = await fetch(`${baseUrl}/api/posts/${post.id}/attribution`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ showGithubPublicly: true }),
  });
  assert.equal(anonymousAttributionResponse.status, 401);
  const showAttributionResponse = await fetch(`${baseUrl}/api/posts/${post.id}/attribution`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ showGithubPublicly: true }),
  });
  assert.equal((await showAttributionResponse.json()).post.moderationStatus, "published");

  const editPostResponse = await fetch(`${baseUrl}/api/posts/${post.id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ body: "Edited without a browser edit token" }),
  });
  assert.equal(editPostResponse.status, 200);

  const submissionsResponse = await fetch(`${baseUrl}/api/me/submissions`, { headers: { Cookie: sessionCookie } });
  const submissions = await submissionsResponse.json();
  assert.equal(submissions.requests.length, 1);
  assert.equal(submissions.requests[0].contactEmail, "");
  assert.equal(submissions.posts.length, 1);

  const activityResponse = await fetch(`${baseUrl}/api/requests/${created.id}/activity`, {
    headers: { Cookie: sessionCookie },
  });
  const activity = (await activityResponse.json()).activity;
  assert.equal(activity.some((item) => item.type === "edit"), true);

  const clearOwnerResponse = await fetch(`${baseUrl}/api/requests/${created.id}`, {
    method: "PATCH",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ status: "proposed", ownerGithubLogin: "" }),
  });
  assert.equal(clearOwnerResponse.status, 200);
  assert.equal((await clearOwnerResponse.json()).request.ownerGithubLogin, "");
  const requestsAfterClear = await fetch(`${baseUrl}/api/me/submissions`, { headers: { Cookie: sessionCookie } });
  assert.equal((await requestsAfterClear.json()).requests.length, 0);

  const assignOwnerResponse = await fetch(`${baseUrl}/api/requests/${created.id}`, {
    method: "PATCH",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ status: "proposed", ownerGithubLogin: "octo-zopen" }),
  });
  assert.equal(assignOwnerResponse.status, 200);
  assert.equal((await assignOwnerResponse.json()).request.ownerGithubLogin, "octo-zopen");

  const acceptResponse = await fetch(`${baseUrl}/api/requests/${created.id}`, {
    method: "PATCH",
    headers: { Authorization: "Bearer test-admin-token", "Content-Type": "application/json" },
    body: JSON.stringify({ status: "accepted" }),
  });
  assert.equal(acceptResponse.status, 200);
  const protectedDeleteResponse = await fetch(`${baseUrl}/api/me/requests/${created.id}`, {
    method: "DELETE",
    headers: { Cookie: sessionCookie },
  });
  assert.equal(protectedDeleteResponse.status, 409);

  const deleteTargetResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ packageName: "Owner Delete Target", ecosystem: "general", description: "OK" }),
  });
  const deleteTarget = (await deleteTargetResponse.json()).request;
  const anonymousDeleteResponse = await fetch(`${baseUrl}/api/me/requests/${deleteTarget.id}`, { method: "DELETE" });
  assert.equal(anonymousDeleteResponse.status, 401);
  const ownerDeleteResponse = await fetch(`${baseUrl}/api/me/requests/${deleteTarget.id}`, {
    method: "DELETE",
    headers: { Cookie: sessionCookie },
  });
  assert.deepEqual(await ownerDeleteResponse.json(), {
    success: true,
    id: deleteTarget.id,
    packageName: "Owner Delete Target",
  });

  const logoutResponse = await fetch(`${baseUrl}/api/auth/logout`, {
    method: "POST",
    headers: { Cookie: sessionCookie },
  });
  assert.equal(logoutResponse.status, 200);
  const afterLogout = await fetch(`${baseUrl}/api/auth/me`, { headers: { Cookie: sessionCookie } });
  assert.equal((await afterLogout.json()).user, null);
});

test("rejects an OAuth callback whose state is not bound to the browser", async () => {
  const response = await fetch(`${baseUrl}/api/auth/github/callback?code=code&state=wrong`, { redirect: "manual" });
  assert.equal(response.status, 302);
  assert.equal(response.headers.get("location"), "http://localhost:5173/PackageRequests?auth=error");
});
