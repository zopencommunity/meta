# Package requests server

This service stores package requests, guest or GitHub-authenticated votes, and moderated discussion
contributions for the zopen community website. The VitePress site remains on
GitHub Pages and calls this API from the browser.

Requires Node.js 20.17 or newer.

Requests are categorized by ecosystem, including general/CLI projects,
Python/PyPI, C/C++, Rust/Cargo, Go modules, Java/JVM, JavaScript/npm, and shell
projects.

Published zopen artifacts use the community Pulp service:

- RPM repository: `https://repo.zopen.community/pulp/content/zopen/`
- Production wheels: `https://repo.zopen.community/pulp/content/wheels/`
- Repository root: `https://repo.zopen.community/pulp/content/`

The maintainer console recognizes both Pulp zopen RPMs and Pulp Python packages
as first-class artifact types. Prefer an exact artifact or package URL when one
is available rather than linking only to the repository root.

## Run locally

```bash
npm install
npm start
```

The API listens on `http://localhost:3100` and writes its SQLite database to
`db/package_requests.db` by default. Run the website separately from `docs/`:

```bash
VITE_PACKAGE_REQUESTS_API_URL=http://localhost:3100/api npm run docs:dev
```

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3100` | HTTP port |
| `HOST` | `127.0.0.1` | Listen address; keep loopback-only behind a reverse proxy |
| `DATABASE_PATH` | `db/package_requests.db` | SQLite database path |
| `ALLOWED_ORIGINS` | `localhost` and `127.0.0.1` Vite ports | Comma-separated website origins allowed by CORS |
| `ADMIN_TOKEN` | none | Bearer token required to change request status |
| `TRUST_PROXY` | `false` | Set to `true` behind one trusted reverse proxy so rate limiting sees client IPs |
| `PULP_RPM_BASE_URL` | production zopen RPM repository | Override the RPM repository used by synchronization |
| `PULP_WHEEL_BASE_URL` | production wheels repository | Override the wheel directory used by synchronization |
| `GITHUB_OAUTH_CLIENT_ID` | none | Enables GitHub sign-in when set with the client secret and callback URL |
| `GITHUB_OAUTH_CLIENT_SECRET` | none | Private OAuth App credential; keep outside Git |
| `GITHUB_OAUTH_CALLBACK_URL` | none | Exact public callback registered in the GitHub OAuth App |
| `SITE_URL` | package-request page | Browser destination after GitHub sign-in |
| `PUBLIC_API_PATH` | `/api` | Public URL path used to scope secure session cookies |

For production, use a persistent database path, set `ALLOWED_ORIGINS` to the
exact GitHub Pages/custom-domain origin, provide a long random `ADMIN_TOKEN`, and
place the service behind HTTPS. The process works with systemd, Docker, or a
process manager such as PM2.

Example:

```bash
PORT=3100 \
HOST=127.0.0.1 \
DATABASE_PATH=/var/lib/zopen-package-requests/requests.db \
ALLOWED_ORIGINS=https://zopen.community \
ADMIN_TOKEN=replace-with-a-long-random-value \
TRUST_PROXY=true \
npm start
```

Set the GitHub Actions repository variable `PACKAGE_REQUESTS_API_URL` to the
public API prefix, such as `https://requests-api.zopen.community/api`. The Pages
workflow passes it into the VitePress build.

## Production deployment

Reusable deployment templates live in [`deploy/`](deploy/):

- `zopen-package-requests.env.example` documents the private runtime settings.
  Copy it outside the checkout, set mode `0600`, and never commit the live file.
- `zopen-package-requests.service` runs the API as an unprivileged system user,
  binds it to loopback, and grants write access only to the persistent data path.
- `zopen-package-requests-pulp-sync.service` and `.timer` perform automatic,
  review-first Pulp discovery approximately every six hours.
- `Caddyfile.example` exposes the API over HTTPS while returning `404` for the
  backend's standalone admin page. Admin API calls remain protected by the
  bearer token and an additional per-IP rate limit.

Keep the SQLite database, backups, admin token, TLS keys, and any future email
or Pulp credentials outside Git. The admin HTML and API code can remain public:
authorization comes from the server-side token and private network path, not
from hiding source code.

On older enterprise Linux hosts, the prebuilt `sqlite3` native module may
target a newer glibc. Rebuild it against the host after `npm ci`:

```bash
npm rebuild sqlite3 --build-from-source
```

When dependencies are installed as root with a restrictive umask, restore
group read/traverse permissions for the `zopenreq` service account after the
install. The systemd unit itself uses `UMask=0077` so databases containing
private requester details are created without world or group access.

The integrated maintainer console is available at
`https://zopen.community/PackageRequests/admin`. It stores the token only in
the current tab's session storage. The standalone backend console can still be
used through a private tunnel:

```bash
ssh -N -L 3310:127.0.0.1:3100 \
  -J itodorov@rogi21.fyre.ibm.com root@163.74.88.212
```

