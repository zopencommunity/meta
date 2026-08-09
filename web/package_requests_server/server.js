const crypto = require("crypto");
const express = require("express");
const fs = require("fs");
const path = require("path");
const sqlite3 = require("sqlite3").verbose();
const {
  approvePulpMatch,
  dismissPulpMatch,
  getPulpOverview,
  syncPulp,
} = require("./pulp_sync");

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
const COMMUNITY_POST_KINDS = new Set([
  "use_case",
  "testing_offer",
  "contribution_offer",
  "technical_note",
  "question",
]);
const MAINTAINER_POST_KINDS = new Set(["maintainer_update", "technical_note", "question"]);
const VALID_POST_MODERATION_STATUSES = new Set(["pending", "published", "hidden"]);
const MAX_BULK_REQUESTS = 25;

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
    `CREATE TABLE IF NOT EXISTS request_posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      request_id INTEGER NOT NULL,
      kind TEXT NOT NULL CHECK (
        kind IN ('use_case', 'testing_offer', 'contribution_offer', 'technical_note', 'question', 'maintainer_update')
      ),
      body TEXT NOT NULL,
      author_name TEXT NOT NULL DEFAULT '',
      organization TEXT NOT NULL DEFAULT '',
      contact_email TEXT NOT NULL DEFAULT '',
      show_author_publicly INTEGER NOT NULL DEFAULT 0 CHECK (show_author_publicly IN (0, 1)),
      author_role TEXT NOT NULL DEFAULT 'community' CHECK (author_role IN ('community', 'maintainer')),
      moderation_status TEXT NOT NULL DEFAULT 'pending' CHECK (
        moderation_status IN ('pending', 'published', 'hidden')
      ),
      edit_token_hash TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      published_at TEXT,
      reviewed_at TEXT,
      FOREIGN KEY (request_id) REFERENCES package_requests(id) ON DELETE CASCADE
    )`,
  );
  await run(
    database,
    `CREATE TABLE IF NOT EXISTS pulp_artifacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source TEXT NOT NULL CHECK (source IN ('rpm', 'wheel')),
      package_name TEXT NOT NULL,
      normalized_name TEXT NOT NULL,
      version TEXT NOT NULL DEFAULT '',
      release TEXT NOT NULL DEFAULT '',
      architecture TEXT NOT NULL DEFAULT '',
      artifact_url TEXT NOT NULL UNIQUE,
      checksum TEXT NOT NULL DEFAULT '',
      published_at TEXT,
      first_seen_at TEXT NOT NULL,
      last_seen_at TEXT NOT NULL
    )`,
  );
  await run(
    database,
    `CREATE TABLE IF NOT EXISTS pulp_sync_runs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      started_at TEXT NOT NULL,
      finished_at TEXT,
      status TEXT NOT NULL CHECK (status IN ('running', 'success', 'failed')),
      artifacts_seen INTEGER NOT NULL DEFAULT 0,
      matches_found INTEGER NOT NULL DEFAULT 0,
      error TEXT NOT NULL DEFAULT ''
    )`,
  );
  await run(
    database,
    `CREATE TABLE IF NOT EXISTS pulp_matches (
      request_id INTEGER NOT NULL,
      source TEXT NOT NULL CHECK (source IN ('rpm', 'wheel')),
      artifact_id INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'suggested' CHECK (status IN ('suggested', 'approved', 'dismissed')),
      matched_at TEXT NOT NULL,
      reviewed_at TEXT,
      PRIMARY KEY (request_id, source),
      FOREIGN KEY (request_id) REFERENCES package_requests(id) ON DELETE CASCADE,
      FOREIGN KEY (artifact_id) REFERENCES pulp_artifacts(id) ON DELETE CASCADE
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
  await run(database, "CREATE INDEX IF NOT EXISTS idx_request_posts_request_id ON request_posts(request_id)");
  await run(database, "CREATE INDEX IF NOT EXISTS idx_request_posts_moderation ON request_posts(moderation_status)");
  await run(database, "CREATE INDEX IF NOT EXISTS idx_pulp_artifacts_name ON pulp_artifacts(source, normalized_name)");
  await run(database, "CREATE INDEX IF NOT EXISTS idx_pulp_matches_status ON pulp_matches(status)");
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

function hashEditToken(value) {
  return crypto.createHash("sha256").update(String(value || "")).digest("hex");
}

function editTokenMatches(request, row) {
  const suppliedHash = hashEditToken(request.get("X-Edit-Token"));
  const storedHash = String(row?.edit_token_hash || "");
  return Boolean(
    storedHash &&
      suppliedHash.length === storedHash.length &&
      crypto.timingSafeEqual(Buffer.from(suppliedHash), Buffer.from(storedHash)),
  );
}

function validatePost(body, role = "community") {
  const source = body && typeof body === "object" ? body : {};
  const post = {
    kind: cleanText(source.kind, 40),
    body: cleanText(source.body, 2000),
    authorName: cleanText(source.authorName, 100),
    organization: cleanText(source.organization, 160),
    contactEmail: cleanText(source.contactEmail, 254),
    showAuthorPublicly: Boolean(source.showAuthorPublicly),
  };
  const validKinds = role === "maintainer" ? MAINTAINER_POST_KINDS : COMMUNITY_POST_KINDS;
  if (!validKinds.has(post.kind)) return { error: "Choose a valid contribution type." };
  if (post.body.length < 10) return { error: "Write at least 10 characters." };
  if ((post.body.match(/https?:\/\//gi) || []).length > 3) {
    return { error: "A post can contain no more than three links." };
  }
  if (!validEmail(post.contactEmail)) {
    return { error: "Enter a valid contact email address or leave it blank." };
  }
  return { post };
}

function mapPost(row, includePrivate = false) {
  const isMaintainer = row.author_role === "maintainer";
  const showAuthor = isMaintainer || Boolean(row.show_author_publicly);
  const post = {
    id: row.id,
    requestId: row.request_id,
    requestPackageName: row.request_package_name || "",
    kind: row.kind,
    body: row.body,
    authorRole: row.author_role,
    authorName: isMaintainer ? "zopen maintainer" : includePrivate || showAuthor ? row.author_name || "" : "",
    organization: isMaintainer ? "" : includePrivate || showAuthor ? row.organization || "" : "",
    showAuthorPublicly: isMaintainer || Boolean(row.show_author_publicly),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    publishedAt: row.published_at || null,
  };
  if (includePrivate) {
    post.contactEmail = row.contact_email || "";
    post.moderationStatus = row.moderation_status;
  }
  return post;
}

function validateSubmission(body) {
  const source = body && typeof body === "object" ? body : {};
  const submission = {
    packageName: cleanText(source.packageName, 80),
    ecosystem: cleanText(source.ecosystem, 30),
    upstreamUrl: cleanText(source.upstreamUrl, 500),
    description: cleanText(source.description, 1200),
    useCase: cleanText(source.useCase, 1200),
    canHelpTest: Boolean(source.canHelpTest),
    requesterName: cleanText(source.requesterName, 100),
    organization: cleanText(source.organization, 160),
    contactEmail: cleanText(source.contactEmail, 254),
    showRequesterPublicly: Boolean(source.showRequesterPublicly),
  };
  submission.normalizedName = normalizePackageName(submission.packageName);

  if (!/^[a-zA-Z0-9][a-zA-Z0-9._+\s-]{0,79}$/.test(submission.packageName)) {
    return { error: "Enter a valid package name." };
  }
  if (submission.upstreamUrl && !validHttpUrl(submission.upstreamUrl)) {
    return { error: "Enter a valid upstream project URL or leave it blank." };
  }
  if (!VALID_ECOSYSTEMS.has(submission.ecosystem)) {
    return { error: "Choose a valid project ecosystem." };
  }
  if (submission.description.length < 20) {
    return { error: "Tell us a little more about why this package is useful." };
  }
  if (!validEmail(submission.contactEmail)) {
    return { error: "Enter a valid contact email address or leave it blank." };
  }
  return { submission };
}

async function insertSubmission(database, submission) {
  const now = new Date().toISOString();
  const result = await run(
    database,
    `INSERT INTO package_requests (
      package_name, normalized_name, ecosystem, upstream_url, description, use_case,
      can_help_test, requester_name, organization, contact_email, show_requester_publicly,
      status, created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'proposed', ?, ?)`,
    [
      submission.packageName,
      submission.normalizedName,
      submission.ecosystem,
      submission.upstreamUrl,
      submission.description,
      submission.useCase,
      submission.canHelpTest ? 1 : 0,
      submission.requesterName,
      submission.organization,
      submission.contactEmail,
      submission.showRequesterPublicly ? 1 : 0,
      now,
      now,
    ],
  );
  const row = await get(
    database,
    "SELECT *, 0 AS vote_count, 0 AS voted FROM package_requests WHERE id = ?",
    [result.id],
  );
  return mapRequest(row);
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
    discussionCount: Number(row.discussion_count || 0),
    pendingPostCount: includePrivate ? Number(row.pending_post_count || 0) : undefined,
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
  app.use(express.json({ limit: "128kb" }));
  app.use((request, response, next) => {
    const origin = request.get("Origin");
    if (origin && allowedOrigins.has(origin.replace(/\/$/, ""))) {
      response.set("Access-Control-Allow-Origin", origin);
      response.set("Vary", "Origin");
      response.set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Voter-ID, X-Edit-Token");
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
  const bulkSubmissionLimiter = createRateLimiter({ limit: 2, windowMilliseconds: 60 * 60 * 1000 });
  const postSubmissionLimiter = createRateLimiter({ limit: 5, windowMilliseconds: 60 * 60 * 1000 });
  const voteLimiter = createRateLimiter({ limit: 60, windowMilliseconds: 60 * 1000 });
  const adminLimiter = createRateLimiter({ limit: 120, windowMilliseconds: 15 * 60 * 1000 });
  let pulpSyncPromise = null;
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
          (SELECT COUNT(*) FROM request_posts post
           WHERE post.request_id = r.id AND post.moderation_status = 'published') AS discussion_count,
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
      response.json({ requests: rows.map((row) => mapRequest(row)) });
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/requests/:id/activity", async (request, response, next) => {
    const requestId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(requestId) || requestId < 1) {
      response.status(400).json({ error: "Invalid package request ID." });
      return;
    }
    try {
      const packageRequest = await get(
        database,
        "SELECT id, package_name, created_at FROM package_requests WHERE id = ?",
        [requestId],
      );
      if (!packageRequest) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      const [events, posts] = await Promise.all([
        all(
          database,
          `SELECT id, from_status, to_status, maintainer_note, created_at
           FROM request_events WHERE request_id = ? ORDER BY created_at`,
          [requestId],
        ),
        all(
          database,
          `SELECT * FROM request_posts
           WHERE request_id = ? AND moderation_status = 'published' ORDER BY created_at`,
          [requestId],
        ),
      ]);
      const activity = [
        {
          id: `created-${requestId}`,
          type: "created",
          packageName: packageRequest.package_name,
          createdAt: packageRequest.created_at,
        },
        ...events.map((event) => ({
          id: `status-${event.id}`,
          type: "status",
          fromStatus: event.from_status,
          toStatus: event.to_status,
          note: event.maintainer_note || "",
          createdAt: event.created_at,
        })),
        ...posts.map((post) => ({ ...mapPost(post), type: "post" })),
      ].sort((left, right) => left.createdAt.localeCompare(right.createdAt));
      response.json({ requestId, activity });
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/requests/:id/posts", postSubmissionLimiter, async (request, response, next) => {
    const requestId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(requestId) || requestId < 1) {
      response.status(400).json({ error: "Invalid package request ID." });
      return;
    }
    if (cleanText(request.body?.website, 200)) {
      response.status(202).json({ accepted: true, moderationStatus: "pending" });
      return;
    }
    const validated = validatePost(request.body, "community");
    if (validated.error) {
      response.status(400).json({ error: validated.error });
      return;
    }
    try {
      const packageRequest = await get(database, "SELECT id FROM package_requests WHERE id = ?", [requestId]);
      if (!packageRequest) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      const editToken = crypto.randomBytes(32).toString("base64url");
      const now = new Date().toISOString();
      const result = await run(
        database,
        `INSERT INTO request_posts (
          request_id, kind, body, author_name, organization, contact_email,
          show_author_publicly, author_role, moderation_status, edit_token_hash,
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'community', 'pending', ?, ?, ?)`,
        [
          requestId,
          validated.post.kind,
          validated.post.body,
          validated.post.authorName,
          validated.post.organization,
          validated.post.contactEmail,
          validated.post.showAuthorPublicly ? 1 : 0,
          hashEditToken(editToken),
          now,
          now,
        ],
      );
      const row = await get(database, "SELECT * FROM request_posts WHERE id = ?", [result.id]);
      response.status(202).json({ post: mapPost(row, true), editToken });
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/posts/:id", async (request, response, next) => {
    const postId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(postId) || postId < 1) {
      response.status(400).json({ error: "Invalid post ID." });
      return;
    }
    try {
      const row = await get(database, "SELECT * FROM request_posts WHERE id = ?", [postId]);
      if (!row || row.author_role !== "community" || !editTokenMatches(request, row)) {
        response.status(404).json({ error: "Post not found." });
        return;
      }
      response.json({ post: mapPost(row, true) });
    } catch (error) {
      next(error);
    }
  });

  app.patch("/api/posts/:id", postSubmissionLimiter, async (request, response, next) => {
    const postId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(postId) || postId < 1) {
      response.status(400).json({ error: "Invalid post ID." });
      return;
    }
    try {
      const existing = await get(database, "SELECT * FROM request_posts WHERE id = ?", [postId]);
      if (!existing || existing.author_role !== "community" || !editTokenMatches(request, existing)) {
        response.status(404).json({ error: "Post not found." });
        return;
      }
      const validated = validatePost({
        kind: request.body?.kind ?? existing.kind,
        body: request.body?.body ?? existing.body,
        authorName: request.body?.authorName ?? existing.author_name,
        organization: request.body?.organization ?? existing.organization,
        contactEmail: request.body?.contactEmail ?? existing.contact_email,
        showAuthorPublicly: request.body?.showAuthorPublicly ?? Boolean(existing.show_author_publicly),
      });
      if (validated.error) {
        response.status(400).json({ error: validated.error });
        return;
      }
      const now = new Date().toISOString();
      await run(
        database,
        `UPDATE request_posts SET kind = ?, body = ?, author_name = ?, organization = ?,
         contact_email = ?, show_author_publicly = ?, moderation_status = 'pending',
         updated_at = ?, published_at = NULL, reviewed_at = NULL WHERE id = ?`,
        [
          validated.post.kind,
          validated.post.body,
          validated.post.authorName,
          validated.post.organization,
          validated.post.contactEmail,
          validated.post.showAuthorPublicly ? 1 : 0,
          now,
          postId,
        ],
      );
      const updated = await get(database, "SELECT * FROM request_posts WHERE id = ?", [postId]);
      response.json({ post: mapPost(updated, true) });
    } catch (error) {
      next(error);
    }
  });

  app.delete("/api/posts/:id", postSubmissionLimiter, async (request, response, next) => {
    const postId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(postId) || postId < 1) {
      response.status(400).json({ error: "Invalid post ID." });
      return;
    }
    try {
      const existing = await get(database, "SELECT * FROM request_posts WHERE id = ?", [postId]);
      if (!existing || existing.author_role !== "community" || !editTokenMatches(request, existing)) {
        response.status(404).json({ error: "Post not found." });
        return;
      }
      await run(database, "DELETE FROM request_posts WHERE id = ?", [postId]);
      response.json({ success: true, id: postId });
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
        `SELECT r.*, COUNT(v.voter_id) AS vote_count, 0 AS voted,
          (SELECT COUNT(*) FROM request_posts post
           WHERE post.request_id = r.id AND post.moderation_status = 'published') AS discussion_count,
          (SELECT COUNT(*) FROM request_posts post
           WHERE post.request_id = r.id AND post.moderation_status = 'pending') AS pending_post_count
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

  app.get("/api/admin/posts", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    const status = request.query.status === "all" ? "" : cleanText(request.query.status || "pending", 20);
    if (status && !VALID_POST_MODERATION_STATUSES.has(status)) {
      response.status(400).json({ error: "Invalid moderation status." });
      return;
    }
    try {
      const rows = await all(
        database,
        `SELECT post.*, r.package_name AS request_package_name
         FROM request_posts post JOIN package_requests r ON r.id = post.request_id
         ${status ? "WHERE post.moderation_status = ?" : ""}
         ORDER BY CASE post.moderation_status WHEN 'pending' THEN 0 WHEN 'published' THEN 1 ELSE 2 END,
           post.created_at DESC`,
        status ? [status] : [],
      );
      response.json({ posts: rows.map((row) => mapPost(row, true)) });
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/admin/requests/:id/posts", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    const requestId = Number.parseInt(request.params.id, 10);
    const validated = validatePost(request.body, "maintainer");
    if (!Number.isSafeInteger(requestId) || requestId < 1) {
      response.status(400).json({ error: "Invalid package request ID." });
      return;
    }
    if (validated.error) {
      response.status(400).json({ error: validated.error });
      return;
    }
    try {
      const packageRequest = await get(database, "SELECT id FROM package_requests WHERE id = ?", [requestId]);
      if (!packageRequest) {
        response.status(404).json({ error: "Package request not found." });
        return;
      }
      const now = new Date().toISOString();
      const result = await run(
        database,
        `INSERT INTO request_posts (
          request_id, kind, body, author_role, moderation_status,
          created_at, updated_at, published_at, reviewed_at
        ) VALUES (?, ?, ?, 'maintainer', 'published', ?, ?, ?, ?)`,
        [requestId, validated.post.kind, validated.post.body, now, now, now, now],
      );
      const row = await get(database, "SELECT * FROM request_posts WHERE id = ?", [result.id]);
      response.status(201).json({ post: mapPost(row, true) });
    } catch (error) {
      next(error);
    }
  });

  app.patch("/api/admin/posts/:id", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    const postId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(postId) || postId < 1) {
      response.status(400).json({ error: "Invalid post ID." });
      return;
    }
    try {
      const existing = await get(database, "SELECT * FROM request_posts WHERE id = ?", [postId]);
      if (!existing) {
        response.status(404).json({ error: "Post not found." });
        return;
      }
      const moderationStatus = request.body?.moderationStatus ?? existing.moderation_status;
      if (!VALID_POST_MODERATION_STATUSES.has(moderationStatus)) {
        response.status(400).json({ error: "Invalid moderation status." });
        return;
      }
      const validated = validatePost(
        {
          kind: request.body?.kind ?? existing.kind,
          body: request.body?.body ?? existing.body,
          authorName: request.body?.authorName ?? existing.author_name,
          organization: request.body?.organization ?? existing.organization,
          contactEmail: request.body?.contactEmail ?? existing.contact_email,
          showAuthorPublicly: request.body?.showAuthorPublicly ?? Boolean(existing.show_author_publicly),
        },
        existing.author_role,
      );
      if (validated.error) {
        response.status(400).json({ error: validated.error });
        return;
      }
      const now = new Date().toISOString();
      await run(
        database,
        `UPDATE request_posts SET kind = ?, body = ?, author_name = ?, organization = ?,
         contact_email = ?, show_author_publicly = ?, moderation_status = ?, updated_at = ?,
         published_at = CASE WHEN ? = 'published' THEN COALESCE(published_at, ?) ELSE NULL END,
         reviewed_at = CASE WHEN ? = 'pending' THEN NULL ELSE ? END WHERE id = ?`,
        [
          validated.post.kind,
          validated.post.body,
          validated.post.authorName,
          validated.post.organization,
          validated.post.contactEmail,
          validated.post.showAuthorPublicly ? 1 : 0,
          moderationStatus,
          now,
          moderationStatus,
          now,
          moderationStatus,
          now,
          postId,
        ],
      );
      const updated = await get(database, "SELECT * FROM request_posts WHERE id = ?", [postId]);
      response.json({ post: mapPost(updated, true) });
    } catch (error) {
      next(error);
    }
  });

  app.delete("/api/admin/posts/:id", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    const postId = Number.parseInt(request.params.id, 10);
    if (!Number.isSafeInteger(postId) || postId < 1) {
      response.status(400).json({ error: "Invalid post ID." });
      return;
    }
    try {
      const result = await run(database, "DELETE FROM request_posts WHERE id = ?", [postId]);
      if (!result.changes) {
        response.status(404).json({ error: "Post not found." });
        return;
      }
      response.json({ success: true, id: postId });
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/admin/pulp", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    try {
      response.json(await getPulpOverview(database));
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/admin/pulp/sync", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    if (pulpSyncPromise) {
      response.status(409).json({ error: "A Pulp synchronization is already running." });
      return;
    }
    try {
      pulpSyncPromise = syncPulp({ database, fetchImpl: options.pulpFetch });
      response.json({ run: await pulpSyncPromise });
    } catch (error) {
      next(error);
    } finally {
      pulpSyncPromise = null;
    }
  });

  app.post("/api/admin/pulp/matches/:requestId/:source/approve", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    const requestId = Number.parseInt(request.params.requestId, 10);
    const source = request.params.source;
    if (!Number.isSafeInteger(requestId) || requestId < 1 || !["rpm", "wheel"].includes(source)) {
      response.status(400).json({ error: "Invalid Pulp match." });
      return;
    }
    try {
      const result = await approvePulpMatch(database, requestId, source);
      if (!result) {
        response.status(404).json({ error: "Pulp match not found or already reviewed." });
        return;
      }
      response.json({ success: true, match: result });
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/admin/pulp/matches/:requestId/:source/dismiss", adminLimiter, async (request, response, next) => {
    const configuredToken = options.adminToken ?? process.env.ADMIN_TOKEN;
    if (!adminTokenMatches(request, configuredToken)) {
      response.status(401).json({ error: "Unauthorized." });
      return;
    }
    const requestId = Number.parseInt(request.params.requestId, 10);
    const source = request.params.source;
    if (!Number.isSafeInteger(requestId) || requestId < 1 || !["rpm", "wheel"].includes(source)) {
      response.status(400).json({ error: "Invalid Pulp match." });
      return;
    }
    try {
      if (!(await dismissPulpMatch(database, requestId, source))) {
        response.status(404).json({ error: "Pulp match not found or already reviewed." });
        return;
      }
      response.json({ success: true });
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/requests", submissionLimiter, async (request, response, next) => {
    const validated = validateSubmission(request.body);
    if (validated.error) {
      response.status(400).json({ error: validated.error });
      return;
    }

    try {
      response.status(201).json({ request: await insertSubmission(database, validated.submission) });
    } catch (error) {
      if (error.code === "SQLITE_CONSTRAINT") {
        const existing = await get(
          database,
          "SELECT id FROM package_requests WHERE normalized_name = ?",
          [validated.submission.normalizedName],
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

  app.post("/api/requests/bulk", bulkSubmissionLimiter, async (request, response, next) => {
    const body = request.body && typeof request.body === "object" ? request.body : {};
    const items = body.requests;
    if (!Array.isArray(items) || items.length < 1) {
      response.status(400).json({ error: "Include at least one package request." });
      return;
    }
    if (items.length > MAX_BULK_REQUESTS) {
      response.status(400).json({ error: `Bulk submissions are limited to ${MAX_BULK_REQUESTS} packages.` });
      return;
    }

    const requester = {
      requesterName: body.requesterName,
      organization: body.organization,
      contactEmail: body.contactEmail,
      showRequesterPublicly: body.showRequesterPublicly,
    };
    const commonDescription = cleanText(body.description, 1200);
    const commonCanHelpTest = Boolean(body.canHelpTest);
    const created = [];
    const duplicates = [];
    const errors = [];
    const seenNames = new Map();

    try {
      for (const [index, item] of items.entries()) {
        const validated = validateSubmission({
          ...requester,
          packageName: item?.packageName,
          ecosystem: item?.ecosystem,
          upstreamUrl: item?.upstreamUrl,
          description: cleanText(item?.description, 1200) || commonDescription,
          useCase: item?.useCase,
          canHelpTest: typeof item?.canHelpTest === "boolean" ? item.canHelpTest : commonCanHelpTest,
        });
        if (validated.error) {
          errors.push({ index, packageName: cleanText(item?.packageName, 80), error: validated.error });
          continue;
        }

        const firstIndex = seenNames.get(validated.submission.normalizedName);
        if (firstIndex !== undefined) {
          duplicates.push({
            index,
            packageName: validated.submission.packageName,
            existingRequestId: null,
            reason: "batch",
            duplicateOfIndex: firstIndex,
          });
          continue;
        }
        seenNames.set(validated.submission.normalizedName, index);

        try {
          created.push(await insertSubmission(database, validated.submission));
        } catch (error) {
          if (error.code !== "SQLITE_CONSTRAINT") throw error;
          const existing = await get(
            database,
            "SELECT id FROM package_requests WHERE normalized_name = ?",
            [validated.submission.normalizedName],
          );
          duplicates.push({
            index,
            packageName: validated.submission.packageName,
            existingRequestId: existing?.id || null,
            reason: "existing",
          });
        }
      }

      response.status(201).json({
        created,
        duplicates,
        errors,
        summary: {
          submitted: items.length,
          created: created.length,
          duplicates: duplicates.length,
          errors: errors.length,
        },
      });
    } catch (error) {
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
        `SELECT r.*, COUNT(v.voter_id) AS vote_count, 0 AS voted,
          (SELECT COUNT(*) FROM request_posts p
           WHERE p.request_id = r.id AND p.moderation_status = 'published') AS discussion_count,
          (SELECT COUNT(*) FROM request_posts p
           WHERE p.request_id = r.id AND p.moderation_status = 'pending') AS pending_post_count
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
