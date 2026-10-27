<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { withBase } from "vitepress";

interface Command {
  code: string;
  note?: string;
}

interface Step {
  id: string;
  title: string;
  why: string;
  commands: Command[];
  expected?: string;
  tip?: string;
}

interface Track {
  id: "rpm" | "python";
  label: string;
  tagline: string;
  intro: string;
  setupTitle: string;
  setup: Command[];
  setupNote: string;
  steps: Step[];
  reset: string;
}

const tracks: Track[] = [
  {
    id: "rpm",
    label: "RPM packages with dnf5",
    tagline: "Install, inspect, audit and roll back packages with the same tools Linux admins use.",
    intro:
      "zopen publishes signed RPM packages that install under /opt/pkg and are tracked in a single RPM database. You manage them with dnf5 and rpm.",
    setupTitle: "Before you start",
    setup: [
      {
        code: `export PATH="/opt/pkg/bin:$PATH"
export LIBPATH="/opt/pkg/lib:$LIBPATH"
dnf5 --version`,
        note: "dnf5 should report 5.4.4.0 or later.",
      },
    ],
    setupNote:
      "You need a superuser (UID 0) shell and dnf5 configured for the zopen repository. If you haven't done that yet, follow the RPM setup guide first.",
    steps: [
      {
        id: "tooling",
        title: "Show the tooling",
        why: "Confirm dnf5 and rpm are on your PATH and that the zopen repository is configured.",
        commands: [{ code: `dnf5 --version
rpm --version
dnf5 repo list` }],
        expected: `dnf5 version 5.4.5.0
RPM version 6.1.0
repo id    repo name
zopen      zopen`,
      },
      {
        id: "browse",
        title: "Browse the catalog",
        why: "The zopen repository has about 150 packages: compilers, build tools, editors and Python libraries.",
        commands: [{ code: `dnf5 list --available
dnf5 search jq
dnf5 info jq` }],
        expected: `Matched fields: name (exact), summary
 jq.s390x	jq-1.8.2 package`,
      },
      {
        id: "install",
        title: "Install a package and use it",
        why: "dnf5 downloads the package, checks its GPG signature and installs it under /opt/pkg.",
        commands: [{ code: `dnf5 install jq
command -v jq
echo '{"platform":"z/OS"}' | jq .platform` }],
        expected: `Complete!
/opt/pkg/bin/jq
"z/OS"`,
        tip: "On your first install, dnf5 asks you to import the zopen signing key. Answer y.",
      },
      {
        id: "inspect",
        title: "Inspect it with rpm",
        why: "Every installed file is recorded, so you can see what a package installed and which package owns a file.",
        commands: [{ code: `rpm -qi jq
rpm -ql jq
rpm -qf /opt/pkg/bin/jq` }],
        expected: `Name         : jq
Version      : 1.8.2
...
/opt/pkg/bin/jq
...
jq-1.8.2-20260917.090316.s390x`,
      },
      {
        id: "integrity",
        title: "Check security and integrity",
        why: "Packages are signed by the zopen key, and rpm -V checks installed files against the RPM database.",
        commands: [{ code: `rpm -q gpg-pubkey
rpm -V jq && echo "jq is unmodified"` }],
        expected: `gpg-pubkey-c1a01d8a583e1a6a72bf8ac06eba60492f343463-6715f337
jq is unmodified`,
        tip: "rpm -V prints nothing when every file matches. Any changed file is listed with a code showing what changed.",
      },
      {
        id: "deps",
        title: "See dependency resolution",
        why: "dnf5 works out everything a package needs. git, for example, pulls in coreutils, perl, ncurses, less and libiconv.",
        commands: [{ code: `dnf5 install git`, note: "Answer N to see the plan without installing, or y to install." }],
        expected: `Installing:
 git        s390x  2.55.0-...   zopen   218.1 MiB
Installing dependencies:
 coreutils  s390x  9.11-...     zopen   142.5 MiB
 less       s390x  710-...      zopen     4.5 MiB
 libiconv   s390x  1.19-...     zopen     4.7 MiB
 ncurses    s390x  6.6-...      zopen    24.7 MiB
 perl       s390x  5.44.0-...   zopen    88.0 MiB`,
      },
      {
        id: "audit",
        title: "Review the audit trail",
        why: "Every transaction records who made the change, when, the exact command, and RPM database fingerprints from before and after.",
        commands: [{ code: `dnf5 history list
dnf5 history info last` }],
        expected: `ID Command line          Date and time       Action(s) Altered
 3 dnf5 install jq       2026-10-27 02:01:06                 1
...
User           : 0 <BPXROOT>
Status         : Ok`,
      },
      {
        id: "rollback",
        title: "Undo and roll back",
        why: "Return the system to a known state without manual cleanup.",
        commands: [
          { code: `dnf5 history undo last
rpm -q jq`, note: "Reverses the last transaction." },
          { code: `dnf5 install jq ripgrep
dnf5 history list
dnf5 history rollback <ID>`, note: "Replace <ID> with an earlier transaction ID from the list." },
        ],
        expected: `package jq is not installed`,
      },
    ],
    reset: `dnf5 remove jq ripgrep git`,
  },
  {
    id: "python",
    label: "Python packages with pip",
    tagline: "Install z/OS-native Python wheels, including compiled extensions, from the zopen index.",
    intro:
      "PyPI has no z/OS wheels, so packages with compiled code won't build there. The zopen wheel index provides them, and its constraints file keeps installs on current, patched versions.",
    setupTitle: "Configure pip for the zopen index",
    setup: [
      {
        code: `export PIP_EXTRA_INDEX_URL="https://repo.zopen.community/pypi/wheels/simple/"
export PIP_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"
export PIP_CACHE_DIR=/tmp/pip-cache
export PIP_CERT="$ZOPEN_CA"`,
        note: "Add these to your .profile to make them permanent.",
      },
    ],
    setupNote:
      "You need IBM Open Enterprise SDK for Python 3.12 or later, and a zopen environment for bash and the CA bundle ($ZOPEN_CA). Run the tutorial in bash: venv activate scripts don't work in /bin/sh. Keep the pip cache off small filesystems such as /u.",
    steps: [
      {
        id: "tooling",
        title: "Show the setup",
        why: "Confirm which Python interpreter you're using and that pip points at the zopen index.",
        commands: [{ code: `bash
python3 -VV
env | grep ^PIP_` }],
        expected: `IBM Open Enterprise SDK for Python 3.14.7 ...
PIP_EXTRA_INDEX_URL=https://repo.zopen.community/pypi/wheels/simple/
PIP_CONSTRAINT=https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt
...`,
      },
      {
        id: "venv",
        title: "Create an isolated environment",
        why: "A virtual environment keeps the tutorial's packages separate from the interpreter's bundled ones.",
        commands: [{ code: `mkdir -p ~/pydemo && cd ~/pydemo
python3 -m venv .venv
source .venv/bin/activate
command -v python` }],
        expected: `/u/you/pydemo/.venv/bin/python`,
        tip: "Compiled extensions are large on z/OS. Budget about 100 MB per environment, and create it on a filesystem with room.",
      },
      {
        id: "native",
        title: "Install a package with native code",
        why: "cryptography has a compiled extension and depends on cffi. Both come prebuilt from the zopen index.",
        commands: [{ code: `pip install cryptography
python -c "from cryptography.hazmat.primitives import hashes; h=hashes.Hash(hashes.SHA256()); h.update(b'hello z/OS'); print(h.finalize().hex())"` }],
        expected: `Successfully installed cffi-2.0.0 cryptography-50.0.0 pycparser-2.20
6dc1a19e0cb5f3f43c310e992f8a276fb884d826639af9f6f6b8c3fbbba038e2`,
        tip: "Importing the top-level package doesn't prove the extension loads. Hashing something exercises the compiled code.",
      },
      {
        id: "datasci",
        title: "Run the data science stack",
        why: "numpy and pandas run on z/OS from prebuilt wheels.",
        commands: [{ code: `pip install pandas
python -c "
import pandas as pd
df = pd.DataFrame({'lpar':['PROD','TEST','DEV'], 'cpu':[72.5,31.0,12.4]})
print(df.sort_values('cpu', ascending=False))
print('mean cpu:', df.cpu.mean())"` }],
        expected: `   lpar   cpu
0  PROD  72.5
1  TEST  31.0
2   DEV  12.4
mean cpu: 38.63333333333333`,
      },
      {
        id: "inspect",
        title: "Inspect the environment",
        why: "See exactly what's installed and where it came from.",
        commands: [{ code: `pip list
pip show cryptography` }],
        expected: `Package         Version
--------------- -------
cffi            2.0.0
cryptography    50.0.0
numpy           2.5.2
pandas          3.0.5
...`,
      },
      {
        id: "ruff",
        title: "Add developer tooling",
        why: "ruff, the Rust-based Python linter, runs natively on z/OS.",
        commands: [{ code: `pip install ruff
printf 'import os\\nprint("hi")\\n' > lint_me.py
ruff check lint_me.py` }],
        expected: `I001 [*] Import block is un-sorted or un-formatted
 --> lint_me.py:1:1
...
F401 [*] \`os\` imported but unused
 --> lint_me.py:1:8
...
Found 2 errors.
[*] 2 fixable with \`--fix\`.`,
      },
      {
        id: "reproduce",
        title: "Rebuild the same environment elsewhere",
        why: "Pin every version so a second environment is identical to the first.",
        commands: [{ code: `pip freeze > requirements.txt
cat requirements.txt
deactivate
python3 -m venv fresh
fresh/bin/pip install -r requirements.txt` }],
        expected: `cffi==2.0.0
cryptography==50.0.0
numpy==2.5.2
...
Successfully installed cffi-2.0.0 cryptography-50.0.0 numpy-2.5.2 pandas-3.0.5 ...`,
      },
      {
        id: "constraints",
        title: "See why the constraints file matters",
        why: "The interpreter bundles cryptography 3.3.2, a 2021 release with known CVEs. Without constraints, pip reports \"already satisfied\" and keeps it.",
        commands: [
          { code: `python3 -m venv --system-site-packages old
PIP_CONSTRAINT= old/bin/pip install cryptography
old/bin/python -c "import cryptography; print(cryptography.__version__)"`, note: "Without constraints, the old version stays." },
          { code: `old/bin/pip install cryptography
old/bin/python -c "import cryptography; print(cryptography.__version__)"`, note: "With constraints, pip upgrades." },
        ],
        expected: `Requirement already satisfied: cryptography ...
3.3.2
Successfully installed cffi-2.0.0 cryptography-50.0.0
50.0.0`,
      },
    ],
    reset: `cd ~/pydemo && rm -rf .venv fresh old requirements.txt lint_me.py`,
  },
];