Then open `http://127.0.0.1:3310/admin`. A non-root SSH account should replace
the root login once the initial deployment is complete.

## API

- `GET /api/health`
- `GET /api/requests?sort=top|newest&status=proposed`
- `GET /api/requests/:id` with public request details and grouped relationships
- `POST /api/requests`
- `POST /api/requests/bulk` with up to 25 requests and shared requester details
- `PUT /api/requests/:id/vote`
- `DELETE /api/requests/:id/vote`
- `GET /api/requests/:id/activity`
- `POST /api/requests/:id/posts`
- `GET`, `PATCH`, or `DELETE /api/posts/:id` with `X-Edit-Token`
- `GET /api/admin/requests` with `Authorization: Bearer <ADMIN_TOKEN>`
- `GET /api/admin/relationships` with `Authorization: Bearer <ADMIN_TOKEN>`
- `POST /api/admin/requests/:id/relationships` with `Authorization: Bearer <ADMIN_TOKEN>`
- `DELETE /api/admin/relationships/:id` with `Authorization: Bearer <ADMIN_TOKEN>`
- `PATCH /api/requests/:id` with `Authorization: Bearer <ADMIN_TOKEN>`
- `DELETE /api/requests/:id` with `Authorization: Bearer <ADMIN_TOKEN>`
- `GET /api/admin/posts?status=pending|published|hidden|all` with `Authorization: Bearer <ADMIN_TOKEN>`
- `POST /api/admin/requests/:id/posts` with `Authorization: Bearer <ADMIN_TOKEN>`
- `PATCH` or `DELETE /api/admin/posts/:id` with `Authorization: Bearer <ADMIN_TOKEN>`
- `GET /api/auth/config`, `GET /api/auth/me`, and `POST /api/auth/logout`
- `GET /api/auth/github` and `GET /api/auth/github/callback`
- `GET /api/me/submissions` and `PATCH` or `DELETE /api/me/requests/:id` with a GitHub session
- `POST /api/me/votes/claim` with a GitHub session to migrate this browser's guest votes
- `GET /api/admin/pulp` with `Authorization: Bearer <ADMIN_TOKEN>`
- `POST /api/admin/pulp/sync` with `Authorization: Bearer <ADMIN_TOKEN>`
- `POST /api/admin/pulp/matches/:requestId/:source/approve` with `Authorization: Bearer <ADMIN_TOKEN>`
- `POST /api/admin/pulp/matches/:requestId/:source/dismiss` with `Authorization: Bearer <ADMIN_TOKEN>`

## Pulp synchronization

The synchronizer reads the current RPM `repomd.xml` and primary package
metadata plus the production wheel directory. It stores discovered versions,
checksums, architectures, exact artifact URLs, sync history, and one current
suggestion per request and source. Package matching uses normalized exact names
(`-`, `_`, `.`, spaces, and the zopen `port` suffix are normalized); it does not
use fuzzy matching.

Synchronization never changes a public request by itself. A maintainer reviews
each suggestion in `/PackageRequests/admin`, inspects the artifact, and either
dismisses it or applies it. Applying a suggestion records the Pulp URL and type,
changes the request to **Available**, and appends the normal status event.
For Python requests, an exact match from the production wheels repository is
presented as the primary artifact and a zopen RPM match is retained as an
alternative. Other ecosystems prefer the zopen RPM. Applying either reviewed
artifact dismisses the remaining alternatives for that request.

Run it manually with:

```bash
DATABASE_PATH=/var/lib/zopen-package-requests/requests.db npm run sync:pulp
```

The deployment directory includes a systemd oneshot service and timer that run
the same command approximately every six hours. The timer needs no Pulp secret
because both production repositories are publicly readable.

## Maintainer workflow

Open `https://zopen.community/PackageRequests/admin` and enter the configured
`ADMIN_TOKEN`. The token is kept in browser session storage and is not compiled
into the GitHub Pages site.

The console lets maintainers:

1. Correct every user-submitted field, including package name, ecosystem,
   upstream URL, description, use case, tester availability, and requester details.
2. Move a new request from **Proposed** to **Under review** to acknowledge it.
3. Record a public maintainer note and progress through **Accepted** and **In progress**.
4. Add the `zopencommunity/<name>port` repository URL when a port repository exists.
5. Add a published package location, including Pulp-hosted Python wheels or RPMs.
6. Mark the request **Available**. At least one repository or artifact link is
   required before the API accepts this state.
7. Permanently delete an invalid or test request after typing its exact package
   name. Its votes and status history are deleted by the same database action.
8. Link requests as **Depends on**, **Related to**, or **Duplicate of**. Reverse
   **Blocks** relationships are derived automatically, and dependency cycles are rejected.

Requester name and organization are public only when the requester opts in.
Contact email is never included by the public API; it is returned only from the
admin endpoint and shown only in this protected console.

