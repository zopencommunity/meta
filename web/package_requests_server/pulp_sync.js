const DEFAULT_RPM_BASE_URL = "https://repo.zopen.community/pulp/content/zopen/";
const DEFAULT_WHEEL_BASE_URL = "https://repo.zopen.community/pulp/content/wheels/";

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
    database.all(sql, parameters, (error, rows) => error ? reject(error) : resolve(rows));
  });
}

function get(database, sql, parameters = []) {
  return new Promise((resolve, reject) => {
    database.get(sql, parameters, (error, row) => error ? reject(error) : resolve(row));
  });
}

function decodeXml(value) {
  return String(value || "")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;|&apos;/g, "'");
}

function normalizeForMatch(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[-_.\s]+/g, "-")
    .replace(/-?port$/, "");
}

function attribute(fragment, name) {
  const match = String(fragment || "").match(new RegExp(`${name}=["']([^"']*)["']`, "i"));
  return decodeXml(match?.[1] || "");
}

function elementText(fragment, name) {
  const match = String(fragment || "").match(new RegExp(`<${name}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${name}>`, "i"));
  return decodeXml((match?.[1] || "").replace(/<[^>]+>/g, "").trim());
}

function parseRpmMetadata(repomdXml, primaryXml, rpmBaseUrl = DEFAULT_RPM_BASE_URL) {
  const primaryBlock = [...repomdXml.matchAll(/<data\b[^>]*type=["']primary["'][^>]*>([\s\S]*?)<\/data>/gi)][0]?.[1];
  const primaryLocationTag = primaryBlock?.match(/<location\b[^>]*>/i)?.[0];
  const primaryLocation = attribute(primaryLocationTag, "href");
  if (!primaryLocation) throw new Error("Pulp RPM metadata does not contain a primary metadata location.");

  const artifacts = [];
  for (const match of primaryXml.matchAll(/<package\b[^>]*>([\s\S]*?)<\/package>/gi)) {
    const block = match[1];
    const name = elementText(block, "name");
    const versionTag = block.match(/<version\b[^>]*>/i)?.[0];
    const locationTag = block.match(/<location\b[^>]*>/i)?.[0];
    const timeTag = block.match(/<time\b[^>]*>/i)?.[0];
    const checksumTag = block.match(/<checksum\b[^>]*>([\s\S]*?)<\/checksum>/i);
    const location = attribute(locationTag, "href");
    if (!name || !location) continue;
    const timestamp = Number(attribute(timeTag, "file"));
    artifacts.push({
      source: "rpm",
      packageName: name,
      normalizedName: normalizeForMatch(name),
      version: attribute(versionTag, "ver"),
      release: attribute(versionTag, "rel"),
      architecture: elementText(block, "arch"),
      artifactUrl: new URL(location, rpmBaseUrl).href,
      checksum: decodeXml(checksumTag?.[1]?.trim() || ""),
      publishedAt: Number.isFinite(timestamp) && timestamp > 0 ? new Date(timestamp * 1000).toISOString() : null,
    });
  }
  return { primaryLocation, artifacts };
}

function parseWheelIndex(indexHtml, wheelBaseUrl = DEFAULT_WHEEL_BASE_URL) {
  const artifacts = [];
  for (const match of indexHtml.matchAll(/<a\s+href=["']([^"']+\.whl)["'][^>]*>[^<]*<\/a>([^\r\n]*)/gi)) {
    const href = decodeXml(match[1]);
    const filename = decodeURIComponent(href.split("/").pop());
    const parts = filename.replace(/\.whl$/i, "").split("-");
    if (parts.length < 5) continue;
    const packageName = parts[0].replace(/_/g, "-");
    const dateMatch = match[2].match(/(\d{2}-[A-Za-z]{3}-\d{4})\s+(\d{2}:\d{2})/);
    const parsedDate = dateMatch ? new Date(`${dateMatch[1]} ${dateMatch[2]} UTC`) : null;
    artifacts.push({
      source: "wheel",
      packageName,
      normalizedName: normalizeForMatch(packageName),
      version: parts[1],
      release: "",
      architecture: parts.slice(-3).join("-"),
      artifactUrl: new URL(href, wheelBaseUrl).href,
      checksum: "",
      publishedAt: parsedDate && !Number.isNaN(parsedDate.valueOf()) ? parsedDate.toISOString() : null,
    });
  }
  return artifacts;
}

async function fetchText(url, fetchImpl) {
  const response = await fetchImpl(url, {
    headers: { "User-Agent": "zopen-package-request-pulp-sync/1.0" },
    signal: typeof AbortSignal?.timeout === "function" ? AbortSignal.timeout(30000) : undefined,
  });
  if (!response.ok) throw new Error(`Pulp returned HTTP ${response.status} for ${url}`);
  return response.text();
}

function newerArtifact(candidate, current) {
  if (!current) return true;
  const candidateTime = candidate.publishedAt || "";
  const currentTime = current.publishedAt || "";
  if (candidateTime !== currentTime) return candidateTime > currentTime;
  return `${candidate.version}-${candidate.release}` > `${current.version}-${current.release}`;
}

async function syncPulp(options) {
  const database = options.database;
  const fetchImpl = options.fetchImpl || global.fetch;
  const rpmBaseUrl = options.rpmBaseUrl || process.env.PULP_RPM_BASE_URL || DEFAULT_RPM_BASE_URL;
  const wheelBaseUrl = options.wheelBaseUrl || process.env.PULP_WHEEL_BASE_URL || DEFAULT_WHEEL_BASE_URL;
  const startedAt = new Date().toISOString();
  const runResult = await run(
    database,
    "INSERT INTO pulp_sync_runs (started_at, status) VALUES (?, 'running')",
    [startedAt],
  );

  try {
    const repomdUrl = new URL("repodata/repomd.xml", rpmBaseUrl).href;
    const [repomdXml, wheelHtml] = await Promise.all([
      fetchText(repomdUrl, fetchImpl),
      fetchText(wheelBaseUrl, fetchImpl),
    ]);
    const primaryLocationTag = [...repomdXml.matchAll(/<data\b[^>]*type=["']primary["'][^>]*>([\s\S]*?)<\/data>/gi)][0]?.[1]?.match(/<location\b[^>]*>/i)?.[0];
    const primaryLocation = attribute(primaryLocationTag, "href");
    if (!primaryLocation) throw new Error("Pulp RPM metadata does not contain primary metadata.");
    const primaryXml = await fetchText(new URL(primaryLocation, rpmBaseUrl).href, fetchImpl);
    const rpmArtifacts = parseRpmMetadata(repomdXml, primaryXml, rpmBaseUrl).artifacts;
    const artifacts = [...rpmArtifacts, ...parseWheelIndex(wheelHtml, wheelBaseUrl)];
    const now = new Date().toISOString();
    const currentArtifacts = new Map();

    await run(database, "BEGIN IMMEDIATE");
    try {
      for (const artifact of artifacts) {
        await run(
          database,
          `INSERT INTO pulp_artifacts (
             source, package_name, normalized_name, version, release, architecture,
             artifact_url, checksum, published_at, first_seen_at, last_seen_at
           ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ON CONFLICT(artifact_url) DO UPDATE SET
             package_name = excluded.package_name, normalized_name = excluded.normalized_name,
             version = excluded.version, release = excluded.release,
             architecture = excluded.architecture, checksum = excluded.checksum,
             published_at = excluded.published_at, last_seen_at = excluded.last_seen_at`,
          [
            artifact.source, artifact.packageName, artifact.normalizedName, artifact.version,
            artifact.release, artifact.architecture, artifact.artifactUrl, artifact.checksum,
            artifact.publishedAt, now, now,
          ],
        );
        const stored = await get(database, "SELECT id FROM pulp_artifacts WHERE artifact_url = ?", [artifact.artifactUrl]);
        const withId = { ...artifact, id: stored.id };
        const key = `${artifact.source}:${artifact.normalizedName}`;
        if (newerArtifact(withId, currentArtifacts.get(key))) currentArtifacts.set(key, withId);
      }

      const requests = await all(
        database,
        "SELECT id, package_name FROM package_requests WHERE status NOT IN ('available', 'declined')",
      );
      const existingRows = await all(database, "SELECT * FROM pulp_matches");
      const existing = new Map(existingRows.map((row) => [`${row.request_id}:${row.source}`, row]));
      const activeKeys = new Set();
      let matchesFound = 0;

      for (const request of requests) {
        const normalizedRequest = normalizeForMatch(request.package_name);
        for (const source of ["rpm", "wheel"]) {
          const artifact = currentArtifacts.get(`${source}:${normalizedRequest}`);
          if (!artifact) continue;
          const key = `${request.id}:${source}`;
          activeKeys.add(key);
          matchesFound += 1;
          const previous = existing.get(key);
          if (!previous) {
            await run(
              database,
              `INSERT INTO pulp_matches (request_id, source, artifact_id, status, matched_at)
               VALUES (?, ?, ?, 'suggested', ?)`,
              [request.id, source, artifact.id, now],
            );
          } else if (previous.artifact_id !== artifact.id) {
            await run(
              database,
              `UPDATE pulp_matches SET artifact_id = ?, status = 'suggested', matched_at = ?, reviewed_at = NULL
               WHERE request_id = ? AND source = ?`,
              [artifact.id, now, request.id, source],
            );
          }
        }
      }

      for (const previous of existingRows) {
        const key = `${previous.request_id}:${previous.source}`;
        if (previous.status === "suggested" && !activeKeys.has(key)) {
          await run(database, "DELETE FROM pulp_matches WHERE request_id = ? AND source = ?", [previous.request_id, previous.source]);
        }
      }
      await run(database, "COMMIT");

      const finishedAt = new Date().toISOString();
      await run(
        database,
        `UPDATE pulp_sync_runs SET finished_at = ?, status = 'success', artifacts_seen = ?, matches_found = ?
         WHERE id = ?`,
        [finishedAt, artifacts.length, matchesFound, runResult.id],
      );
      return { id: runResult.id, status: "success", artifactsSeen: artifacts.length, matchesFound, startedAt, finishedAt };
    } catch (error) {
      await run(database, "ROLLBACK");
      throw error;
    }
  } catch (error) {
    await run(
      database,
      "UPDATE pulp_sync_runs SET finished_at = ?, status = 'failed', error = ? WHERE id = ?",
      [new Date().toISOString(), String(error.message || error).slice(0, 1000), runResult.id],
    );
    throw error;
  }
}

async function getPulpOverview(database) {
  const [matches, runs, counts] = await Promise.all([
    all(
      database,
      `SELECT pm.request_id, pm.source, pm.status, pm.matched_at,
              r.package_name AS request_package_name, r.status AS request_status,
              r.ecosystem AS request_ecosystem,
              a.id AS artifact_id, a.package_name, a.version, a.release, a.architecture,
              a.artifact_url, a.checksum, a.published_at
       FROM pulp_matches pm
       JOIN package_requests r ON r.id = pm.request_id
       JOIN pulp_artifacts a ON a.id = pm.artifact_id
       WHERE pm.status = 'suggested'
       ORDER BY r.id DESC,
         CASE
           WHEN r.ecosystem = 'python' AND pm.source = 'wheel' THEN 0
           WHEN r.ecosystem != 'python' AND pm.source = 'rpm' THEN 0
           ELSE 1
         END,
         pm.matched_at DESC, pm.source`,
    ),
    all(database, "SELECT * FROM pulp_sync_runs ORDER BY id DESC LIMIT 10"),
    get(database, "SELECT COUNT(*) AS artifacts FROM pulp_artifacts"),
  ]);
  return {
    matches: matches.map((row) => ({
      requestId: row.request_id,
      requestPackageName: row.request_package_name,
      requestStatus: row.request_status,
      requestEcosystem: row.request_ecosystem,
      source: row.source,
      isPrimary: row.request_ecosystem === "python" ? row.source === "wheel" : row.source === "rpm",
      matchedAt: row.matched_at,
      artifactId: row.artifact_id,
      packageName: row.package_name,
      version: row.version,
      release: row.release,
      architecture: row.architecture,
      artifactUrl: row.artifact_url,
      checksum: row.checksum,
      publishedAt: row.published_at,
    })),
    runs: runs.map((row) => ({
      id: row.id,
      startedAt: row.started_at,
      finishedAt: row.finished_at,
      status: row.status,
      artifactsSeen: row.artifacts_seen,
      matchesFound: row.matches_found,
      error: row.error,
    })),
    artifactCount: counts.artifacts,
  };
}

async function approvePulpMatch(database, requestId, source) {
  const now = new Date().toISOString();
  await run(database, "BEGIN IMMEDIATE");
  try {
    const match = await get(
      database,
      `SELECT pm.*, a.artifact_url, a.package_name AS artifact_package_name, a.version, a.release,
              a.architecture, a.last_seen_at, r.package_name AS request_package_name,
              r.status AS request_status, r.maintainer_note, r.acknowledged_at, r.install_command
       FROM pulp_matches pm
       JOIN pulp_artifacts a ON a.id = pm.artifact_id
       JOIN package_requests r ON r.id = pm.request_id
       WHERE pm.request_id = ? AND pm.source = ? AND pm.status = 'suggested'`,
      [requestId, source],
    );
    if (!match) {
      await run(database, "ROLLBACK");
      return null;
    }
    const artifactKind = source === "wheel" ? "pulp_python" : "pulp_zopen";
    const installCommand = match.install_command || (source === "wheel"
      ? `export PIP_EXTRA_INDEX_URL="https://repo.zopen.community/pypi/wheels/simple/"\nexport PIP_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"\npip install ${match.request_package_name}`
      : `zopen install ${match.request_package_name}`);
    const acknowledgedAt = match.acknowledged_at || now;
    await run(
      database,
      `UPDATE package_requests SET status = 'available', artifact_kind = ?, artifact_url = ?,
       install_command = ?, package_version = ?, package_architecture = ?, artifact_last_synced_at = ?,
       resolution_kind = 'zopen_release',
       acknowledged_at = ?, available_at = COALESCE(available_at, ?), updated_at = ? WHERE id = ?`,
      [artifactKind, match.artifact_url, installCommand, match.version || "", match.architecture || "",
        match.last_seen_at || now, acknowledgedAt, now, now, requestId],
    );
    if (match.request_status !== "available") {
      await run(
        database,
        `INSERT INTO request_events (request_id, from_status, to_status, maintainer_note, created_at)
         VALUES (?, ?, 'available', ?, ?)`,
        [requestId, match.request_status, match.maintainer_note || "", now],
      );
    }
    await run(
      database,
      "UPDATE pulp_matches SET status = 'approved', reviewed_at = ? WHERE request_id = ? AND source = ?",
      [now, requestId, source],
    );
    await run(
      database,
      `UPDATE pulp_matches SET status = 'dismissed', reviewed_at = ?
       WHERE request_id = ? AND source != ? AND status = 'suggested'`,
      [now, requestId, source],
    );
    await run(database, "COMMIT");
    return { requestId, source, artifactKind, artifactUrl: match.artifact_url };
  } catch (error) {
    await run(database, "ROLLBACK");
    throw error;
  }
}

async function dismissPulpMatch(database, requestId, source) {
  const result = await run(
    database,
    `UPDATE pulp_matches SET status = 'dismissed', reviewed_at = ?
     WHERE request_id = ? AND source = ? AND status = 'suggested'`,
    [new Date().toISOString(), requestId, source],
  );
  return Boolean(result.changes);
}

module.exports = {
  DEFAULT_RPM_BASE_URL,
  DEFAULT_WHEEL_BASE_URL,
  approvePulpMatch,
  dismissPulpMatch,
  getPulpOverview,
  normalizeForMatch,
  parseRpmMetadata,
  parseWheelIndex,
  syncPulp,
};
