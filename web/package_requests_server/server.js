const crypto = require("crypto");
const express = require("express");
const fs = require("fs");
const path = require("path");
const sqlite3 = require("sqlite3").verbose();

const VALID_STATUSES = new Set([
  "proposed",
  "under_review",
  "accepted",
  "in_progress",
  "available",
  "declined",
]);
const VALID_ECOSYSTEMS = new Set([
  "general",
  "python",
  "c_cpp",
  "rust",
  "go",
  "java",
  "javascript",
  "shell",
  "other",
]);
const VALID_ARTIFACT_KINDS = new Set([
  "",
  "zopen_package",
  "pulp_zopen",
  "pulp_python",
  "pypi",
  "python_wheel",
  "pulp_rpm",
  "other",
]);

function openDatabase(databasePath) {
  if (databasePath !== ":memory:") {
    fs.mkdirSync(path.dirname(databasePath), { recursive: true });
  }

  const database = new sqlite3.Database(databasePath);
  database.configure("busyTimeout", 5000);
  database.exec("PRAGMA foreign_keys = ON; PRAGMA journal_mode = WAL;");
  return database;
}

function run(database, sql, parameters = []) {
  return new Promise((resolve, reject) => {
    database.run(sql, parameters, function onResult(error) {
      if (error) reject(error);
      else resolve({ id: this.lastID, changes: this.changes });
    });
  });
}

function all(database, sql, parameters = []) {
  return new Promise((resolve, reject) => {
    database.all(sql, parameters, (error, rows) => {
      if (error) reject(error);
      else resolve(rows);
    });
  });
}

function get(database, sql, parameters = []) {
  return new Promise((resolve, reject) => {
    database.get(sql, parameters, (error, row) => {
      if (error) reject(error);
      else resolve(row);
    });
  });
}

async function initializeDatabase(database) {
  await run(
    database,
    `CREATE TABLE IF NOT EXISTS package_requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      package_name TEXT NOT NULL,
      normalized_name TEXT NOT NULL UNIQUE,
      ecosystem TEXT NOT NULL DEFAULT 'general',
      port_repository_url TEXT NOT NULL DEFAULT '',
      artifact_kind TEXT NOT NULL DEFAULT '',
      artifact_url TEXT NOT NULL DEFAULT '',
      maintainer_note TEXT NOT NULL DEFAULT '',
      acknowledged_at TEXT,
      available_at TEXT,
      requester_name TEXT NOT NULL DEFAULT '',
      organization TEXT NOT NULL DEFAULT '',
      contact_email TEXT NOT NULL DEFAULT '',
      show_requester_publicly INTEGER NOT NULL DEFAULT 0 CHECK (show_requester_publicly IN (0, 1)),
      upstream_url TEXT NOT NULL,
      description TEXT NOT NULL,
      use_case TEXT NOT NULL DEFAULT '',
      can_help_test INTEGER NOT NULL DEFAULT 0 CHECK (can_help_test IN (0, 1)),
      status TEXT NOT NULL DEFAULT 'proposed' CHECK (
        status IN ('proposed', 'under_review', 'accepted', 'in_progress', 'available', 'declined')
      ),
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )`,
  );
  const columns = await all(database, "PRAGMA table_info(package_requests)");
  const migrations = [
    ["ecosystem", "TEXT NOT NULL DEFAULT 'general'"],
    ["port_repository_url", "TEXT NOT NULL DEFAULT ''"],
    ["artifact_kind", "TEXT NOT NULL DEFAULT ''"],
    ["artifact_url", "TEXT NOT NULL DEFAULT ''"],
    ["maintainer_note", "TEXT NOT NULL DEFAULT ''"],
    ["acknowledged_at", "TEXT"],
    ["available_at", "TEXT"],
    ["requester_name", "TEXT NOT NULL DEFAULT ''"],
    ["organization", "TEXT NOT NULL DEFAULT ''"],
    ["contact_email", "TEXT NOT NULL DEFAULT ''"],
    ["show_requester_publicly", "INTEGER NOT NULL DEFAULT 0"],
  ];
  for (const [columnName, definition] of migrations) {
    if (!columns.some((column) => column.name === columnName)) {
      await run(database, `ALTER TABLE package_requests ADD COLUMN ${columnName} ${definition}`);
    }
  }
  await run(
    database,
    `CREATE TABLE IF NOT EXISTS votes (
      request_id INTEGER NOT NULL,
      voter_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (request_id, voter_id),
      FOREIGN KEY (request_id) REFERENCES package_requests(id) ON DELETE CASCADE
    )`,
  );
  await run(
    database,
    `CREATE TABLE IF NOT EXISTS request_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      request_id INTEGER NOT NULL,
      from_status TEXT NOT NULL,
      to_status TEXT NOT NULL,
      maintainer_note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      FOREIGN KEY (request_id) REFERENCES package_requests(id) ON DELETE CASCADE
    )`,
  );
  await run(
    database,
    "CREATE INDEX IF NOT EXISTS idx_package_requests_status ON package_requests(status)",
  );
  await run(
    database,
    "CREATE INDEX IF NOT EXISTS idx_package_requests_ecosystem ON package_requests(ecosystem)",
  );
  await run(
    database,
    "CREATE INDEX IF NOT EXISTS idx_votes_request_id ON votes(request_id)",
  );
  await run(
    database,
    "CREATE INDEX IF NOT EXISTS idx_request_events_request_id ON request_events(request_id)",
  );
}