const STORAGE_KEY = "zopen-packages-tutorial";
const activeId = ref<Track["id"]>("rpm");
const done = ref<Record<string, boolean>>({});
const openExpected = ref<Record<string, boolean>>({});
const copied = ref("");

const active = computed(() => tracks.find((t) => t.id === activeId.value)!);
const key = (trackId: string, stepId: string) => `${trackId}:${stepId}`;
const doneCount = computed(
  () => active.value.steps.filter((s) => done.value[key(active.value.id, s.id)]).length
);
const progress = computed(() => Math.round((doneCount.value / active.value.steps.length) * 100));

onMounted(() => {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
    if (saved.done) done.value = saved.done;
    if (saved.active === "rpm" || saved.active === "python") activeId.value = saved.active;
  } catch {
    /* storage unavailable: start fresh */
  }
  const hash = window.location.hash.replace("#", "");
  if (hash === "rpm" || hash === "python") activeId.value = hash;
});

watch(
  [done, activeId],
  () => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({ done: done.value, active: activeId.value }));
    } catch {
      /* ignore */
    }
  },
  { deep: true }
);

function selectTrack(id: Track["id"]) {
  activeId.value = id;
  history.replaceState(null, "", `#${id}`);
}

function toggleDone(stepId: string) {
  const k = key(activeId.value, stepId);
  done.value = { ...done.value, [k]: !done.value[k] };
}

