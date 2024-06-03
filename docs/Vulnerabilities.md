# Package Vulnerabilities

## caddy

<details>
<summary>caddy (Build 2215) - (STABLE) -- 1 medium vulnerability</summary>

- **(MEDIUM severity) CVE-2022-29718**: Caddy v2.4 was discovered to contain an open redirect vulnerability. A remote unauthenticated attacker may exploit this vulnerability to redirect users to arbitrary web URLs by tricking the victim users to click on crafted links.

</details>

## logrotate

<details>
<summary>logrotate (Build 2172) - (STABLE) -- 1 medium vulnerability</summary>

- **(MEDIUM severity) CVE-2022-1348**: A vulnerability was found in logrotate in how the state file is created. The state file is used to prevent parallel executions of multiple instances of logrotate by acquiring and releasing a file lock. When the state file does not exist, it is created with world-readable permission, allowing an unprivileged user to lock the state file, stopping any rotation. This flaw affects logrotate versions before 3.20.0.

</details>

## grafana

<details>
<summary>grafana (Build 2266) - (STABLE) -- 2 vulnerabilities (1 critical, 1 high)</summary>

- **(CRITICAL severity) CVE-2018-15727**: Grafana 2.x, 3.x, and 4.x before 4.6.4 and 5.x before 5.2.3 allows authentication bypass because an attacker can generate a valid "remember me" cookie knowing only a username of an LDAP or OAuth user.
- **(HIGH severity) CVE-2020-13379**: The avatar feature in Grafana 3.0.1 through 7.0.1 has an SSRF Incorrect Access Control issue. This vulnerability allows any unauthenticated user/client to make Grafana send HTTP requests to any URL and return its result to the user/client. This can be used to gain information about the network that Grafana is running on. Furthermore, passing invalid URL objects could be used for DOS'ing Grafana via SegFault.

</details>