function normalizePackageName(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/-?port$/, "");
}

function cleanText(value, maximumLength) {
  return String(value || "").trim().slice(0, maximumLength);
}

function validHttpUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
}

function validVoterId(value) {
  return typeof value === "string" && /^[a-zA-Z0-9_-]{20,128}$/.test(value);
}

function validEmail(value) {
  return !value || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function mapRequest(row, includePrivate = false) {
  const showRequester = Boolean(row.show_requester_publicly);
  const request = {
    id: row.id,
    packageName: row.package_name,
    ecosystem: row.ecosystem,
    portRepositoryUrl: row.port_repository_url || "",
    artifactKind: row.artifact_kind || "",
    artifactUrl: row.artifact_url || "",
    maintainerNote: row.maintainer_note || "",
    acknowledgedAt: row.acknowledged_at || null,
    availableAt: row.available_at || null,
    upstreamUrl: row.upstream_url,
    description: row.description,
    useCase: row.use_case,
    canHelpTest: Boolean(row.can_help_test),
    requesterName: includePrivate || showRequester ? row.requester_name || "" : "",
    organization: includePrivate || showRequester ? row.organization || "" : "",
    showRequesterPublicly: showRequester,
    status: row.status,
    voteCount: Number(row.vote_count || 0),
    voted: Boolean(row.voted),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
  if (includePrivate) request.contactEmail = row.contact_email || "";
  return request;
}

function createRateLimiter({ limit, windowMilliseconds }) {
  const entries = new Map();
  return (request, response, next) => {
    const now = Date.now();
    const key = request.ip || request.socket.remoteAddress || "unknown";
    const current = entries.get(key);

    if (!current || current.resetAt <= now) {
      entries.set(key, { count: 1, resetAt: now + windowMilliseconds });
      next();
      return;
    }

    if (current.count >= limit) {
      response.set("Retry-After", String(Math.ceil((current.resetAt - now) / 1000)));
      response.status(429).json({ error: "Too many requests. Please try again later." });
      return;
    }

    current.count += 1;
    next();
  };
}

function adminTokenMatches(request, configuredToken) {
  const suppliedToken = String(request.get("Authorization") || "").replace(/^Bearer\s+/i, "");
  return Boolean(
    configuredToken &&
      suppliedToken &&
      suppliedToken.length === configuredToken.length &&
      crypto.timingSafeEqual(Buffer.from(suppliedToken), Buffer.from(configuredToken)),
  );
}

function createApp(options = {}) {
  const databasePath =
    options.databasePath ||
    process.env.DATABASE_PATH ||
    path.join(__dirname, "db", "package_requests.db");
  const database = options.database || openDatabase(databasePath);
  const app = express();
  const allowedOrigins = new Set(
    String(
      options.allowedOrigins ??
        process.env.ALLOWED_ORIGINS ??
        "http://localhost:5173,http://localhost:4173,http://127.0.0.1:5173,http://127.0.0.1:4173",
    )
      .split(",")
      .map((origin) => origin.trim().replace(/\/$/, ""))
      .filter(Boolean),
  );

  if (String(process.env.TRUST_PROXY || "").toLowerCase() === "true") {
    app.set("trust proxy", 1);
  }

  app.disable("x-powered-by");
  app.use(express.json({ limit: "32kb" }));
  app.use((request, response, next) => {
    const origin = request.get("Origin");
    if (origin && allowedOrigins.has(origin.replace(/\/$/, ""))) {
      response.set("Access-Control-Allow-Origin", origin);
      response.set("Vary", "Origin");
      response.set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Voter-ID");
      response.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS");
    }

    if (request.method === "OPTIONS") {
      if (origin && !allowedOrigins.has(origin.replace(/\/$/, ""))) {
        response.sendStatus(403);
      } else {
        response.sendStatus(204);
      }
      return;
    }
    next();
  });

  const submissionLimiter = createRateLimiter({ limit: 5, windowMilliseconds: 60 * 60 * 1000 });
  const voteLimiter = createRateLimiter({ limit: 60, windowMilliseconds: 60 * 1000 });
  const adminLimiter = createRateLimiter({ limit: 120, windowMilliseconds: 15 * 60 * 1000 });
  const ready = initializeDatabase(database);

  app.use(async (request, response, next) => {
    try {
      await ready;
      next();
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/health", (request, response) => {
    response.json({ status: "ok" });
  });

  app.get("/admin", (request, response) => {
    response.set(
      "Content-Security-Policy",
      "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'self'; frame-ancestors 'none'",
    );
    response.sendFile(path.join(__dirname, "admin.html"));
  });

  app.get("/api/requests", async (request, response, next) => {
    try {
      const voterId = validVoterId(request.get("X-Voter-ID")) ? request.get("X-Voter-ID") : "";
      const sort = request.query.sort === "newest" ? "newest" : "top";
      const status = VALID_STATUSES.has(request.query.status) ? request.query.status : "";
      const ordering =
        sort === "newest"
          ? "r.created_at DESC"
          : "vote_count DESC, r.created_at DESC";
      const where = status ? "WHERE r.status = ?" : "WHERE r.status != 'declined'";
      const parameters = status ? [voterId, status] : [voterId];
      const rows = await all(
        database,
        `SELECT r.*, COUNT(v.voter_id) AS vote_count,
          EXISTS(
            SELECT 1 FROM votes own_vote
            WHERE own_vote.request_id = r.id AND own_vote.voter_id = ?
          ) AS voted
        FROM package_requests r
        LEFT JOIN votes v ON v.request_id = r.id
        ${where}
        GROUP BY r.id
        ORDER BY ${ordering}`,
        parameters,
      );
      response.json({ requests: rows.map(mapRequest) });
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/admin/requests", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }

    try {
      const rows = await all(
        database,
        `SELECT r.*, COUNT(v.voter_id) AS vote_count, 0 AS voted
         FROM package_requests r
         LEFT JOIN votes v ON v.request_id = r.id
         GROUP BY r.id
         ORDER BY
           CASE r.status
             WHEN 'proposed' THEN 0
             WHEN 'under_review' THEN 1
             WHEN 'accepted' THEN 2
             WHEN 'in_progress' THEN 3
             WHEN 'available' THEN 4
             ELSE 5
           END,
           vote_count DESC,
           r.created_at DESC`,
      );
      response.json({ requests: rows.map((row) => mapRequest(row, true)) });
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/requests", submissionLimiter, async (request, response, next) => {
    const packageName = cleanText(request.body.packageName, 80);
    const normalizedName = normalizePackageName(packageName);
    const ecosystem = cleanText(request.body.ecosystem, 30);
    const upstreamUrl = cleanText(request.body.upstreamUrl, 500);
    const description = cleanText(request.body.description, 1200);
    const useCase = cleanText(request.body.useCase, 1200);
    const canHelpTest = Boolean(request.body.canHelpTest);
    const requesterName = cleanText(request.body.requesterName, 100);
    const organization = cleanText(request.body.organization, 160);
    const contactEmail = cleanText(request.body.contactEmail, 254);
    const showRequesterPublicly = Boolean(request.body.showRequesterPublicly);

    if (!/^[a-zA-Z0-9][a-zA-Z0-9._+\s-]{0,79}$/.test(packageName)) {
      response.status(400).json({ error: "Enter a valid package name." });
      return;
    }
    if (upstreamUrl && !validHttpUrl(upstreamUrl)) {
      response.status(400).json({ error: "Enter a valid upstream project URL or leave it blank." });
      return;
    }
    if (!VALID_ECOSYSTEMS.has(ecosystem)) {
      response.status(400).json({ error: "Choose a valid project ecosystem." });
      return;
    }
    if (description.length < 20) {
      response.status(400).json({ error: "Tell us a little more about why this package is useful." });
      return;
    }
    if (!validEmail(contactEmail)) {
      response.status(400).json({ error: "Enter a valid contact email address or leave it blank." });
      return;
    }

    try {
      const now = new Date().toISOString();
      const result = await run(
        database,
        `INSERT INTO package_requests (
          package_name, normalized_name, ecosystem, upstream_url, description, use_case,
          can_help_test, requester_name, organization, contact_email, show_requester_publicly,
          status, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'proposed', ?, ?)`,
        [
          packageName,
          normalizedName,
          ecosystem,
          upstreamUrl,
          description,
          useCase,
          canHelpTest ? 1 : 0,
          requesterName,
          organization,
          contactEmail,
          showRequesterPublicly ? 1 : 0,
          now,
          now,
        ],
      );
      const row = await get(
        database,
        "SELECT *, 0 AS vote_count, 0 AS voted FROM package_requests WHERE id = ?",
        [result.id],
      );
      response.status(201).json({ request: mapRequest(row) });
    } catch (error) {
      if (error.code === "SQLITE_CONSTRAINT") {
        const existing = await get(
          database,
          "SELECT id FROM package_requests WHERE normalized_name = ?",
          [normalizedName],
        );
        response.status(409).json({
          error: "That package has already been requested. You can vote for the existing request.",
          existingRequestId: existing?.id,
        });
        return;
      }
      next(error);
    }
  });

  app.put("/api/requests/:id/vote", voteLimiter, async (request, response, next) => {
    const requestId = Number.parseInt(request.params.id, 10);
    const voterId = request.body.voterId;
    if (!Number.isSafeInteger(requestId) || requestId < 1 || !validVoterId(voterId)) {
      response.status(400).json({ error: "Invalid vote." });
      return;
    }

    try {
      const packageRequest = await get(database, "SELECT id FROM package_requests WHERE id = ?", [requestId]);
      if (!packageRequest) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      await run(
        database,
        "INSERT OR IGNORE INTO votes (request_id, voter_id, created_at) VALUES (?, ?, ?)",
        [requestId, voterId, new Date().toISOString()],
      );
      const count = await get(database, "SELECT COUNT(*) AS total FROM votes WHERE request_id = ?", [requestId]);
      response.json({ voted: true, voteCount: count.total });
    } catch (error) {
      next(error);
    }
  });

  app.delete("/api/requests/:id/vote", voteLimiter, async (request, response, next) => {
    const requestId = Number.parseInt(request.params.id, 10);
    const voterId = request.body.voterId;
    if (!Number.isSafeInteger(requestId) || requestId < 1 || !validVoterId(voterId)) {
      response.status(400).json({ error: "Invalid vote." });
      return;
    }

    try {
      await run(database, "DELETE FROM votes WHERE request_id = ? AND voter_id = ?", [requestId, voterId]);
      const count = await get(database, "SELECT COUNT(*) AS total FROM votes WHERE request_id = ?", [requestId]);
      response.json({ voted: false, voteCount: count.total });
    } catch (error) {
      next(error);
    }
  });

  app.patch("/api/requests/:id", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }

    const requestId = Number.parseInt(request.params.id, 10);
    const status = request.body.status;
    const portRepositoryUrl = request.body.portRepositoryUrl === undefined
      ? null
      : cleanText(request.body.portRepositoryUrl, 500);
    const artifactKind = request.body.artifactKind === undefined
      ? null
      : cleanText(request.body.artifactKind, 40);
    const artifactUrl = request.body.artifactUrl === undefined
      ? null
      : cleanText(request.body.artifactUrl, 500);
    const maintainerNote = request.body.maintainerNote === undefined
      ? null
      : cleanText(request.body.maintainerNote, 1200);
    const packageName = request.body.packageName === undefined ? null : cleanText(request.body.packageName, 80);
    const ecosystem = request.body.ecosystem === undefined ? null : cleanText(request.body.ecosystem, 30);
    const upstreamUrl = request.body.upstreamUrl === undefined ? null : cleanText(request.body.upstreamUrl, 500);
    const description = request.body.description === undefined ? null : cleanText(request.body.description, 1200);
    const useCase = request.body.useCase === undefined ? null : cleanText(request.body.useCase, 1200);
    const canHelpTest = request.body.canHelpTest === undefined ? null : Boolean(request.body.canHelpTest);
    const requesterName = request.body.requesterName === undefined ? null : cleanText(request.body.requesterName, 100);
    const organization = request.body.organization === undefined ? null : cleanText(request.body.organization, 160);
    const contactEmail = request.body.contactEmail === undefined ? null : cleanText(request.body.contactEmail, 254);
    const showRequesterPublicly = request.body.showRequesterPublicly === undefined
      ? null
      : Boolean(request.body.showRequesterPublicly);
    if (!Number.isSafeInteger(requestId) || requestId < 1 || !VALID_STATUSES.has(status)) {
      response.status(400).json({ error: "Invalid request status." });
      return;
    }
    if (portRepositoryUrl !== null && portRepositoryUrl && !validHttpUrl(portRepositoryUrl)) {
      response.status(400).json({ error: "Enter a valid zopen port repository URL." });
      return;
    }
    if (
      (artifactKind !== null && !VALID_ARTIFACT_KINDS.has(artifactKind)) ||
      (artifactUrl !== null && artifactUrl && !validHttpUrl(artifactUrl))
    ) {
      response.status(400).json({ error: "Enter a valid published artifact type and URL." });
      return;
    }
    if (packageName !== null && !/^[a-zA-Z0-9][a-zA-Z0-9._+\s-]{0,79}$/.test(packageName)) {
      response.status(400).json({ error: "Enter a valid package name." });
      return;
    }
    if (ecosystem !== null && !VALID_ECOSYSTEMS.has(ecosystem)) {
      response.status(400).json({ error: "Choose a valid project ecosystem." });
      return;
    }
    if (upstreamUrl !== null && upstreamUrl && !validHttpUrl(upstreamUrl)) {
      response.status(400).json({ error: "Enter a valid upstream project URL or leave it blank." });
      return;
    }
    if (description !== null && description.length < 20) {
      response.status(400).json({ error: "The package description must be at least 20 characters." });
      return;
    }
    if (contactEmail !== null && !validEmail(contactEmail)) {
      response.status(400).json({ error: "Enter a valid contact email address or leave it blank." });
      return;
    }

    try {
      const existing = await get(database, "SELECT * FROM package_requests WHERE id = ?", [requestId]);
      if (!existing) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      const effectivePortRepositoryUrl = portRepositoryUrl ?? existing.port_repository_url;
      const effectiveArtifactKind = artifactKind ?? existing.artifact_kind;
      const effectiveArtifactUrl = artifactUrl ?? existing.artifact_url;
      const effectiveMaintainerNote = maintainerNote ?? existing.maintainer_note;
      const effectivePackageName = packageName ?? existing.package_name;
      const effectiveNormalizedName = normalizePackageName(effectivePackageName);
      const effectiveEcosystem = ecosystem ?? existing.ecosystem;
      const effectiveUpstreamUrl = upstreamUrl ?? existing.upstream_url;
      const effectiveDescription = description ?? existing.description;
      const effectiveUseCase = useCase ?? existing.use_case;
      const effectiveCanHelpTest = canHelpTest ?? Boolean(existing.can_help_test);
      const effectiveRequesterName = requesterName ?? existing.requester_name;
      const effectiveOrganization = organization ?? existing.organization;
      const effectiveContactEmail = contactEmail ?? existing.contact_email;
      const effectiveShowRequesterPublicly = showRequesterPublicly ?? Boolean(existing.show_requester_publicly);
      if (effectiveArtifactKind && !effectiveArtifactUrl) {
        response.status(400).json({ error: "An artifact type requires a published artifact URL." });
        return;
      }
      if (effectiveArtifactUrl && !effectiveArtifactKind) {
        response.status(400).json({ error: "Choose a type for the published artifact." });
        return;
      }
      if (status === "available" && !effectivePortRepositoryUrl && !effectiveArtifactUrl) {
        response.status(400).json({ error: "Available requests must include a port repository or published artifact link." });
        return;
      }
      const now = new Date().toISOString();
      const acknowledgedAt =
        existing.acknowledged_at || (existing.status === "proposed" && status !== "proposed" ? now : null);
      const availableAt = status === "available" ? existing.available_at || now : existing.available_at;
      const result = await run(
        database,
        `UPDATE package_requests SET
          package_name = ?, normalized_name = ?, ecosystem = ?, upstream_url = ?,
          description = ?, use_case = ?, can_help_test = ?, requester_name = ?,
          organization = ?, contact_email = ?, show_requester_publicly = ?,
          status = ?, port_repository_url = ?, artifact_kind = ?, artifact_url = ?,
          maintainer_note = ?, acknowledged_at = ?, available_at = ?, updated_at = ?
         WHERE id = ?`,
        [
          effectivePackageName,
          effectiveNormalizedName,
          effectiveEcosystem,
          effectiveUpstreamUrl,
          effectiveDescription,
          effectiveUseCase,
          effectiveCanHelpTest ? 1 : 0,
          effectiveRequesterName,
          effectiveOrganization,
          effectiveContactEmail,
          effectiveShowRequesterPublicly ? 1 : 0,
          status,
          effectivePortRepositoryUrl,
          effectiveArtifactKind,
          effectiveArtifactUrl,
          effectiveMaintainerNote,
          acknowledgedAt,
          availableAt,
          now,
          requestId,
        ],
      );
      if (!result.changes) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      if (existing.status !== status) {
        await run(
          database,
          `INSERT INTO request_events (request_id, from_status, to_status, maintainer_note, created_at)
           VALUES (?, ?, ?, ?, ?)`,
          [requestId, existing.status, status, effectiveMaintainerNote, now],
        );
      }
      const updated = await get(
        database,
        `SELECT r.*, COUNT(v.voter_id) AS vote_count, 0 AS voted
         FROM package_requests r LEFT JOIN votes v ON v.request_id = r.id
         WHERE r.id = ? GROUP BY r.id`,
        [requestId],
      );
      response.json({ success: true, request: mapRequest(updated, true) });
    } catch (error) {
      if (error.code === "SQLITE_CONSTRAINT") {
        response.status(409).json({ error: "Another request already uses that package name." });
        return;
      }
      next(error);
    }
  });

  app.delete("/api/requests/:id", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }

    const requestId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(requestId) || requestId < 1) {
      response.status(400).json({ error: "Invalid package request ID." });
      return;
    }

    try {
      const result = await run(database, "DELETE FROM package_requests WHERE id = ?", [requestId]);
      if (!result.changes) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      response.json({ success: true, id: requestId });
    } catch (error) {
      next(error);
    }
  });

  app.use((error, request, response, next) => {
    console.error(error);
    if (response.headersSent) {
      next(error);
      return;
    }
    response.status(500).json({ error: "Internal server error." });
  });

  app.locals.database = database;
  app.locals.ready = ready;
  return app;
}

if (require.main === module) {
  const port = Number(process.env.PORT) || 3100;
  const host = process.env.HOST || "127.0.0.1";
  const app = createApp();
  app.listen(port, host, () => {
    console.log(`Package requests API listening on http://${host}:${port}`);
  });
}

module.exports = { createApp, initializeDatabase, normalizePackageName, openDatabase };
