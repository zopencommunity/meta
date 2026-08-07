#!/usr/bin/env node
const { initializeDatabase, openDatabase } = require("./server");
const { syncPulp } = require("./pulp_sync");

async function main() {
  const database = openDatabase(process.env.DATABASE_PATH || "db/package_requests.db");
  try {
    await initializeDatabase(database);
    const result = await syncPulp({ database });
    console.log(`Pulp sync ${result.status}: ${result.artifactsSeen} artifacts, ${result.matchesFound} matches`);
  } finally {
    await new Promise((resolve, reject) => database.close((error) => error ? reject(error) : resolve()));
  }
}

main().catch((error) => {
  console.error(`Pulp sync failed: ${error.message || error}`);
  process.exitCode = 1;
});