function resetProgress() {
  const prefix = `${activeId.value}:`;
  done.value = Object.fromEntries(Object.entries(done.value).filter(([k]) => !k.startsWith(prefix)));
}

async function copy(text: string, id: string) {
  try {
    await navigator.clipboard.writeText(text);
  } catch {
    const el = document.createElement("textarea");
    el.value = text;
    document.body.appendChild(el);
    el.select();
    document.execCommand("copy");
    el.remove();
  }
  copied.value = id;
  setTimeout(() => {
    if (copied.value === id) copied.value = "";
  }, 1600);
}
</script>

<template>
  <div class="tutorial">
    <header class="intro">
      <p class="eyebrow">Hands-on tutorial</p>
      <h1>Package management on z/OS</h1>
      <p class="intro-copy">
        Two short tracks, eight steps each. Work through them in a z/OS UNIX shell, copy each command,
        compare with the expected output, and tick the step off. Your progress is saved in this browser.
      </p>
    </header>

    <div class="tabs" role="tablist" aria-label="Tutorial track">
      <button
        v-for="t in tracks"
        :key="t.id"
        role="tab"
        :aria-selected="t.id === activeId"
        :class="['tab', { active: t.id === activeId }]"
        @click="selectTrack(t.id)"
      >
        <span class="tab-label">{{ t.label }}</span>
        <span class="tab-tagline">{{ t.tagline }}</span>
      </button>
    </div>

    <section class="track" role="tabpanel">
      <p class="track-intro">{{ active.intro }}</p>

      <div class="progress" aria-live="polite">
        <div class="progress-bar"><div class="progress-fill" :style="{ width: progress + '%' }" /></div>
        <span>{{ doneCount }} of {{ active.steps.length }} steps done</span>
        <button v-if="doneCount" class="link-button" @click="resetProgress">Reset</button>
      </div>

      <details class="setup" open>
        <summary>{{ active.setupTitle }}</summary>
        <p>
          {{ active.setupNote }}
          <template v-if="active.id === 'rpm'">
            See the <a :href="withBase('/Guides/RpmSetup')">RPM setup guide</a>.
          </template>
          <template v-else>
            See <a :href="withBase('/Guides/PythonPackages')">Using Python packages</a> for details.
          </template>
        </p>
        <div v-for="(c, i) in active.setup" :key="i" class="command">
          <div class="command-bar">
            <span>{{ c.note }}</span>
            <button @click="copy(c.code, `setup-${active.id}-${i}`)">
              {{ copied === `setup-${active.id}-${i}` ? "Copied" : "Copy" }}
            </button>
          </div>
          <pre><code>{{ c.code }}</code></pre>
        </div>
      </details>

      <ol class="steps">
        <li
          v-for="(s, n) in active.steps"
          :key="s.id"
          :class="['step', { done: done[key(active.id, s.id)] }]"
        >
          <div class="step-head">
            <span class="step-num">{{ n + 1 }}</span>
            <div class="step-title">
              <h2>{{ s.title }}</h2>
              <p>{{ s.why }}</p>
            </div>
            <label class="check">
              <input
                type="checkbox"
                :checked="!!done[key(active.id, s.id)]"
                @change="toggleDone(s.id)"
              />
              <span>Done</span>
            </label>
          </div>

          <div v-for="(c, i) in s.commands" :key="i" class="command">
            <div class="command-bar">
              <span>{{ c.note }}</span>
              <button @click="copy(c.code, `${active.id}-${s.id}-${i}`)">
                {{ copied === `${active.id}-${s.id}-${i}` ? "Copied" : "Copy" }}
              </button>
            </div>
            <pre><code>{{ c.code }}</code></pre>
          </div>

          <p v-if="s.tip" class="tip"><strong>Tip</strong> {{ s.tip }}</p>

          <div v-if="s.expected" class="expected">
            <button
              class="link-button"
              :aria-expanded="!!openExpected[key(active.id, s.id)]"
              @click="openExpected[key(active.id, s.id)] = !openExpected[key(active.id, s.id)]"
            >
              {{ openExpected[key(active.id, s.id)] ? "Hide" : "Show" }} expected output
            </button>
            <pre v-if="openExpected[key(active.id, s.id)]" class="output"><code>{{ s.expected }}</code></pre>
          </div>
        </li>
      </ol>

      <div class="reset-box">
        <div>
          <strong>Start over</strong>
          <p>Clean up what this track installed, so you can run it again.</p>
        </div>
        <div class="command">
          <div class="command-bar">
            <span />
            <button @click="copy(active.reset, `reset-${active.id}`)">
              {{ copied === `reset-${active.id}` ? "Copied" : "Copy" }}
            </button>
          </div>
          <pre><code>{{ active.reset }}</code></pre>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.tutorial { min-width: 0; color: var(--vp-c-text-1); }
