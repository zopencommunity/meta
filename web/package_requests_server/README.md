# Package requests server

This service stores package requests and anonymous votes for the zopen community
website. The VitePress site remains on GitHub Pages and calls this API from the
browser.

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
- `Caddyfile.example` exposes the public endpoints over HTTPS while returning
  `404` for the admin console, admin API, and status-edit endpoint.

Keep the SQLite database, backups, admin token, TLS keys, and any future email
or Pulp credentials outside Git. The admin HTML and API code can remain public:
authorization comes from the server-side token and private network path, not
from hiding source code.

For tunnel-only administration, connect from a maintainer workstation with:

```bash
ssh -N -L 3310:127.0.0.1:3100 \
  -J itodorov@rogi21.fyre.ibm.com root@163.74.88.212
```

Then open `http://127.0.0.1:3310/admin`. A non-root SSH account should replace
the root login once the initial deployment is complete.

## API

- `GET /api/health`
- `GET /api/requests?sort=top|newest&status=proposed`
- `POST /api/requests`
- `PUT /api/requests/:id/vote`
- `DELETE /api/requests/:id/vote`
- `GET /api/admin/requests` with `Authorization: Bearer <ADMIN_TOKEN>`
- `PATCH /api/requests/:id` with `Authorization: Bearer <ADMIN_TOKEN>`

## Maintainer workflow

Open `https://<api-host>/admin` and enter the configured `ADMIN_TOKEN`. The
token is kept in browser session storage and is not compiled into the GitHub
Pages site.

The console lets maintainers:

1. Correct every user-submitted field, including package name, ecosystem,
   upstream URL, description, use case, tester availability, and requester details.
2. Move a new request from **Proposed** to **Under review** to acknowledge it.
3. Record a public maintainer note and progress through **Accepted** and **In progress**.
4. Add the `zopencommunity/<name>port` repository URL when a port repository exists.
5. Add a published package location, including Pulp-hosted Python wheels or RPMs.
6. Mark the request **Available**. At least one repository or artifact link is
   required before the API accepts this state.

Requester name and organization are public only when the requester opts in.
Contact email is never included by the public API; it is returned only from the
admin endpoint and shown only in this protected console.

Status changes are appended to the `request_events` audit table. A request also
records its first acknowledgement and availability timestamps.

The public interface creates an opaque voter ID in browser storage. It is a
low-friction community-interest signal, not a verified one-person-one-vote
system. The unique database constraint prevents accidental duplicate votes from
the same browser, and the API adds per-IP request throttling without storing IP
addresses.