Every request also has a GitHub Pages-compatible detail URL in the form
`/PackageRequest?request=<id>-<readable-name>`. The numeric ID remains authoritative
if a maintainer later corrects the package name. The page combines voting, status
progress, delivery links, relationships, discussion, and activity.

## Discussion and activity

Each package request has a public chronological timeline containing its creation,
status changes, published community contributions, and verified maintainer posts.
Community members can add a use case, offer testing or contribution help, share a
technical note, or ask a question. These contributions enter a moderation queue
and are not public until a maintainer publishes them. Maintainers can edit,
publish, hide, or permanently delete a contribution and can post verified updates
directly to the timeline.

A community contribution may include an optional name, organization, and contact
email. Public attribution is opt-in; contact email is always private to
maintainers. On submission, the API returns a one-time edit token and stores only
its SHA-256 hash. The browser retains that token locally so the author can edit or
delete the contribution without an account. Editing a published contribution
returns it to the moderation queue. Clearing browser storage or moving to another
browser loses this self-service access, but an administrator can still edit or
remove the post.

Post bodies are rendered as plain text with safe HTTP(S) links. The API limits
length and link count, applies per-IP submission throttling without storing IP
addresses, and includes a honeypot field for simple bot filtering. This is a
focused request discussion, not a general-purpose forum; the community Code of
Conduct applies.

## GitHub sign-in and submission ownership

GitHub sign-in is optional. Guest package requests continue to work, and guest
discussion posts retain their browser-held edit token. When GitHub OAuth is
configured, a signed-in user's new package requests and discussion contributions
are linked to GitHub's durable numeric user ID. The user can then view **My
submissions** and edit those items from any browser where they sign in.
Owners may permanently delete their own requests while they remain **Proposed**.
After maintainer review begins, deletion is restricted to administrators so that
community votes, discussion, and project history are not removed unexpectedly.

Signed-in requesters can also opt to show **Submitted by @username** on a request,
linked to their public GitHub profile. This is enabled by default for new signed-in
submissions, but can be turned off before submission or later from **Edit request**.
It is separate from the name-and-organization visibility setting. The durable
numeric GitHub ID and contact email are never included in the public API response.

The same independent control applies to signed-in discussion contributions, which
can show **Posted by @username** linked to the author's public GitHub profile. An
author may hide or restore that attribution without changing the post's moderation
status. Existing contributions remain hidden until their owner opts in.

The OAuth App requests identity only: the authorization request has no repository
or private-email scopes. The server exchanges the short-lived authorization code,
reads the authenticated public GitHub profile, then discards the GitHub access
token. It creates its own random 30-day session token, stores only a SHA-256 hash,
and sends the raw token in a `Secure`, `HttpOnly`, `SameSite=Lax` cookie. OAuth
state is also bound to an `HttpOnly` cookie. Never place the OAuth client secret or
session token in the GitHub Pages build.

Create an organization-owned GitHub OAuth App with these production values:

- Homepage URL: `https://zopen.community/PackageRequests`
- Authorization callback URL: `https://usage.zopen.community/package-requests/api/auth/github/callback`
- Device flow: disabled

Then add the following only to `/etc/zopen-package-requests.env` on the API host:

```bash
GITHUB_OAUTH_CLIENT_ID=the-client-id
GITHUB_OAUTH_CLIENT_SECRET=the-client-secret
GITHUB_OAUTH_CALLBACK_URL=https://usage.zopen.community/package-requests/api/auth/github/callback
SITE_URL=https://zopen.community/PackageRequests
PUBLIC_API_PATH=/package-requests/api
```

Restart `zopen-package-requests` after changing the environment. GitHub sign-in
remains hidden when any of the three OAuth variables is absent. Existing requests
are not claimed automatically. After a user signs in once, an administrator can
enter that user's GitHub login in the request editor to assign ownership.

Status changes are appended to the `request_events` audit table. A request also
records its first acknowledgement and availability timestamps.

For guests, the public interface creates an opaque voter ID in browser storage.
For signed-in users, votes are keyed by the durable GitHub user ID, enforcing one
vote per request across signed-in devices. On sign-in, the browser asks the API to
move its existing guest votes to the GitHub identity and removes the corresponding
guest rows so they are not counted twice. The API never exposes voter identities
publicly and adds per-IP request throttling without storing IP addresses. Guest
voting remains a low-friction interest signal and cannot prevent a determined
person from using multiple anonymous browsers, so all votes remain advisory.

The bulk-request interface accepts a pasted list or CSV, validates every row,
and checks the public catalog before submission. The bulk API independently
validates all fields and returns created, duplicate, and rejected rows. Public
submissions are limited to 25 packages per batch and two batches per IP per
hour. Each accepted row is stored as a normal independent request; a batch does
not imply acceptance, priority, or a combined maintenance commitment.