.intro { padding: 10px 0 24px; }
.intro h1 { margin: 2px 0 12px; font-size: clamp(2rem, 4vw, 3rem); line-height: 1.08; letter-spacing: -0.03em; }
.eyebrow { margin: 0; color: var(--vp-c-brand-1); font-size: 0.78rem; font-weight: 750; letter-spacing: 0.12em; text-transform: uppercase; }
.intro-copy { max-width: 760px; margin: 0; color: var(--vp-c-text-2); font-size: 1.05rem; line-height: 1.65; }

.tabs { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; margin-bottom: 22px; }
.tab { display: flex; flex-direction: column; gap: 4px; padding: 14px 16px; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg-soft); color: var(--vp-c-text-1); text-align: left; cursor: pointer; transition: border-color 0.15s, background 0.15s; }
.tab:hover { border-color: var(--vp-c-brand-2); }
.tab.active { border-color: var(--vp-c-brand-1); background: var(--vp-c-brand-soft); }
.tab-label { font-weight: 750; font-size: 1rem; }
.tab-tagline { color: var(--vp-c-text-2); font-size: 0.85rem; line-height: 1.45; }

.track-intro { margin: 0 0 16px; color: var(--vp-c-text-2); line-height: 1.65; }

.progress { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; color: var(--vp-c-text-2); font-size: 0.85rem; }
.progress-bar { flex: 1; height: 8px; overflow: hidden; border-radius: 99px; background: var(--vp-c-divider); }
.progress-fill { height: 100%; border-radius: 99px; background: var(--vp-c-brand-1); transition: width 0.25s; }

