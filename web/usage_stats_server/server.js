const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cron = require('node-cron');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.set('view engine', 'ejs');
app.set('views', __dirname);

// SQLite Database
const db = new sqlite3.Database('db/package_stats.db');

// Create tables if not exists
db.run(`
  CREATE TABLE IF NOT EXISTS removals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    packagename TEXT,
    version TEXT,
    timestamp INTEGER
  )
`);

db.run(`
  CREATE TABLE IF NOT EXISTS installs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    packagename TEXT,
    version TEXT,
    isUpgrade BOOLEAN,
    isBuildInstall BOOLEAN,
    isRuntimeDependencyInstall BOOLEAN,
    timestamp INTEGER
  )
`);

db.run(`
  CREATE TABLE IF NOT EXISTS profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    isbot BOOLEAN,
    isibm BOOLEAN
  )
`);

// API Endpoint to handle incoming data
app.post('/statistics', async (req, res) => {
  try {
    const { type, data } = req.body;

    if (!type || !data) {
      throw new Error('Invalid request format');
    }

    console.log('Received data:', { type, data });

    switch (type) {
      case 'removals':
      case 'installs':
      case 'profiles':
        const isDuplicate = await checkDuplicateEntry(type, data);
        if (isDuplicate) {
          console.error('Duplicate entry:', data);
          throw new Error('Duplicate entry');
        }

        await insertData(type, data);
        console.log(`Inserted into ${type} table:`, data);
        break;

      default:
        console.error('Invalid data type:', type);
        throw new Error('Invalid data type');
    }

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Error:', error.message);
    if (error.message === 'Duplicate entry') {
      res.status(400).json({ error: 'Duplicate entry' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

async function checkDuplicateEntry(type, data) {
  return new Promise((resolve, reject) => {
    let query;

    switch (type) {
      case 'removals':
        query = `SELECT COUNT(*) as count FROM ${type} WHERE uuid = ? AND packagename = ? AND version = ?`;
        db.get(query, [data.uuid, data.packagename, data.version], (err, result) => {
          if (err) {
            reject(err);
          } else {
            resolve(result.count > 0);
          }
        });
        break;

      case 'installs':
        query = `SELECT COUNT(*) as count FROM ${type} WHERE uuid = ? AND packagename = ? AND version = ?`;
        db.get(query, [data.uuid, data.packagename, data.version], (err, result) => {
          if (err) {
            reject(err);
          } else {
            resolve(result.count > 0);
          }
        });
        break;

      case 'profiles':
        query = `SELECT COUNT(*) as count FROM ${type} WHERE uuid = ?`;
        db.get(query, [data.uuid], (err, result) => {
          if (err) {
            reject(err);
          } else {
            resolve(result.count > 0);
          }
        });
        break;

      default:
        reject(new Error('Invalid data type'));
    }
  });
}

async function insertData(type, data) {
  return new Promise((resolve, reject) => {
    let insertQuery, values;
    switch (type) {
      case 'removals':
        insertQuery = 'INSERT INTO removals (uuid, packagename, version, timestamp) VALUES (?, ?, ?, ?)';
        values = [data.uuid, data.packagename, data.version, data.timestamp];
        break;

      case 'installs':
        insertQuery = 'INSERT INTO installs (uuid, packagename, version, isUpgrade, isBuildInstall, isRuntimeDependencyInstall, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?)';
        values = [data.uuid, data.packagename, data.version, data.isUpgrade, data.isBuildInstall, data.isRuntimeDependencyInstall, data.timestamp];
        break;

      case 'profiles':
        insertQuery = 'INSERT INTO profiles (uuid, isbot, isibm) VALUES (?, ?, ?)';
        values = [data.uuid, data.isbot, data.isibm];
        break;

      default:
        reject(new Error('Invalid data type'));
        return;
    }

    db.run(insertQuery, values, function (err) {
      if (err) {
        reject(new Error('Database error: ' + err.message));
      } else {
        resolve();
      }
    });
  });
}

// Serve HTML Page with Dynamic Data
app.get('/', async (req, res) => {
  try {
    const rankedInstalls = await getRankedInstalls();
    const removals = await getTableData('removals');
    const installs = await getTableData('installs');
    const profiles = await getTableData('profiles');

    const data = { rankedInstalls, removals, installs, profiles };

    const totalDownloadsPerMonth = getDownloadsPerMonth(installs);

    res.render('index', { data, totalDownloadsPerMonth});
  } catch (error) {
    console.error('Error:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Route to fetch statistics for a specific port
app.get('/statistics/:port', async (req, res) => {
  const port = req.params.port;

  try {
    const installs = await getInstallsByPort(port);

    const totalDownloads = installs.reduce((sum, install) => sum + install.installs, 0);

    const downloadsPerMonth = getDownloadsPerMonth(installs);

    res.render('port_statistics', {
      port,
      totalDownloads,
      downloadsPerMonth,
    });
  } catch (error) {
    console.error('Database error:', error.message);
    res.status(500).send('Internal server error');
  }
});

async function getInstallsByPort(port) {
  return new Promise(async (resolve, reject) => {
    try {
      const query = 'SELECT * FROM installs WHERE packagename = ?';
      db.all(query, [port], async (err, installs) => {
        if (err) {
          reject(err);
        } else {
          const profile = await getProfileByPort(port);

          const botInstalls = profile.isBot ? installs.filter((install) => install.isBot).length : 0;
          const buildInstalls = installs.filter((install) => install.isBuildInstall).length;

          const netInstalls = installs.map((install) => ({
            timestamp: install.timestamp,
            installs: install.installs - botInstalls - buildInstalls,
            installsWithBuild: install.installs - botInstalls,
            installsWithBuildAndBot: install.installs,
          }));

          resolve(netInstalls);
        }
      });
    } catch (error) {
      reject(error);
    }
  });
}

async function getProfileByPort(port) {
  return new Promise((resolve, reject) => {
    const query = 'SELECT * FROM profiles WHERE uuid = ?';
    db.get(query, [port], (err, profile) => {
      if (err) {
        reject(err);
      } else {
        resolve(profile || {}); // Return an empty object if profile is not found
      }
    });
  });
}

async function getRankedInstalls() {
  return new Promise(async (resolve, reject) => {
    try {
      // Fetch counts of isBuildInstall installs
      const buildInstalls = await getCountByCriteria('installs', 'isBuildInstall', true);

      // Fetch ranked installs including isBot installs
      const rankedInstalls = await new Promise((resolve, reject) => {
        db.all(`
          SELECT i.packagename, COUNT(*) as installs
          FROM installs i
          LEFT JOIN profiles p ON i.uuid = p.uuid
	  WHERE p.isbot is not true
          GROUP BY i.packagename
          ORDER BY installs DESC
        `, async (err, installs) => {
          if (err) {
            reject(err);
          } else {
            // Fetch counts of isBot installs
            const botInstalls = await getCountByCriteria('installs', 'isBot', true);


            const netInstalls = installs.map((install) => {
              const buildCount = buildInstalls.get(install.packagename) || 0;
              const botCount = botInstalls.get(install.packagename) || 0;

              console.log(`Package: ${install.packagename}, Installs: ${install.installs}, BuildCount: ${buildCount}, BotCount: ${botCount}`);

              return {
                packagename: install.packagename,
                installs: install.installs,
                totalDownloads: install.installs,
                botDownloads: botCount,
                buildDownloads: buildCount,
                totalWithBotAndBuild: install.installs + botCount + buildCount,
              };
            });

            resolve(netInstalls);
          }
        });
      });

      resolve(rankedInstalls);
    } catch (error) {
      reject(error);
    }
  });
}


function getDownloadsPerMonth(installs) {
  const downloadsPerMonth = {};

  installs.forEach((install) => {
    const date = new Date(install.timestamp * 1000);
    const yearMonth = `${date.getFullYear()}/${date.getMonth() + 1}`;

    if (downloadsPerMonth[yearMonth]) {
      downloadsPerMonth[yearMonth]++;
    } else {
      downloadsPerMonth[yearMonth] = 1;
    }
  });

  return downloadsPerMonth;
}


async function getCountByCriteria(tableName, columnName, criteria, port) {
  return new Promise((resolve, reject) => {
    let query;
    let params;

    if (port) {
      query = `SELECT packagename, COUNT(*) as count FROM ${tableName} WHERE ${columnName} = ? AND packagename = ? GROUP BY packagename`;
      params = [criteria, port];
    } else {
      if (columnName === 'isBot') {
        query = `
          SELECT i.packagename, COUNT(*) as count
          FROM ${tableName} i
          LEFT JOIN profiles p ON i.uuid = p.uuid
          WHERE IFNULL(p.isbot, 0) = ?
          GROUP BY i.packagename
        `;
      } else {
        query = `SELECT packagename, COUNT(*) as count FROM ${tableName} WHERE ${columnName} = ? GROUP BY packagename`;
      }

      params = [criteria];
    }

    db.all(query, params, (err, counts) => {
      if (err) {
        reject(err);
      } else {
        const countMap = new Map(counts.map((count) => [count.packagename, count.count]));
        resolve(countMap);
      }
    });
  });
}


async function getTableData(tableName) {
  return new Promise((resolve, reject) => {
    db.all(`SELECT * FROM ${tableName}`, (err, data) => {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    });
  });
}

// Route to fetch profile statistics for a specific UUID
app.get('/profile/:uuid', async (req, res) => {
  const uuid = req.params.uuid;

  try {
    const profile = await getProfileByUUID(uuid);

    const installs = await getInstallsByUUID(uuid);

    const totalDownloads = installs.reduce((sum, install) => sum + install.installs, 0);

    res.render('profile_statistics', {
      serverName: 'Your Server Name', 
      data: {
        profile,
        installs: installs,
      },
    });
  } catch (error) {
    console.error('Database error:', error.message);
    res.status(500).send('Internal server error');
  }
});

async function getInstallsByUUID(uuid) {
  return new Promise((resolve, reject) => {
    const query = 'SELECT * FROM installs WHERE uuid = ?';
    db.all(query, [uuid], (err, installs) => {
      if (err) {
        reject(err);
      } else {
        resolve(installs);
      }
    });
  });
}

async function getProfileByUUID(uuid) {
  return new Promise((resolve, reject) => {
    const query = 'SELECT * FROM profiles WHERE uuid = ?';
    db.get(query, [uuid], (err, profile) => {
      if (err) {
        reject(err);
      } else {
        resolve(profile || {}); 
      }
    });
  });
}

// Serve package.db file
app.get('/download/package.db', (req, res) => {
  const packageDbPath = path.join(__dirname, 'db/package_stats.db'); 

  // Check if the file exists
  if (fs.existsSync(packageDbPath)) {
    res.setHeader('Content-Disposition', 'attachment; filename=package.db');
    res.sendFile(packageDbPath);
  } else {
    res.status(404).send('File not found');
  }
});

// Backup the database daily
cron.schedule('0 0 * * *', async () => {
  try {
    const timestamp = new Date().toISOString().replace(/[-T:]/g, '').split('.')[0];
    const backupFileName = `backup_${timestamp}.db`;
    const backupFilePath = path.join(__dirname, 'backups', backupFileName);

    const backupDb = new sqlite3.Database(backupFilePath);
    await new Promise((resolve, reject) => {
      db.backup(backupDb, (err) => {
        if (err) {
          console.error('Database backup error:', err.message);
          reject(err);
        } else {
          console.log(`Database backed up to: ${backupFilePath}`);
          resolve();
        }

        backupDb.close();
      });
    });
  } catch (error) {
    console.error('Backup error:', error.message);
  }
});


// Start Server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

