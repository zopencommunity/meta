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
  const configResponse = await fetch(`${baseUrl}/api/auth/config`);
  assert.deepEqual(await configResponse.json(), { githubEnabled: true });

  const loginResponse = await fetch(`${baseUrl}/api/auth/github`, { redirect: "manual" });
  assert.equal(loginResponse.status, 302);
  const authorizationUrl = new URL(loginResponse.headers.get("location"));
  assert.equal(authorizationUrl.origin, "https://github.com");
  assert.equal(authorizationUrl.searchParams.get("client_id"), "test-client-id");
  assert.equal(authorizationUrl.searchParams.has("scope"), false);
  const state = authorizationUrl.searchParams.get("state");
  const stateCookie = loginResponse.headers.get("set-cookie").match(/zopen_oauth_state=([^;]+)/)[1];

  const callbackResponse = await fetch(
    `${baseUrl}/api/auth/github/callback?code=temporary-code&state=${encodeURIComponent(state)}`,
    { headers: { Cookie: `zopen_oauth_state=${stateCookie}` }, redirect: "manual" },
  );
  assert.equal(callbackResponse.status, 302);
  assert.equal(callbackResponse.headers.get("location"), "http://localhost:5173/PackageRequests?auth=success");
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

  const createResponse = await fetch(`${baseUrl}/api/requests`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Cookie: sessionCookie },
    body: JSON.stringify({ packageName: "GitHub Owned", ecosystem: "go", description: "OK" }),
  });
  assert.equal(createResponse.status, 201);
  const created = (await createResponse.json()).request;
  assert.equal(created.ownedByCurrentUser, true);

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
    body: JSON.stringify({ kind: "technical_note", body: "Owned note" }),
  });
  assert.equal(postResponse.status, 202);
  const post = (await postResponse.json()).post;
  assert.equal(post.ownedByCurrentUser, true);

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