.setup { margin-bottom: 22px; border: 1px solid var(--vp-c-divider); border-left: 4px solid var(--vp-c-brand-1); border-radius: 10px; background: var(--vp-c-bg-soft); }
.setup summary { padding: 14px 16px; cursor: pointer; font-weight: 700; }
.setup p { margin: 0; padding: 0 16px 12px; color: var(--vp-c-text-2); font-size: 0.92rem; line-height: 1.6; }
.setup .command { padding: 0 16px 16px; }

.steps { margin: 0; padding: 0; list-style: none; counter-reset: none; }
.step { margin: 0 0 16px; padding: 18px; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg); transition: border-color 0.15s, opacity 0.15s; }
.step.done { border-color: var(--vp-c-green-2, var(--vp-c-brand-2)); }
.step.done .step-num { background: var(--vp-c-green-1, var(--vp-c-brand-1)); color: var(--vp-c-white); }
.step-head { display: grid; grid-template-columns: auto minmax(0, 1fr) auto; gap: 14px; align-items: start; margin-bottom: 12px; }
.step-num { display: inline-flex; width: 32px; height: 32px; align-items: center; justify-content: center; border-radius: 50%; background: var(--vp-c-bg-soft); border: 1px solid var(--vp-c-divider); font-weight: 750; font-size: 0.9rem; }
.step-title h2 { margin: 2px 0 4px; padding: 0; border: 0; font-size: 1.12rem; line-height: 1.35; letter-spacing: -0.01em; }
.step-title p { margin: 0; color: var(--vp-c-text-2); font-size: 0.92rem; line-height: 1.55; }
.check { display: inline-flex; align-items: center; gap: 6px; padding: 5px 10px; border: 1px solid var(--vp-c-divider); border-radius: 99px; color: var(--vp-c-text-2); font-size: 0.82rem; font-weight: 650; cursor: pointer; white-space: nowrap; }
.check input { accent-color: var(--vp-c-brand-1); }

.command { min-width: 0; margin-top: 10px; }
.command-bar { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 6px; color: var(--vp-c-text-2); font-size: 0.82rem; }
.command-bar button { border: 1px solid var(--vp-c-divider); border-radius: 7px; padding: 4px 10px; background: var(--vp-c-bg-soft); color: var(--vp-c-text-1); cursor: pointer; font-size: 0.8rem; font-weight: 650; }
.command-bar button:hover { border-color: var(--vp-c-brand-1); }
pre { margin: 0; padding: 12px 14px; overflow-x: auto; border-radius: 8px; background: var(--vp-code-block-bg); font-family: var(--vp-font-family-mono); font-size: 0.82rem; line-height: 1.6; }
pre code { color: var(--vp-code-block-color, var(--vp-c-text-1)); white-space: pre; }
pre.output { margin-top: 8px; border: 1px dashed var(--vp-c-divider); background: var(--vp-c-bg-soft); }
pre.output code { color: var(--vp-c-text-2); }

.tip { margin: 12px 0 0; padding: 10px 12px; border-radius: 8px; background: var(--vp-c-tip-soft, var(--vp-c-bg-soft)); color: var(--vp-c-text-2); font-size: 0.88rem; line-height: 1.55; }
.tip strong { margin-right: 6px; color: var(--vp-c-tip-1, var(--vp-c-brand-1)); }
.expected { margin-top: 10px; }
.link-button { padding: 0; border: 0; background: none; color: var(--vp-c-brand-1); cursor: pointer; font-size: 0.85rem; font-weight: 650; }
.link-button:hover { text-decoration: underline; }

.reset-box { display: grid; grid-template-columns: minmax(180px, 0.6fr) minmax(0, 1.4fr); gap: 16px; align-items: center; margin-top: 8px; padding: 16px; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg-soft); }
.reset-box p { margin: 4px 0 0; color: var(--vp-c-text-2); font-size: 0.88rem; }
.reset-box .command { margin: 0; }

@media (max-width: 640px) {
  .tabs, .reset-box { grid-template-columns: minmax(0, 1fr); }
  .step { padding: 14px; }
  .step-head { grid-template-columns: auto minmax(0, 1fr); }
  .check { grid-column: 2; justify-self: start; }
}
</style>
