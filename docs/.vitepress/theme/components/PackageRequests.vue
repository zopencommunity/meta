<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import { withBase } from "vitepress";

type RequestStatus =
  | "proposed"
  | "under_review"
  | "accepted"
  | "in_progress"
  | "available"
  | "declined";

interface PackageRequest {
  id: number;
  packageName: string;
  ecosystem: string;
  portRepositoryUrl: string;
  artifactKind: string;
  artifactUrl: string;
  maintainerNote: string;
  acknowledgedAt: string | null;
  availableAt: string | null;
  requesterName: string;
  organization: string;
  showRequesterPublicly: boolean;
  upstreamUrl: string;
  description: string;
  useCase: string;
  canHelpTest: boolean;
  status: RequestStatus;
  voteCount: number;
  voted: boolean;
  discussionCount: number;
  ownedByCurrentUser: boolean;
  contactEmail?: string;
  createdAt: string;
}

interface GithubUser {
  id: number;
  login: string;
  avatarUrl: string;
  profileUrl: string;
}

interface ActivityItem {
  id: string | number;
  type: "created" | "status" | "edit" | "post";
  kind?: string;
  body?: string;
  authorRole?: "community" | "maintainer";
  authorName?: string;
  organization?: string;
  fromStatus?: RequestStatus;
  toStatus?: RequestStatus;
  note?: string;
  createdAt: string;
  updatedAt?: string;
  ownedByCurrentUser?: boolean;
}

interface OwnPost extends ActivityItem {
  id: number;
  requestId: number;
  moderationStatus: "pending" | "published" | "hidden";
  contactEmail: string;
  showAuthorPublicly: boolean;
}

interface BulkRow {
  key: number;
  packageName: string;
  ecosystem: string;
  upstreamUrl: string;
  description: string;
  useCase: string;
  canHelpTest: boolean | null;
}

interface BulkRowState {
  kind: "ready" | "existing" | "available" | "duplicate" | "invalid";
  label: string;
  existingRequest?: PackageRequest;
}

const productionApiUrl = "https://usage.zopen.community/package-requests/api";
const configuredApiUrl = String(
  import.meta.env.VITE_PACKAGE_REQUESTS_API_URL || (import.meta.env.PROD ? productionApiUrl : ""),
).replace(/\/$/, "");
const apiUrl = ref(configuredApiUrl);
const requests = ref<PackageRequest[]>([]);
const availablePackages = ref(new Set<string>());
const search = ref("");
const sort = ref<"top" | "newest">("top");
const status = ref("all");
const ecosystem = ref("all");
const loading = ref(true);
const loadError = ref("");
const formOpen = ref(false);
const bulkFormOpen = ref(false);
const submitting = ref(false);
const submitError = ref("");
const successMessage = ref("");
const githubAuthEnabled = ref(false);
const authUser = ref<GithubUser | null>(null);
const authLoading = ref(true);
const authMessage = ref("");
const showMine = ref(false);
const githubOwnedPosts = ref<OwnPost[]>([]);
const editingRequestId = ref<number | null>(null);
const requestEditBusy = ref(false);
const requestEditError = ref("");
const busyVotes = ref(new Set<number>());
const expandedActivity = ref(new Set<number>());
const activityByRequest = reactive<Record<number, ActivityItem[]>>({});
const ownPostsByRequest = reactive<Record<number, OwnPost[]>>({});
const activityBusy = ref(new Set<number>());
const activityErrors = reactive<Record<number, string>>({});
const postFormRequestId = ref<number | null>(null);
const postSubmitting = ref(false);
const postError = ref("");
const postMessage = ref("");
const postFeedbackRequestId = ref<number | null>(null);
const bulkRows = ref<BulkRow[]>([]);
const bulkInput = ref("");
const bulkReviewing = ref(false);
const bulkSubmitting = ref(false);
const bulkError = ref("");
const maxBulkRequests = 25;
let nextBulkRowKey = 1;

const form = reactive({
  packageName: "",
  ecosystem: "",
  upstreamUrl: "",
  description: "",
  useCase: "",
  canHelpTest: false,
  requesterName: "",
  organization: "",
  contactEmail: "",
  showRequesterPublicly: false,
});

const bulkForm = reactive({
  defaultEcosystem: "",
  description: "",
  canHelpTest: false,
  requesterName: "",
  organization: "",
  contactEmail: "",
  showRequesterPublicly: false,
});

const postForm = reactive({
  kind: "use_case",
  body: "",
  authorName: "",
  organization: "",
  contactEmail: "",
  showAuthorPublicly: false,
  website: "",
});

const requestEditForm = reactive({
  packageName: "",
  ecosystem: "",
  upstreamUrl: "",
  description: "",
  useCase: "",
  canHelpTest: false,
  requesterName: "",
  organization: "",
  contactEmail: "",
  showRequesterPublicly: false,
});

const statuses: Record<RequestStatus, { label: string; detail: string }> = {
  proposed: { label: "Proposed", detail: "Gathering community interest" },
  under_review: { label: "Under review", detail: "Being evaluated by maintainers" },
  accepted: { label: "Accepted", detail: "Suitable for the backlog; awaiting or coordinating contributors" },
  in_progress: { label: "In progress", detail: "Someone is working on the port" },
  available: { label: "Available", detail: "The package has been released" },
  declined: { label: "Declined", detail: "Not currently planned" },
};

const ecosystems: Record<string, string> = {
  general: "General / CLI",
  python: "Python / PyPI",
  c_cpp: "C / C++",
  rust: "Rust / Cargo",
  go: "Go module",
  java: "Java / JVM",
  javascript: "JavaScript / npm",
  shell: "Shell",
  other: "Other",
};

const artifactLabels: Record<string, string> = {
  zopen_package: "Installable zopen package",
  pulp_zopen: "zopen Pulp RPM package",
  pulp_python: "Pulp Python package / wheel",
  pypi: "PyPI project",
  python_wheel: "Python wheel",
  pulp_rpm: "Pulp RPM",
  other: "Published package",
};

const postKinds: Record<string, string> = {
  use_case: "Use case",
  testing_offer: "Testing offer",
  contribution_offer: "Contribution offer",
  technical_note: "Technical information",
  question: "Question",
  maintainer_update: "Maintainer update",
};

const filteredRequests = computed(() => {
  const query = search.value.trim().toLowerCase();
  return requests.value.filter((request) => {
    const matchesOwner = !showMine.value || request.ownedByCurrentUser;
    const matchesStatus = status.value === "all" || request.status === status.value;
    const matchesEcosystem = ecosystem.value === "all" || request.ecosystem === ecosystem.value;
    const matchesSearch =
      !query ||
      request.packageName.toLowerCase().includes(query) ||
      request.description.toLowerCase().includes(query) ||
      request.useCase.toLowerCase().includes(query);
    return matchesOwner && matchesStatus && matchesEcosystem && matchesSearch;
  });
});

const totalVotes = computed(() => requests.value.reduce((total, request) => total + request.voteCount, 0));
const availableMatch = computed(() => {
  const normalized = normalizeName(form.packageName);
  return normalized && availablePackages.value.has(normalized);
});
const requestsByName = computed(() => new Map(
  requests.value.map((request) => [normalizeName(request.packageName), request]),
));
const bulkStates = computed(() => bulkRows.value.map((row, index) => getBulkRowState(row, index)));
const readyBulkRows = computed(() => bulkRows.value.filter((row, index) => bulkStates.value[index].kind === "ready"));
const invalidBulkRows = computed(() => bulkStates.value.filter((state) => state.kind === "invalid").length);
const skippedBulkRows = computed(() => bulkStates.value.filter((state) => state.kind !== "ready" && state.kind !== "invalid").length);

function normalizeName(value: string) {
  return value.trim().toLowerCase().replace(/\s+/g, "-").replace(/-?port$/, "");
}

function validPackageName(value: string) {
  return /^[a-zA-Z0-9][a-zA-Z0-9._+\s-]{0,79}$/.test(value.trim());
}

function validHttpUrl(value: string) {
  if (!value) return true;
  try {
    return ["http:", "https:"].includes(new URL(value).protocol);
  } catch {
    return false;
  }
}

function getBulkRowState(row: BulkRow, index: number): BulkRowState {
  if (!validPackageName(row.packageName)) return { kind: "invalid", label: "Invalid package name" };
  if (!Object.hasOwn(ecosystems, row.ecosystem)) return { kind: "invalid", label: "Choose an ecosystem" };
  if (!validHttpUrl(row.upstreamUrl)) return { kind: "invalid", label: "Invalid upstream URL" };
  if ((row.description || bulkForm.description).trim().length < 2) {
    return { kind: "invalid", label: "Add a reason (2+ characters)" };
  }

  const normalized = normalizeName(row.packageName);
  const firstIndex = bulkRows.value.findIndex((candidate) => normalizeName(candidate.packageName) === normalized);
  if (firstIndex !== index) return { kind: "duplicate", label: `Duplicate of row ${firstIndex + 1}` };
  const existingRequest = requestsByName.value.get(normalized);
  if (existingRequest) return { kind: "existing", label: "Already requested", existingRequest };
  if (availablePackages.value.has(normalized)) return { kind: "available", label: "Already available" };
  return { kind: "ready", label: "Ready" };
}

function normalizeEcosystem(value: string, fallback = "") {
  const normalized = value.trim().toLowerCase().replace(/[\s-]+/g, "_");
  if (!normalized) return fallback;
  if (Object.hasOwn(ecosystems, normalized)) return normalized;
  const aliases: Record<string, string> = {
    cli: "general",
    general_cli: "general",
    pypi: "python",
    python_pypi: "python",
    c: "c_cpp",
    cpp: "c_cpp",
    "c++": "c_cpp",
    "c/c++": "c_cpp",
    cargo: "rust",
    rust_cargo: "rust",
    golang: "go",
    go_module: "go",
    jvm: "java",
    java_jvm: "java",
    js: "javascript",
    npm: "javascript",
    javascript_npm: "javascript",
  };
  return aliases[normalized] || normalized;
}

function parseCsv(text: string) {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    if (character === '"') {
      if (quoted && text[index + 1] === '"') {
        field += '"';
        index += 1;
      } else {
        quoted = !quoted;
      }
    } else if (character === "," && !quoted) {
      row.push(field);
      field = "";
    } else if ((character === "\n" || character === "\r") && !quoted) {
      if (character === "\r" && text[index + 1] === "\n") index += 1;
      row.push(field);
      if (row.some((value) => value.trim())) rows.push(row);
      row = [];
      field = "";
    } else {
      field += character;
    }
  }
  row.push(field);
  if (row.some((value) => value.trim())) rows.push(row);
  if (quoted) throw new Error("The CSV contains an unclosed quoted field.");
  return rows;
}

function csvBoolean(value: string): boolean | null {
  const normalized = value.trim().toLowerCase();
  if (!normalized) return null;
  if (["yes", "true", "1", "y"].includes(normalized)) return true;
  if (["no", "false", "0", "n"].includes(normalized)) return false;
  return null;
}

function setBulkRows(rows: Omit<BulkRow, "key">[]) {
  if (!rows.length) throw new Error("Add at least one package name.");
  if (rows.length > maxBulkRequests) {
    throw new Error(`Public bulk submissions are limited to ${maxBulkRequests} packages at a time.`);
  }
  bulkRows.value = rows.map((row) => ({ ...row, key: nextBulkRowKey++ }));
  bulkReviewing.value = true;
  bulkError.value = "";
}

function reviewPastedPackages() {
  bulkError.value = "";
  try {
    const names = bulkInput.value
      .split(/\r?\n/)
      .map((name) => name.trim().replace(/^(?:[-*]\s+|\d+[.)]\s*)/, ""))
      .filter(Boolean);
    setBulkRows(names.map((packageName) => ({
      packageName,
      ecosystem: bulkForm.defaultEcosystem,
      upstreamUrl: "",
      description: "",
      useCase: "",
      canHelpTest: null,
    })));
  } catch (error) {
    bulkError.value = error instanceof Error ? error.message : "The package list could not be read.";
  }
}

async function loadCsv(event: Event) {
  bulkError.value = "";
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  input.value = "";
  if (!file) return;
  if (file.size > 64 * 1024) {
    bulkError.value = "The CSV must be smaller than 64 KB.";
    return;
  }
  try {
    const records = parseCsv(await file.text());
    const headers = (records.shift() || []).map((header) => header
      .replace(/^\uFEFF/, "")
      .trim()
      .toLowerCase()
      .replace(/[\s-]+/g, "_"));
    const packageIndex = headers.findIndex((header) => ["package_name", "package", "name"].includes(header));
    if (packageIndex < 0) throw new Error("The CSV needs a package_name column.");
    const column = (...names: string[]) => headers.findIndex((header) => names.includes(header));
    const ecosystemIndex = column("ecosystem", "project_ecosystem");
    const upstreamIndex = column("upstream_url", "upstream", "project_url");
    const descriptionIndex = column("description", "reason", "rationale");
    const useCaseIndex = column("use_case", "usecase", "version_or_use_case");
    const testerIndex = column("tester_available", "can_help_test", "help_test");
    const valueAt = (record: string[], index: number) => index < 0 ? "" : String(record[index] || "").trim();
    setBulkRows(records.map((record) => ({
      packageName: valueAt(record, packageIndex),
      ecosystem: normalizeEcosystem(valueAt(record, ecosystemIndex), bulkForm.defaultEcosystem),
      upstreamUrl: valueAt(record, upstreamIndex),
      description: valueAt(record, descriptionIndex),
      useCase: valueAt(record, useCaseIndex),
      canHelpTest: csvBoolean(valueAt(record, testerIndex)),
    })));
  } catch (error) {
    bulkError.value = error instanceof Error ? error.message : "The CSV could not be read.";
  }
}

function downloadCsvTemplate() {
  const csv = "package_name,ecosystem,upstream_url,description,use_case,tester_available\n" +
    'ripgrep,rust,https://github.com/BurntSushi/ripgrep,"Fast recursive search on z/OS",,yes\n';
  const link = document.createElement("a");
  link.href = URL.createObjectURL(new Blob([csv], { type: "text/csv" }));
  link.download = "zopen-package-requests-template.csv";
  link.click();
  URL.revokeObjectURL(link.href);
}

function getVoterId() {
  const storageKey = "zopen-package-request-voter-id";
  let voterId = localStorage.getItem(storageKey);
  if (!voterId) {
    voterId = crypto.randomUUID();
    localStorage.setItem(storageKey, voterId);
  }
  return voterId;
}

function getPostTokens(): Record<string, string> {
  try {
    return JSON.parse(localStorage.getItem("zopen-package-post-edit-tokens") || "{}");
  } catch {
    return {};
  }
}

function savePostToken(postId: number, token: string) {
  const tokens = getPostTokens();
  tokens[String(postId)] = token;
  localStorage.setItem("zopen-package-post-edit-tokens", JSON.stringify(tokens));
}

function removePostToken(postId: number) {
  const tokens = getPostTokens();
  delete tokens[String(postId)];
  localStorage.setItem("zopen-package-post-edit-tokens", JSON.stringify(tokens));
}

function postToken(postId: string | number) {
  return typeof postId === "number" ? getPostTokens()[String(postId)] || "" : "";
}

function textSegments(value = "") {
  const segments: Array<{ text: string; url?: string }> = [];
  const pattern = /https?:\/\/[^\s<>]+/gi;
  let position = 0;
  for (const match of value.matchAll(pattern)) {
    if (match.index! > position) segments.push({ text: value.slice(position, match.index) });
    let url = match[0];
    const punctuation = url.match(/[),.;!?]+$/)?.[0] || "";
    if (punctuation) url = url.slice(0, -punctuation.length);
    segments.push({ text: url, url });
    if (punctuation) segments.push({ text: punctuation });
    position = match.index! + match[0].length;
  }
  if (position < value.length) segments.push({ text: value.slice(position) });
  return segments;
}

function statusLabel(value?: RequestStatus) {
  return value ? statuses[value]?.label || value : "Unknown";
}

function displayDate(value: string) {
  return new Date(value).toLocaleString(undefined, { dateStyle: "medium", timeStyle: "short" });
}

async function apiRequest(path: string, options: RequestInit = {}) {
  if (!apiUrl.value) throw new Error("The package request service has not been configured yet.");
  const headers = new Headers(options.headers);
  headers.set("Content-Type", "application/json");
  headers.set("X-Voter-ID", getVoterId());
  const response = await fetch(`${apiUrl.value}${path}`, { ...options, headers, credentials: "include" });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    const error = new Error(body.error || "The request could not be completed.");
    Object.assign(error, body);
    throw error;
  }
  return body;
}

function mergeOwnedRequests(ownedRequests: PackageRequest[]) {
  const merged = new Map(requests.value.map((request) => [request.id, request]));
  for (const request of ownedRequests) merged.set(request.id, { ...merged.get(request.id), ...request });
  requests.value = [...merged.values()];
}

async function loadAuthentication() {
  authLoading.value = true;
  try {
    const config = await apiRequest("/auth/config");
    githubAuthEnabled.value = Boolean(config.githubEnabled);
    if (!githubAuthEnabled.value) return;
    const result = await apiRequest("/auth/me");
    authUser.value = result.user || null;
    if (authUser.value) {
      try {
        await apiRequest("/me/votes/claim", {
          method: "POST",
          body: JSON.stringify({ voterId: getVoterId() }),
        });
      } catch {
        // Voting still works; a later sign-in can retry claiming this browser's guest votes.
      }
      await loadRequests();
    }
  } catch {
    githubAuthEnabled.value = false;
    authUser.value = null;
  } finally {
    authLoading.value = false;
  }
}

async function loadMySubmissions() {
  if (!authUser.value) return;
  const result = await apiRequest("/me/submissions");
  mergeOwnedRequests(result.requests || []);
  githubOwnedPosts.value = result.posts || [];
}

function signInWithGithub() {
  window.location.assign(`${apiUrl.value}/auth/github`);
}

async function signOut() {
  await apiRequest("/auth/logout", { method: "POST", body: "{}" });
  authUser.value = null;
  githubOwnedPosts.value = [];
  showMine.value = false;
  editingRequestId.value = null;
  await loadRequests();
}

async function loadRequests() {
  loading.value = true;
  loadError.value = "";
  try {
    const result = await apiRequest(`/requests?sort=${sort.value}`);
    requests.value = result.requests;
    if (authUser.value) await loadMySubmissions();
  } catch (error) {
    loadError.value = error instanceof Error ? error.message : "The package requests could not be loaded.";
  } finally {
    loading.value = false;
  }
}

async function loadAvailablePackages() {
  try {
    const response = await fetch(withBase("/api/zopen_releases_descriptions.json"));
    if (!response.ok) return;
    const data = await response.json();
    availablePackages.value = new Set(
      Object.keys(data.descriptions || {}).map((packageName) => normalizeName(packageName)),
    );
  } catch {
    // This hint is optional; a failure should not prevent package submissions.
  }
}

async function loadOwnPosts(requestId: number) {
  const tokens = getPostTokens();
  const posts: OwnPost[] = [];
  await Promise.all(Object.entries(tokens).map(async ([postId, token]) => {
    try {
      const result = await apiRequest(`/posts/${postId}`, { headers: { "X-Edit-Token": token } });
      if (result.post.requestId === requestId) posts.push(result.post);
    } catch {
      // Keep the browser-held secret through temporary network or service failures.
    }
  }));
  const combined = new Map<number, OwnPost>();
  for (const post of githubOwnedPosts.value.filter((item) => item.requestId === requestId)) combined.set(post.id, post);
  for (const post of posts) combined.set(post.id, post);
  ownPostsByRequest[requestId] = [...combined.values()].sort((left, right) => right.createdAt.localeCompare(left.createdAt));
}

async function loadActivity(requestId: number) {
  activityErrors[requestId] = "";
  activityBusy.value = new Set(activityBusy.value).add(requestId);
  try {
    const [result] = await Promise.all([
      apiRequest(`/requests/${requestId}/activity`),
      loadOwnPosts(requestId),
    ]);
    activityByRequest[requestId] = result.activity;
  } catch (error) {
    activityErrors[requestId] = error instanceof Error ? error.message : "The activity could not be loaded.";
  } finally {
    const next = new Set(activityBusy.value);
    next.delete(requestId);
    activityBusy.value = next;
  }
}

function toggleActivity(requestId: number) {
  const next = new Set(expandedActivity.value);
  if (next.has(requestId)) {
    next.delete(requestId);
    if (postFormRequestId.value === requestId) postFormRequestId.value = null;
  } else {
    next.add(requestId);
    void loadActivity(requestId);
  }
  expandedActivity.value = next;
}

function ownUnpublishedPosts(requestId: number) {
  return (ownPostsByRequest[requestId] || []).filter((post) => post.moderationStatus !== "published");
}

function resetPostForm() {
  postForm.kind = "use_case";
  postForm.body = "";
  postForm.authorName = "";
  postForm.organization = "";
  postForm.contactEmail = "";
  postForm.showAuthorPublicly = false;
  postForm.website = "";
  postError.value = "";
}

function openPostForm(requestId: number) {
  resetPostForm();
  postFormRequestId.value = requestId;
  postFeedbackRequestId.value = requestId;
  postMessage.value = "";
  requestAnimationFrame(() => document.querySelector<HTMLElement>(`#community-post-${requestId} textarea`)?.focus());
}

async function submitCommunityPost(requestId: number) {
  postFeedbackRequestId.value = requestId;
  postSubmitting.value = true;
  postError.value = "";
  postMessage.value = "";
  try {
    const result = await apiRequest(`/requests/${requestId}/posts`, {
      method: "POST",
      body: JSON.stringify(postForm),
    });
    if (!result.post || !result.editToken) throw new Error("The contribution could not be saved.");
    savePostToken(result.post.id, result.editToken);
    ownPostsByRequest[requestId] = [
      result.post,
      ...(ownPostsByRequest[requestId] || []).filter((post) => post.id !== result.post.id),
    ];
    if (authUser.value) {
      githubOwnedPosts.value = [
        result.post,
        ...githubOwnedPosts.value.filter((post) => post.id !== result.post.id),
      ];
    }
    resetPostForm();
    postFormRequestId.value = null;
    postMessage.value = "Your contribution is awaiting maintainer review. This browser can edit or delete it.";
  } catch (error) {
    postError.value = error instanceof Error ? error.message : "The contribution could not be submitted.";
  } finally {
    postSubmitting.value = false;
  }
}

async function editCommunityPost(requestId: number, post: ActivityItem | OwnPost) {
  if (typeof post.id !== "number") return;
  const body = window.prompt(
    "Edit your contribution. Published edits return to the moderation queue.",
    post.body || "",
  );
  if (body === null || body.trim() === post.body) return;
  postFeedbackRequestId.value = requestId;
  postError.value = "";
  try {
    const result = await apiRequest(`/posts/${post.id}`, {
      method: "PATCH",
      headers: { "X-Edit-Token": postToken(post.id) },
      body: JSON.stringify({ body }),
    });
    ownPostsByRequest[requestId] = [
      result.post,
      ...(ownPostsByRequest[requestId] || []).filter((item) => item.id !== post.id),
    ];
    githubOwnedPosts.value = [
      result.post,
      ...githubOwnedPosts.value.filter((item) => item.id !== post.id),
    ];
    postMessage.value = "Your edit is awaiting maintainer review.";
    await loadActivity(requestId);
  } catch (error) {
    postError.value = error instanceof Error ? error.message : "The contribution could not be edited.";
  }
}

async function deleteCommunityPost(requestId: number, post: ActivityItem | OwnPost) {
  if (typeof post.id !== "number" || !window.confirm("Delete your contribution permanently?")) return;
  postFeedbackRequestId.value = requestId;
  postError.value = "";
  try {
    await apiRequest(`/posts/${post.id}`, {
      method: "DELETE",
      headers: { "X-Edit-Token": postToken(post.id) },
    });
    removePostToken(post.id);
    ownPostsByRequest[requestId] = (ownPostsByRequest[requestId] || []).filter((item) => item.id !== post.id);
    githubOwnedPosts.value = githubOwnedPosts.value.filter((item) => item.id !== post.id);
    postMessage.value = "Your contribution was deleted.";
    await loadActivity(requestId);
  } catch (error) {
    postError.value = error instanceof Error ? error.message : "The contribution could not be deleted.";
  }
}

function startEditingRequest(request: PackageRequest) {
  editingRequestId.value = request.id;
  requestEditError.value = "";
  requestEditForm.packageName = request.packageName;
  requestEditForm.ecosystem = request.ecosystem;
  requestEditForm.upstreamUrl = request.upstreamUrl;
  requestEditForm.description = request.description;
  requestEditForm.useCase = request.useCase;
  requestEditForm.canHelpTest = request.canHelpTest;
  requestEditForm.requesterName = request.requesterName || "";
  requestEditForm.organization = request.organization || "";
  requestEditForm.contactEmail = request.contactEmail || "";
  requestEditForm.showRequesterPublicly = request.showRequesterPublicly;
  requestAnimationFrame(() => document.querySelector<HTMLElement>(`#edit-package-request-${request.id} textarea`)?.focus());
}

async function saveRequestEdit(request: PackageRequest) {
  requestEditBusy.value = true;
  requestEditError.value = "";
  try {
    const result = await apiRequest(`/me/requests/${request.id}`, {
      method: "PATCH",
      body: JSON.stringify(requestEditForm),
    });
    const index = requests.value.findIndex((item) => item.id === request.id);
    if (index >= 0) requests.value[index] = { ...requests.value[index], ...result.request };
    editingRequestId.value = null;
    successMessage.value = `${result.request.packageName} was updated.`;
    if (expandedActivity.value.has(request.id)) await loadActivity(request.id);
  } catch (error) {
    requestEditError.value = error instanceof Error ? error.message : "The request could not be updated.";
  } finally {
    requestEditBusy.value = false;
  }
}

async function deleteOwnedRequest(request: PackageRequest) {
  const confirmation = window.prompt(
    `Permanently delete this request, its votes, and its discussion?\n\nType "${request.packageName}" to confirm.`,
  );
  if (confirmation === null) return;
  if (confirmation.trim() !== request.packageName) {
    requestEditError.value = "Package name did not match. Nothing was deleted.";
    return;
  }
  requestEditBusy.value = true;
  requestEditError.value = "";
  try {
    await apiRequest(`/me/requests/${request.id}`, { method: "DELETE", body: "{}" });
    for (const post of ownPostsByRequest[request.id] || []) removePostToken(post.id);
    delete ownPostsByRequest[request.id];
    delete activityByRequest[request.id];
    githubOwnedPosts.value = githubOwnedPosts.value.filter((post) => post.requestId !== request.id);
    requests.value = requests.value.filter((item) => item.id !== request.id);
    editingRequestId.value = null;
    successMessage.value = `${request.packageName} was deleted.`;
  } catch (error) {
    requestEditError.value = error instanceof Error ? error.message : "The request could not be deleted.";
  } finally {
    requestEditBusy.value = false;
  }
}

async function changeSort() {
  await loadRequests();
}

async function toggleVote(request: PackageRequest) {
  if (busyVotes.value.has(request.id)) return;
  busyVotes.value = new Set(busyVotes.value).add(request.id);
  const previous = { voted: request.voted, voteCount: request.voteCount };
  request.voted = !request.voted;
  request.voteCount += request.voted ? 1 : -1;

  try {
    const result = await apiRequest(`/requests/${request.id}/vote`, {
      method: request.voted ? "PUT" : "DELETE",
      body: JSON.stringify({ voterId: getVoterId() }),
    });
    request.voted = result.voted;
    request.voteCount = result.voteCount;
  } catch (error) {
    request.voted = previous.voted;
    request.voteCount = previous.voteCount;
    loadError.value = error instanceof Error ? error.message : "Your vote could not be saved.";
  } finally {
    const nextBusyVotes = new Set(busyVotes.value);
    nextBusyVotes.delete(request.id);
    busyVotes.value = nextBusyVotes;
  }
}

function openForm() {
  bulkFormOpen.value = false;
  formOpen.value = true;
  submitError.value = "";
  successMessage.value = "";
  requestAnimationFrame(() => document.querySelector<HTMLElement>("#package-request-form input")?.focus());
}

function closeForm() {
  formOpen.value = false;
  submitError.value = "";
}

function openBulkForm() {
  formOpen.value = false;
  bulkFormOpen.value = true;
  bulkError.value = "";
  successMessage.value = "";
  requestAnimationFrame(() => document.querySelector<HTMLElement>("#bulk-package-request-form textarea")?.focus());
}

function closeBulkForm() {
  bulkFormOpen.value = false;
  bulkError.value = "";
}

function resetBulkForm() {
  bulkRows.value = [];
  bulkInput.value = "";
  bulkReviewing.value = false;
  bulkForm.defaultEcosystem = "";
  bulkForm.description = "";
  bulkForm.canHelpTest = false;
  bulkForm.requesterName = "";
  bulkForm.organization = "";
  bulkForm.contactEmail = "";
  bulkForm.showRequesterPublicly = false;
}

function removeBulkRow(index: number) {
  bulkRows.value.splice(index, 1);
  if (!bulkRows.value.length) bulkReviewing.value = false;
}

function setBulkTester(row: BulkRow, event: Event) {
  const value = (event.target as HTMLSelectElement).value;
  row.canHelpTest = value === "" ? null : value === "true";
}

function toggleBulkExisting(state: BulkRowState) {
  if (state.existingRequest) void toggleVote(state.existingRequest);
}

async function submitBulkRequests() {
  bulkError.value = "";
  successMessage.value = "";
  if (invalidBulkRows.value) {
    bulkError.value = `Fix or remove the ${invalidBulkRows.value} invalid row${invalidBulkRows.value === 1 ? "" : "s"}.`;
    return;
  }
  if (!readyBulkRows.value.length) {
    bulkError.value = "There are no new package requests ready to submit.";
    return;
  }

  bulkSubmitting.value = true;
  try {
    const clientSkipped = skippedBulkRows.value;
    const result = await apiRequest("/requests/bulk", {
      method: "POST",
      body: JSON.stringify({
        description: bulkForm.description,
        canHelpTest: bulkForm.canHelpTest,
        requesterName: bulkForm.requesterName,
        organization: bulkForm.organization,
        contactEmail: bulkForm.contactEmail,
        showRequesterPublicly: bulkForm.showRequesterPublicly,
        requests: readyBulkRows.value.map((row) => ({
          packageName: row.packageName,
          ecosystem: row.ecosystem,
          upstreamUrl: row.upstreamUrl,
          description: row.description,
          useCase: row.useCase,
          canHelpTest: row.canHelpTest,
        })),
      }),
    });
    requests.value.unshift(...result.created);
    const details = [
      `${result.summary.created} package request${result.summary.created === 1 ? "" : "s"} added`,
    ];
    const totalSkipped = clientSkipped + result.summary.duplicates;
    if (totalSkipped) details.push(`${totalSkipped} duplicate or available package${totalSkipped === 1 ? "" : "s"} skipped`);
    if (result.summary.errors) details.push(`${result.summary.errors} rejected`);
    successMessage.value = `${details.join("; ")}.`;
    resetBulkForm();
    bulkFormOpen.value = false;
    document.querySelector(".package-requests")?.scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (error) {
    bulkError.value = error instanceof Error ? error.message : "The bulk request could not be submitted.";
  } finally {
    bulkSubmitting.value = false;
  }
}

async function submitRequest() {
  submitError.value = "";
  successMessage.value = "";
  if (availableMatch.value) {
    submitError.value = "This package already appears in the available-tools catalog.";
    return;
  }

  submitting.value = true;
  try {
    const result = await apiRequest("/requests", {
      method: "POST",
      body: JSON.stringify(form),
    });
    requests.value.unshift(result.request);
    form.packageName = "";
    form.ecosystem = "";
    form.upstreamUrl = "";
    form.description = "";
    form.useCase = "";
    form.canHelpTest = false;
    form.requesterName = "";
    form.organization = "";
    form.contactEmail = "";
    form.showRequesterPublicly = false;
    formOpen.value = false;
    successMessage.value = `${result.request.packageName} was added. You can now vote for it and share this page.`;
    document.querySelector(".package-requests")?.scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (error) {
    const apiError = error as Error & { existingRequestId?: number };
    submitError.value = apiError.message;
    if (apiError.existingRequestId) {
      formOpen.value = false;
      search.value = form.packageName;
      requestAnimationFrame(() => document.getElementById(`package-request-${apiError.existingRequestId}`)?.scrollIntoView({
        behavior: "smooth",
        block: "center",
      }));
    }
  } finally {
    submitting.value = false;
  }
}

onMounted(async () => {
  if (!apiUrl.value && ["localhost", "127.0.0.1"].includes(window.location.hostname)) {
    apiUrl.value = "http://localhost:3100/api";
  }
  const query = new URLSearchParams(window.location.search);
  const packageFromQuery = query.get("package");
  if (query.get("auth") === "success") authMessage.value = "Signed in with GitHub.";
  if (query.get("auth") === "error") authMessage.value = "GitHub sign-in could not be completed. Please try again.";
  if (query.has("auth")) {
    query.delete("auth");
    const replacement = `${window.location.pathname}${query.size ? `?${query}` : ""}${window.location.hash}`;
    window.history.replaceState({}, "", replacement);
  }
  if (packageFromQuery) {
    form.packageName = packageFromQuery;
    formOpen.value = true;
  }
  await Promise.all([loadRequests(), loadAvailablePackages()]);
  await loadAuthentication();
});
</script>

<template>
  <div class="package-requests">
    <section class="request-hero">
      <div class="request-hero-copy">
        <span class="eyebrow">Community package backlog</span>
        <h1>What should we bring to z/OS next?</h1>
        <p>
          Request an open-source package, support the tools you need, and follow its progress.
        </p>
        <div class="hero-actions">
          <button class="primary-button" type="button" @click="openForm">Request a package</button>
          <button class="secondary-button" type="button" @click="openBulkForm">Request several</button>
          <a class="secondary-button" :href="withBase('/Latest')">Browse available tools</a>
          <a
            class="secondary-button"
            href="https://repo.zopen.community/pulp/content/"
            target="_blank"
            rel="noopener noreferrer"
          >Browse package repository ↗</a>
        </div>
      </div>
      <div class="request-stats" aria-label="Package request statistics">
        <div><strong>{{ requests.length }}</strong><span>requests</span></div>
        <div><strong>{{ totalVotes }}</strong><span>community votes</span></div>
      </div>
    </section>

    <section v-if="githubAuthEnabled || authUser" class="identity-panel" aria-label="GitHub sign-in">
      <div v-if="authUser" class="identity-user">
        <img v-if="authUser.avatarUrl" :src="authUser.avatarUrl" alt="" />
        <div>
          <strong>Signed in as @{{ authUser.login }}</strong>
          <span>Your votes are tied to this GitHub identity, and your submissions can be edited from any signed-in device.</span>
        </div>
      </div>
      <div v-else>
        <strong>Want to edit submissions later?</strong>
        <span>Sign in with GitHub before submitting. Guest discussion posts still use this browser's private edit key.</span>
      </div>
      <div class="identity-actions">
        <button v-if="authUser" class="secondary-button compact" type="button" @click="showMine = !showMine">
          {{ showMine ? "Show all requests" : "My submissions" }}
        </button>
        <button v-if="authUser" class="secondary-button compact" type="button" @click="signOut">Sign out</button>
        <button v-else class="primary-button compact" type="button" :disabled="authLoading" @click="signInWithGithub">
          Sign in with GitHub
        </button>
      </div>
    </section>
    <p v-if="authMessage && !authLoading" class="notice" :class="{ success: authUser, error: !authUser }" role="status">{{ authMessage }}</p>

    <p class="governance-note">
      Requests and votes guide community planning; they are not delivery or support commitments.
      Ports move forward through open contribution, maintainer capacity, and the zopen governance process.
      <a :href="withBase('/Governance#package-requests-and-prioritization')">Learn how requests are governed</a>.
    </p>

    <p v-if="successMessage" class="notice success" role="status">{{ successMessage }}</p>
    <p v-if="loadError" class="notice error" role="alert">
      {{ loadError }}
      <button v-if="apiUrl" type="button" class="text-button" @click="loadRequests">Try again</button>
    </p>

    <section v-if="formOpen" id="package-request-form" class="request-form-panel">
      <div class="panel-heading">
        <div>
          <span class="eyebrow">New request</span>
          <h2>Tell us what you need</h2>
        </div>
        <button class="close-button" type="button" aria-label="Close request form" @click="closeForm">×</button>
      </div>

      <form @submit.prevent="submitRequest">
        <p v-if="authUser" class="signed-in-note">This request will belong to @{{ authUser.login }}, so you can edit it later.</p>
        <div class="form-grid">
          <label>
            <span>Package name <b aria-hidden="true">*</b></span>
            <input v-model.trim="form.packageName" maxlength="80" required placeholder="e.g. ripgrep" />
          </label>
          <label>
            <span>Project ecosystem <b aria-hidden="true">*</b></span>
            <select v-model="form.ecosystem" required>
              <option value="" disabled>Select an ecosystem</option>
              <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
            </select>
          </label>
        </div>
        <div class="form-grid">
          <label>
            <span>Upstream project URL <small>Optional</small></span>
            <input v-model.trim="form.upstreamUrl" type="url" maxlength="500" placeholder="GitHub, PyPI, crates.io, project homepage…" />
          </label>
          <div class="field-hint">
            Add a GitHub, project homepage, or package-registry link if you know it. Maintainers can add this later.
          </div>
        </div>

        <p v-if="availableMatch" class="inline-warning">
          This package appears to be available already. <a :href="withBase('/Latest')">Find it in the catalog</a>.
        </p>

        <label>
          <span>Why would this package be useful on z/OS? <b aria-hidden="true">*</b></span>
          <textarea
            v-model.trim="form.description"
            minlength="2"
            maxlength="1200"
            required
            rows="4"
            placeholder="Describe the problem it solves and who would benefit."
          />
        </label>
        <label>
          <span>Specific use case or version <small>Optional</small></span>
          <textarea
            v-model.trim="form.useCase"
            maxlength="1200"
            rows="3"
            placeholder="Tell us about required features, versions, or compatibility needs."
          />
        </label>
        <label class="checkbox-label">
          <input v-model="form.canHelpTest" type="checkbox" />
          <span>I may be able to help test this package on z/OS.</span>
        </label>
        <fieldset class="requester-section">
          <legend>About you <small>Optional</small></legend>
          <p>These details help maintainers follow up and understand who would benefit from the package.</p>
          <div class="form-grid requester-grid">
            <label>
              <span>Name or alias</span>
              <input v-model.trim="form.requesterName" maxlength="100" autocomplete="name" placeholder="Your name" />
            </label>
            <label>
              <span>Organization or company</span>
              <input v-model.trim="form.organization" maxlength="160" autocomplete="organization" placeholder="Organization name" />
            </label>
          </div>
          <label>
            <span>Contact email <small>Private—maintainers only</small></span>
            <input v-model.trim="form.contactEmail" type="email" maxlength="254" autocomplete="email" placeholder="you@example.com" />
          </label>
          <label class="checkbox-label">
            <input v-model="form.showRequesterPublicly" type="checkbox" />
            <span>Show my name and organization on the public request.</span>
          </label>
        </fieldset>
        <p v-if="submitError" class="notice error" role="alert">{{ submitError }}</p>
        <div class="form-actions">
          <button class="secondary-button" type="button" @click="closeForm">Cancel</button>
          <button class="primary-button" type="submit" :disabled="submitting || Boolean(availableMatch)">
            {{ submitting ? "Submitting…" : "Submit request" }}
          </button>
        </div>
      </form>
    </section>

    <section v-if="bulkFormOpen" id="bulk-package-request-form" class="request-form-panel bulk-request-panel">
      <div class="panel-heading">
        <div>
          <span class="eyebrow">Bulk request</span>
          <h2>Request several packages</h2>
        </div>
        <button class="close-button" type="button" aria-label="Close bulk request form" @click="closeBulkForm">×</button>
      </div>

      <p class="panel-intro">
        Add up to {{ maxBulkRequests }} packages. Each one becomes an independent request with its own votes and status.
        Existing requests and available packages are skipped during review.
      </p>

      <form @submit.prevent="submitBulkRequests">
        <template v-if="!bulkReviewing">
          <div class="form-grid">
            <label>
              <span>Default ecosystem <small>Can be changed during review</small></span>
              <select v-model="bulkForm.defaultEcosystem">
                <option value="">Select an ecosystem</option>
                <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
              </select>
            </label>
            <div class="field-hint">
              A CSV can specify a different ecosystem for each row. Unknown or missing values can be corrected before submission.
            </div>
          </div>
          <label>
            <span>Package names <b aria-hidden="true">*</b> <small>One per line</small></span>
            <textarea
              v-model="bulkInput"
              rows="8"
              :placeholder="'ripgrep\nruff\ncmake'"
            />
          </label>
          <div class="bulk-import-actions">
            <button class="primary-button" type="button" @click="reviewPastedPackages">Review pasted list</button>
            <label class="secondary-button file-button">
              Upload CSV
              <input type="file" accept=".csv,text/csv" @change="loadCsv" />
            </label>
            <button class="text-button standalone" type="button" @click="downloadCsvTemplate">Download CSV template</button>
          </div>
          <p class="csv-help">
            CSV columns: <code>package_name</code>, <code>ecosystem</code>, <code>upstream_url</code>,
            <code>description</code>, <code>use_case</code>, and <code>tester_available</code>.
          </p>
        </template>

        <template v-else>
          <div class="bulk-review-heading">
            <div>
              <strong>Review {{ bulkRows.length }} row{{ bulkRows.length === 1 ? "" : "s" }}</strong>
              <span>{{ readyBulkRows.length }} ready · {{ skippedBulkRows }} skipped · {{ invalidBulkRows }} need attention</span>
            </div>
            <button class="secondary-button compact" type="button" @click="bulkReviewing = false">← Change input</button>
          </div>

          <div class="bulk-review-list">
            <article
              v-for="(row, index) in bulkRows"
              :key="row.key"
              class="bulk-review-row"
              :class="`bulk-row-${bulkStates[index].kind}`"
            >
              <div class="bulk-row-heading">
                <strong>Row {{ index + 1 }}</strong>
                <span class="bulk-state" :class="`bulk-state-${bulkStates[index].kind}`">{{ bulkStates[index].label }}</span>
                <button type="button" class="remove-row-button" :aria-label="`Remove row ${index + 1}`" @click="removeBulkRow(index)">Remove</button>
              </div>
              <div class="bulk-row-grid">
                <label>
                  <span>Package name</span>
                  <input v-model.trim="row.packageName" maxlength="80" />
                </label>
                <label>
                  <span>Ecosystem</span>
                  <select v-model="row.ecosystem">
                    <option value="">Select an ecosystem</option>
                    <option
                      v-if="row.ecosystem && !Object.hasOwn(ecosystems, row.ecosystem)"
                      :value="row.ecosystem"
                      disabled
                    >Unknown: {{ row.ecosystem }}</option>
                    <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
                  </select>
                </label>
                <label>
                  <span>Upstream URL <small>Optional</small></span>
                  <input v-model.trim="row.upstreamUrl" type="url" maxlength="500" placeholder="https://…" />
                </label>
              </div>
              <details class="bulk-row-details">
                <summary>Row-specific details <span v-if="row.description || row.useCase || row.canHelpTest !== null">(provided)</span></summary>
                <label>
                  <span>Reason <small>Overrides the shared reason</small></span>
                  <textarea v-model.trim="row.description" maxlength="1200" rows="2" />
                </label>
                <label>
                  <span>Use case or version <small>Optional</small></span>
                  <textarea v-model.trim="row.useCase" maxlength="1200" rows="2" />
                </label>
                <label>
                  <span>Testing availability</span>
                  <select :value="row.canHelpTest === null ? '' : String(row.canHelpTest)" @change="setBulkTester(row, $event)">
                    <option value="">Use shared answer</option>
                    <option value="true">Can help test</option>
                    <option value="false">Cannot currently help test</option>
                  </select>
                </label>
              </details>
              <div v-if="bulkStates[index].kind === 'existing'" class="bulk-existing-action">
                <span>Support the existing request instead:</span>
                <button
                  type="button"
                  class="secondary-button compact"
                  :disabled="busyVotes.has(bulkStates[index].existingRequest?.id || 0)"
                  @click="toggleBulkExisting(bulkStates[index])"
                >{{ bulkStates[index].existingRequest?.voted ? "Remove vote" : "Vote for it" }}</button>
              </div>
              <p v-else-if="bulkStates[index].kind === 'available'" class="bulk-existing-action">
                This package is already in the <a :href="withBase('/Latest')">available-tools catalog</a>.
              </p>
            </article>
          </div>
        </template>

        <label>
          <span>Why is this group of packages useful on z/OS? <small>Used for rows without their own reason</small></span>
          <textarea
            v-model.trim="bulkForm.description"
            maxlength="1200"
            rows="4"
            placeholder="Describe the migration, toolchain, workload, or community need behind this group."
          />
        </label>
        <label class="checkbox-label">
          <input v-model="bulkForm.canHelpTest" type="checkbox" />
          <span>I may be able to help test these packages on z/OS.</span>
        </label>
        <fieldset class="requester-section">
          <legend>About you <small>Optional—applied to every new request</small></legend>
          <p>These details help maintainers understand the shared need and coordinate follow-up.</p>
          <div class="form-grid requester-grid">
            <label>
              <span>Name or alias</span>
              <input v-model.trim="bulkForm.requesterName" maxlength="100" autocomplete="name" placeholder="Your name" />
            </label>
            <label>
              <span>Organization or company</span>
              <input v-model.trim="bulkForm.organization" maxlength="160" autocomplete="organization" placeholder="Organization name" />
            </label>
          </div>
          <label>
            <span>Contact email <small>Private—maintainers only</small></span>
            <input v-model.trim="bulkForm.contactEmail" type="email" maxlength="254" autocomplete="email" placeholder="you@example.com" />
          </label>
          <label class="checkbox-label">
            <input v-model="bulkForm.showRequesterPublicly" type="checkbox" />
            <span>Show my name and organization on the public requests.</span>
          </label>
        </fieldset>

        <p v-if="bulkError" class="notice error" role="alert">{{ bulkError }}</p>
        <div class="form-actions">
          <button class="secondary-button" type="button" @click="closeBulkForm">Cancel</button>
          <button
            v-if="bulkReviewing"
            class="primary-button"
            type="submit"
            :disabled="bulkSubmitting || invalidBulkRows > 0 || readyBulkRows.length === 0"
          >{{ bulkSubmitting ? "Submitting…" : `Submit ${readyBulkRows.length} new request${readyBulkRows.length === 1 ? "" : "s"}` }}</button>
        </div>
      </form>
    </section>

    <section class="request-board">
      <div class="board-heading">
        <div>
          <span class="eyebrow">Package requests</span>
          <h2>Vote for what matters to you</h2>
        </div>
        <div v-if="!formOpen && !bulkFormOpen" class="board-actions">
          <button class="secondary-button compact" type="button" @click="openBulkForm">Bulk request</button>
          <button class="primary-button compact" type="button" @click="openForm">+ New request</button>
        </div>
      </div>

      <div class="board-controls" :class="{ 'has-mine-filter': authUser }">
        <button
          v-if="authUser"
          class="mine-filter"
          :class="{ active: showMine }"
          type="button"
          :aria-pressed="showMine"
          @click="showMine = !showMine"
        >My submissions</button>
        <label class="search-control">
          <span class="visually-hidden">Search package requests</span>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m21 21-4.35-4.35m2.35-5.65a8 8 0 1 1-16 0 8 8 0 0 1 16 0Z" /></svg>
          <input v-model="search" type="search" placeholder="Search requests…" />
        </label>
        <label>
          <span class="visually-hidden">Filter by ecosystem</span>
          <select v-model="ecosystem">
            <option value="all">All ecosystems</option>
            <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
          </select>
        </label>
        <label>
          <span class="visually-hidden">Filter by status</span>
          <select v-model="status">
            <option value="all">All statuses</option>
            <option v-for="(value, key) in statuses" :key="key" :value="key">{{ value.label }}</option>
          </select>
        </label>
        <div class="sort-control" aria-label="Sort requests">
          <button type="button" :class="{ active: sort === 'top' }" @click="sort = 'top'; changeSort()">Top</button>
          <button type="button" :class="{ active: sort === 'newest' }" @click="sort = 'newest'; changeSort()">Newest</button>
        </div>
      </div>

      <div v-if="loading" class="request-skeletons" aria-label="Loading package requests">
        <div v-for="item in 3" :key="item" class="request-skeleton" />
      </div>

      <div v-else-if="filteredRequests.length" class="request-list">
        <article
          v-for="request in filteredRequests"
          :id="`package-request-${request.id}`"
          :key="request.id"
          class="request-card"
        >
          <button
            type="button"
            class="vote-button"
            :class="{ voted: request.voted }"
            :disabled="busyVotes.has(request.id)"
            :aria-label="`${request.voted ? 'Remove vote from' : 'Vote for'} ${request.packageName}`"
            :aria-pressed="request.voted"
            @click="toggleVote(request)"
          >
            <svg viewBox="0 0 20 20" aria-hidden="true"><path d="m10 4 5 6h-3v6H8v-6H5l5-6Z" /></svg>
            <strong>{{ request.voteCount }}</strong>
            <span>{{ request.voted ? "Voted" : "Vote" }}</span>
          </button>
          <div class="request-card-content">
            <div class="request-card-title">
              <h3>{{ request.packageName }}</h3>
              <span class="ecosystem-pill">{{ ecosystems[request.ecosystem] || request.ecosystem }}</span>
              <span class="status-pill" :class="`status-${request.status}`" :title="statuses[request.status].detail">
                {{ statuses[request.status].label }}
              </span>
            </div>
            <p>{{ request.description }}</p>
            <p v-if="request.useCase" class="use-case"><strong>Use case:</strong> {{ request.useCase }}</p>
            <p v-if="request.maintainerNote" class="maintainer-note">
              <strong>Maintainer update:</strong> {{ request.maintainerNote }}
            </p>
            <div v-if="request.portRepositoryUrl || request.artifactUrl" class="delivery-links">
              <a
                v-if="request.portRepositoryUrl"
                :href="request.portRepositoryUrl"
                target="_blank"
                rel="noopener noreferrer"
              >zopen port repository ↗</a>
              <a
                v-if="request.artifactUrl"
                :href="request.artifactUrl"
                target="_blank"
                rel="noopener noreferrer"
              >{{ artifactLabels[request.artifactKind] || "Published package" }} ↗</a>
            </div>
            <div class="request-meta">
              <a v-if="request.upstreamUrl" :href="request.upstreamUrl" target="_blank" rel="noopener noreferrer">View upstream project ↗</a>
              <span v-if="request.canHelpTest">Tester available</span>
              <span v-if="request.acknowledgedAt">Acknowledged by maintainers</span>
              <span v-if="request.requesterName || request.organization">
                Requested by {{ [request.requesterName, request.organization].filter(Boolean).join(" · ") }}
              </span>
              <span>Requested {{ new Date(request.createdAt).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" }) }}</span>
            </div>

            <div v-if="request.ownedByCurrentUser" class="request-owner-tools">
              <span>Owned by your GitHub account</span>
              <button
                class="secondary-button compact"
                type="button"
                @click="editingRequestId === request.id ? editingRequestId = null : startEditingRequest(request)"
              >{{ editingRequestId === request.id ? "Cancel editing" : "Edit request" }}</button>
            </div>

            <form
              v-if="editingRequestId === request.id"
              :id="`edit-package-request-${request.id}`"
              class="request-edit-form"
              @submit.prevent="saveRequestEdit(request)"
            >
              <div class="form-grid">
                <label>
                  <span>Package name</span>
                  <input v-model.trim="requestEditForm.packageName" maxlength="80" required :disabled="!['proposed', 'under_review'].includes(request.status)" />
                </label>
                <label>
                  <span>Project ecosystem</span>
                  <select v-model="requestEditForm.ecosystem" :disabled="!['proposed', 'under_review'].includes(request.status)">
                    <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
                  </select>
                </label>
              </div>
              <p v-if="!['proposed', 'under_review'].includes(request.status)" class="field-hint">
                Package name and ecosystem are locked after initial review; maintainers can correct them if needed.
              </p>
              <label><span>Upstream project URL <small>Optional</small></span><input v-model.trim="requestEditForm.upstreamUrl" type="url" maxlength="500" /></label>
              <label><span>Why is this package useful?</span><textarea v-model.trim="requestEditForm.description" minlength="2" maxlength="1200" required rows="3" /></label>
              <label><span>Specific use case or version <small>Optional</small></span><textarea v-model.trim="requestEditForm.useCase" maxlength="1200" rows="3" /></label>
              <div class="form-grid">
                <label><span>Name or alias <small>Optional</small></span><input v-model.trim="requestEditForm.requesterName" maxlength="100" /></label>
                <label><span>Organization <small>Optional</small></span><input v-model.trim="requestEditForm.organization" maxlength="160" /></label>
              </div>
              <label><span>Contact email <small>Private—maintainers only</small></span><input v-model.trim="requestEditForm.contactEmail" type="email" maxlength="254" /></label>
              <label class="checkbox-label"><input v-model="requestEditForm.canHelpTest" type="checkbox" /><span>I may be able to help test this package.</span></label>
              <label class="checkbox-label"><input v-model="requestEditForm.showRequesterPublicly" type="checkbox" /><span>Show my name and organization publicly.</span></label>
              <p v-if="requestEditError" class="notice error" role="alert">{{ requestEditError }}</p>
              <div class="form-actions">
                <button
                  v-if="request.status === 'proposed'"
                  class="danger-button compact"
                  type="button"
                  :disabled="requestEditBusy"
                  @click="deleteOwnedRequest(request)"
                >Delete request</button>
                <button class="secondary-button compact" type="button" @click="editingRequestId = null">Cancel</button>
                <button class="primary-button compact" type="submit" :disabled="requestEditBusy">{{ requestEditBusy ? "Saving…" : "Save changes" }}</button>
              </div>
            </form>

            <button
              type="button"
              class="discussion-toggle"
              :aria-expanded="expandedActivity.has(request.id)"
              :aria-controls="`request-activity-${request.id}`"
              @click="toggleActivity(request.id)"
            >
              <span>{{ expandedActivity.has(request.id) ? "Hide" : "View" }} discussion &amp; activity</span>
              <span class="discussion-count">{{ request.discussionCount || 0 }} community post{{ request.discussionCount === 1 ? "" : "s" }}</span>
            </button>

            <section
              v-if="expandedActivity.has(request.id)"
              :id="`request-activity-${request.id}`"
              class="activity-panel"
              :aria-label="`${request.packageName} discussion and activity`"
            >
              <div class="activity-heading">
                <div>
                  <span class="eyebrow">Open collaboration</span>
                  <h4>Discussion and activity</h4>
                </div>
                <button class="secondary-button compact" type="button" @click="loadActivity(request.id)">Refresh</button>
              </div>

              <p v-if="activityBusy.has(request.id)" class="activity-loading">Loading activity…</p>
              <p v-else-if="activityErrors[request.id]" class="notice error" role="alert">{{ activityErrors[request.id] }}</p>
              <ol v-else class="activity-timeline">
                <li v-for="item in activityByRequest[request.id] || []" :key="`${item.type}:${item.id}`" :class="`activity-${item.type}`">
                  <div class="activity-marker" aria-hidden="true" />
                  <div class="activity-entry">
                    <template v-if="item.type === 'created'">
                      <strong>Request submitted</strong>
                    </template>
                    <template v-else-if="item.type === 'status'">
                      <strong>Status changed to {{ statusLabel(item.toStatus) }}</strong>
                      <span class="activity-context">from {{ statusLabel(item.fromStatus) }}</span>
                      <p v-if="item.note">{{ item.note }}</p>
                    </template>
                    <template v-else-if="item.type === 'edit'">
                      <strong>Request details updated</strong>
                    </template>
                    <template v-else>
                      <div class="post-heading">
                        <span class="post-kind">{{ postKinds[item.kind || ''] || item.kind }}</span>
                        <span v-if="item.authorRole === 'maintainer'" class="maintainer-badge">Verified maintainer</span>
                      </div>
                      <p class="post-body">
                        <template v-for="(segment, segmentIndex) in textSegments(item.body)" :key="segmentIndex">
                          <a v-if="segment.url" :href="segment.url" target="_blank" rel="noopener noreferrer">{{ segment.text }}</a>
                          <template v-else>{{ segment.text }}</template>
                        </template>
                      </p>
                      <span v-if="item.authorName || item.organization" class="activity-author">
                        {{ [item.authorName, item.organization].filter(Boolean).join(" · ") }}
                      </span>
                      <div v-if="postToken(item.id) || item.ownedByCurrentUser" class="owner-actions">
                        <button type="button" @click="editCommunityPost(request.id, item)">Edit</button>
                        <button type="button" @click="deleteCommunityPost(request.id, item)">Delete</button>
                      </div>
                    </template>
                    <time :datetime="item.createdAt">{{ displayDate(item.createdAt) }}</time>
                  </div>
                </li>
              </ol>

              <div v-if="ownUnpublishedPosts(request.id).length" class="own-posts">
                <h5>Your unpublished contributions</h5>
                <article v-for="post in ownUnpublishedPosts(request.id)" :key="post.id" class="own-post">
                  <div>
                    <span class="post-kind">{{ postKinds[post.kind || ''] || post.kind }}</span>
                    <span :class="['moderation-badge', `moderation-${post.moderationStatus}`]">{{ post.moderationStatus }}</span>
                  </div>
                  <p>{{ post.body }}</p>
                  <div class="owner-actions">
                    <button type="button" @click="editCommunityPost(request.id, post)">Edit</button>
                    <button type="button" @click="deleteCommunityPost(request.id, post)">Delete</button>
                  </div>
                </article>
              </div>

              <p
                v-if="postFeedbackRequestId === request.id && postMessage"
                class="notice success"
                role="status"
              >{{ postMessage }}</p>
              <p
                v-if="postFeedbackRequestId === request.id && postError"
                class="notice error"
                role="alert"
              >{{ postError }}</p>

              <form
                v-if="postFormRequestId === request.id"
                :id="`community-post-${request.id}`"
                class="community-post-form"
                @submit.prevent="submitCommunityPost(request.id)"
              >
                <div class="post-form-heading">
                  <div><strong>Add to the discussion</strong><span>Posts are reviewed before appearing publicly.</span></div>
                  <button type="button" class="close-post-form" aria-label="Close contribution form" @click="postFormRequestId = null">×</button>
                </div>
                <div class="post-form-grid">
                  <label>
                    <span>Contribution type</span>
                    <select v-model="postForm.kind" required>
                      <option value="use_case">Additional use case</option>
                      <option value="testing_offer">Offer to test</option>
                      <option value="contribution_offer">Offer to contribute</option>
                      <option value="technical_note">Technical information</option>
                      <option value="question">Question</option>
                    </select>
                  </label>
                  <label>
                    <span>Contact email <small>Private—maintainers only</small></span>
                    <input v-model.trim="postForm.contactEmail" type="email" maxlength="254" autocomplete="email" />
                  </label>
                </div>
                <label>
                  <span>Your contribution</span>
                  <textarea v-model.trim="postForm.body" required minlength="2" maxlength="2000" rows="4" />
                </label>
                <div class="post-form-grid">
                  <label><span>Name or alias <small>Optional</small></span><input v-model.trim="postForm.authorName" maxlength="100" /></label>
                  <label><span>Organization <small>Optional</small></span><input v-model.trim="postForm.organization" maxlength="160" /></label>
                </div>
                <label class="checkbox-label">
                  <input v-model="postForm.showAuthorPublicly" type="checkbox" />
                  <span>Show my name and organization if this contribution is published.</span>
                </label>
                <label class="honeypot" aria-hidden="true">
                  <span>Website</span>
                  <input v-model="postForm.website" tabindex="-1" autocomplete="off" />
                </label>
                <p class="post-privacy">
                  Your email is visible only to maintainers.
                  <template v-if="authUser">This contribution will belong to your GitHub account.</template>
                  <template v-else>An edit secret is stored in this browser so you can modify or delete your post.</template>
                </p>
                <div class="form-actions">
                  <button class="secondary-button compact" type="button" @click="postFormRequestId = null">Cancel</button>
                  <button class="primary-button compact" type="submit" :disabled="postSubmitting">
                    {{ postSubmitting ? "Submitting…" : "Submit for review" }}
                  </button>
                </div>
              </form>
              <button
                v-else
                class="secondary-button compact add-contribution"
                type="button"
                @click="openPostForm(request.id)"
              >Add information or offer help</button>
            </section>
          </div>
        </article>
      </div>

      <div v-else class="empty-state">
        <div aria-hidden="true">📦</div>
        <h3>{{ requests.length ? "No requests match those filters" : "Be the first to request a package" }}</h3>
        <p>{{ requests.length ? "Try a different search or status." : "Tell the community which open-source tool would help you on z/OS." }}</p>
        <button v-if="!requests.length" class="primary-button" type="button" @click="openForm">Request a package</button>
      </div>
    </section>
  </div>
</template>

<style scoped>
.package-requests { --request-accent: #167d68; --request-accent-dark: #0d5c4c; color: var(--vp-c-text-1); }
.request-hero { position: relative; display: grid; grid-template-columns: minmax(0, 1.6fr) minmax(260px, .7fr); gap: 48px; align-items: end; padding: 56px; margin: 0 0 28px; overflow: hidden; border: 1px solid var(--vp-c-divider); border-radius: 24px; background: linear-gradient(135deg, color-mix(in srgb, var(--request-accent) 14%, var(--vp-c-bg)) 0%, var(--vp-c-bg-soft) 65%); }
.request-hero::after { content: ""; position: absolute; width: 260px; height: 260px; right: -70px; top: -100px; border: 54px solid color-mix(in srgb, var(--request-accent) 12%, transparent); border-radius: 50%; }
.request-hero-copy, .request-stats { position: relative; z-index: 1; }
.eyebrow { display: block; margin-bottom: 8px; color: var(--request-accent); font-size: 12px; font-weight: 750; letter-spacing: .12em; text-transform: uppercase; }
.request-hero h1 { max-width: 720px; margin: 0; border: 0; font-size: clamp(36px, 5vw, 60px); line-height: 1.02; letter-spacing: -.04em; }
.request-hero p { max-width: 680px; margin: 20px 0 0; color: var(--vp-c-text-2); font-size: 18px; line-height: 1.65; }
.hero-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 28px; }
.primary-button, .secondary-button { display: inline-flex; align-items: center; justify-content: center; min-height: 44px; padding: 0 20px; border: 1px solid transparent; border-radius: 10px; font: inherit; font-weight: 650; line-height: 1; text-decoration: none !important; cursor: pointer; transition: transform .15s, background-color .15s, border-color .15s; }
.primary-button { color: white; background: var(--request-accent); }
.primary-button:hover { color: white; background: var(--request-accent-dark); transform: translateY(-1px); }
.primary-button:disabled { cursor: not-allowed; opacity: .55; transform: none; }
.secondary-button { color: var(--vp-c-text-1); border-color: var(--vp-c-divider); background: var(--vp-c-bg); }
.secondary-button:hover { border-color: var(--request-accent); color: var(--request-accent); }
.primary-button.compact, .secondary-button.compact { min-height: 38px; padding: 0 14px; font-size: 14px; }
.danger-button { display:inline-flex; min-height:44px; align-items:center; justify-content:center; padding:0 20px; border:1px solid var(--vp-c-danger-2); border-radius:10px; color:var(--vp-c-danger-1); background:var(--vp-c-danger-soft); font:inherit; font-weight:650; cursor:pointer; }
.danger-button.compact { min-height:38px; padding:0 14px; font-size:14px; }
.danger-button:disabled { cursor:not-allowed; opacity:.55; }
.request-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 1px; overflow: hidden; border: 1px solid var(--vp-c-divider); border-radius: 16px; background: var(--vp-c-divider); box-shadow: var(--vp-shadow-2); }
.request-stats div { display: flex; min-height: 126px; flex-direction: column; align-items: center; justify-content: center; background: color-mix(in srgb, var(--vp-c-bg) 92%, transparent); }
.request-stats strong { font-size: 34px; letter-spacing: -.03em; }
.request-stats span { color: var(--vp-c-text-2); font-size: 12px; text-align: center; text-transform: uppercase; letter-spacing: .08em; }
.notice { padding: 13px 16px; border-radius: 10px; font-size: 14px; }
.governance-note { margin: 0 0 24px; padding: 16px 18px; border-left: 4px solid var(--vp-c-brand-1); border-radius: 4px 10px 10px 4px; color: var(--vp-c-text-2); background: var(--vp-c-bg-soft); font-size: 14px; line-height: 1.6; }
.governance-note a { font-weight: 700; }
.identity-panel { display: flex; align-items: center; justify-content: space-between; gap: 20px; margin: 0 0 20px; padding: 16px 18px; border: 1px solid var(--vp-c-divider); border-radius: 14px; background: var(--vp-c-bg-soft); }
.identity-panel > div, .identity-user { display: flex; align-items: center; gap: 12px; }
.identity-panel strong, .identity-panel span { display: block; }
.identity-panel span { margin-top: 3px; color: var(--vp-c-text-2); font-size: 13px; }
.identity-user img { width: 40px; height: 40px; border-radius: 50%; }
.identity-actions { flex-shrink: 0; }
.signed-in-note { padding: 10px 12px; border-radius: 8px; color: var(--vp-c-text-2); background: var(--vp-c-bg-soft); font-size: 14px; }
.notice.success { color: #09634f; border: 1px solid #85cdbd; background: #e7f8f3; }
.dark .notice.success { color: #a8e6d6; border-color: #275e52; background: #142d28; }
.notice.error { color: var(--vp-c-danger-1); border: 1px solid var(--vp-c-danger-2); background: var(--vp-c-danger-soft); }
.mine-filter { min-height: 44px; padding: 0 16px; border: 1px solid var(--vp-c-divider); border-radius: 9px; color: var(--vp-c-text-2); background: var(--vp-c-bg); font: inherit; font-size: 14px; white-space: nowrap; cursor: pointer; }
.mine-filter.active { color: white; border-color: var(--request-accent); background: var(--request-accent); }
.request-owner-tools { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-top: 14px; padding: 10px 12px; border: 1px solid color-mix(in srgb, var(--request-accent) 35%, var(--vp-c-divider)); border-radius: 10px; color: var(--request-accent); background: color-mix(in srgb, var(--request-accent) 7%, var(--vp-c-bg)); font-size: 13px; font-weight: 650; }
.request-edit-form { display: grid; gap: 14px; margin-top: 14px; padding: 18px; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg-soft); }
.request-edit-form label > span { display: block; margin-bottom: 6px; font-size: 13px; font-weight: 650; }
.request-edit-form input:not([type="checkbox"]), .request-edit-form select, .request-edit-form textarea { width: 100%; padding: 10px 11px; border: 1px solid var(--vp-c-divider); border-radius: 8px; color: var(--vp-c-text-1); background: var(--vp-c-bg); font: inherit; }
.text-button { margin-left: 8px; padding: 0; color: inherit; border: 0; background: transparent; font: inherit; font-weight: 650; text-decoration: underline; cursor: pointer; }
.request-form-panel, .request-board { margin-top: 28px; border: 1px solid var(--vp-c-divider); border-radius: 18px; background: var(--vp-c-bg); box-shadow: var(--vp-shadow-1); }
.request-form-panel { padding: 28px; border-top: 4px solid var(--request-accent); }
.panel-heading, .board-heading { display: flex; align-items: flex-start; justify-content: space-between; gap: 24px; }
.panel-heading h2, .board-heading h2 { margin: 0; border: 0; padding: 0; font-size: 26px; letter-spacing: -.02em; }
.panel-intro { max-width: 780px; margin: 12px 0 0; color: var(--vp-c-text-2); line-height: 1.6; }
.close-button { width: 38px; height: 38px; border: 1px solid var(--vp-c-divider); border-radius: 50%; color: var(--vp-c-text-2); background: var(--vp-c-bg-soft); font-size: 26px; line-height: 1; cursor: pointer; }
.request-form-panel form { margin-top: 24px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.request-form-panel label { display: block; margin: 0 0 18px; }
.request-form-panel label > span { display: block; margin-bottom: 7px; font-size: 14px; font-weight: 650; }
.request-form-panel label b { color: var(--vp-c-danger-1); }
.request-form-panel label small { margin-left: 6px; color: var(--vp-c-text-3); font-weight: 400; }
.request-form-panel input:not([type="checkbox"]), .request-form-panel textarea, .request-form-panel select, .board-controls input, .board-controls select { box-sizing: border-box; width: 100%; border: 1px solid var(--vp-c-divider); border-radius: 9px; color: var(--vp-c-text-1); background: var(--vp-c-bg-soft); font: inherit; outline: none; }
.request-form-panel input:not([type="checkbox"]), .request-form-panel select, .board-controls input, .board-controls select { height: 44px; padding: 0 13px; }
.request-form-panel textarea { min-height: 90px; padding: 11px 13px; resize: vertical; }
.request-form-panel input:focus, .request-form-panel textarea:focus, .request-form-panel select:focus, .board-controls input:focus, .board-controls select:focus { border-color: var(--request-accent); box-shadow: 0 0 0 3px color-mix(in srgb, var(--request-accent) 15%, transparent); }
.field-hint { align-self: center; padding: 0 8px; color: var(--vp-c-text-3); font-size: 13px; line-height: 1.5; }
.checkbox-label { display: flex !important; gap: 10px; align-items: flex-start; }
.checkbox-label input { width: 17px; height: 17px; margin-top: 2px; accent-color: var(--request-accent); }
.checkbox-label span { margin: 0 !important; font-weight: 500 !important; }
.requester-section { padding: 18px; margin: 22px 0; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg-soft); }
.requester-section legend { padding: 0 7px; font-weight: 750; }
.requester-section legend small { margin-left: 5px; color: var(--vp-c-text-3); font-weight: 400; }
.requester-section > p { margin: 0 0 16px; color: var(--vp-c-text-2); font-size: 13px; }
.requester-section label:last-child { margin-bottom: 0; }
.inline-warning { padding: 10px 12px; margin: -6px 0 18px; border-radius: 8px; color: #825d00; background: #fff4ce; font-size: 14px; }
.dark .inline-warning { color: #ffe08a; background: #3b3011; }
.form-actions { display: flex; justify-content: flex-end; gap: 10px; }
.bulk-import-actions, .board-actions { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }
.file-button { display: inline-flex !important; margin: 0 !important; }
.file-button input { position: absolute; width: 1px; height: 1px; overflow: hidden; opacity: 0; }
.text-button.standalone { margin-left: 4px; color: var(--request-accent); }
.csv-help { margin: 12px 0 24px; color: var(--vp-c-text-3); font-size: 13px; line-height: 1.6; }
.bulk-review-heading { display: flex; justify-content: space-between; gap: 20px; align-items: center; padding: 14px 16px; margin-bottom: 14px; border-radius: 10px; background: var(--vp-c-bg-soft); }
.bulk-review-heading strong, .bulk-review-heading span { display: block; }
.bulk-review-heading span { margin-top: 3px; color: var(--vp-c-text-3); font-size: 13px; }
.bulk-review-list { display: grid; gap: 12px; max-height: 780px; padding-right: 4px; margin-bottom: 24px; overflow-y: auto; }
.bulk-review-row { padding: 16px; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg); }
.bulk-row-invalid { border-color: var(--vp-c-danger-2); }
.bulk-row-existing, .bulk-row-available, .bulk-row-duplicate { background: var(--vp-c-bg-soft); }
.bulk-row-heading { display: flex; align-items: center; gap: 10px; margin-bottom: 13px; }
.bulk-row-heading > strong { font-size: 13px; }
.bulk-state { padding: 3px 8px; border-radius: 999px; color: var(--vp-c-text-2); background: var(--vp-c-default-soft); font-size: 11px; font-weight: 700; }
.bulk-state-ready { color: #09634f; background: #daf4ec; }
.bulk-state-invalid { color: var(--vp-c-danger-1); background: var(--vp-c-danger-soft); }
.bulk-state-existing, .bulk-state-available, .bulk-state-duplicate { color: #795b00; background: #fff1bd; }
.dark .bulk-state-ready, .dark .bulk-state-existing, .dark .bulk-state-available, .dark .bulk-state-duplicate { color: var(--vp-c-text-1); background: var(--vp-c-bg-alt); }
.remove-row-button { margin-left: auto; padding: 3px 0; border: 0; color: var(--vp-c-danger-1); background: transparent; font: inherit; font-size: 12px; text-decoration: underline; cursor: pointer; }
.bulk-row-grid { display: grid; grid-template-columns: minmax(150px, .8fr) minmax(150px, .7fr) minmax(220px, 1.4fr); gap: 12px; }
.bulk-row-grid label { margin-bottom: 10px; }
.bulk-row-details { padding-top: 3px; color: var(--vp-c-text-2); font-size: 13px; }
.bulk-row-details summary { cursor: pointer; font-weight: 650; }
.bulk-row-details[open] summary { margin-bottom: 12px; }
.bulk-row-details label { margin-bottom: 10px; }
.bulk-row-details label:last-child { max-width: 320px; margin-bottom: 0; }
.bulk-existing-action { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; padding: 10px 12px; margin: 12px 0 0; border-radius: 8px; color: var(--vp-c-text-2); background: var(--vp-c-bg-alt); font-size: 13px; }
.request-board { padding: 28px; }
.board-controls { display: grid; grid-template-columns: minmax(220px, 1fr) 170px 160px auto; gap: 12px; margin: 24px 0; }
.board-controls.has-mine-filter { grid-template-columns: auto minmax(220px, 1fr) 170px 160px auto; }
.search-control { position: relative; }
.search-control svg { position: absolute; z-index: 1; width: 18px; left: 13px; top: 13px; fill: none; stroke: var(--vp-c-text-3); stroke-width: 2; stroke-linecap: round; }
.search-control input { padding-left: 40px; }
.sort-control { display: flex; min-height: 44px; padding: 3px; border: 1px solid var(--vp-c-divider); border-radius: 9px; background: var(--vp-c-bg-soft); }
.sort-control button { min-width: 70px; border: 0; border-radius: 6px; color: var(--vp-c-text-2); background: transparent; font: inherit; font-size: 14px; cursor: pointer; }
.sort-control button.active { color: var(--vp-c-text-1); background: var(--vp-c-bg); box-shadow: var(--vp-shadow-1); font-weight: 650; }
.request-list { display: grid; gap: 12px; }
.request-card { display: grid; grid-template-columns: 82px minmax(0, 1fr); gap: 20px; padding: 22px; border: 1px solid var(--vp-c-divider); border-radius: 14px; transition: border-color .15s, box-shadow .15s, transform .15s; }
.request-card:hover { border-color: color-mix(in srgb, var(--request-accent) 55%, var(--vp-c-divider)); box-shadow: var(--vp-shadow-2); transform: translateY(-1px); }
.vote-button { display: flex; width: 72px; min-height: 92px; align-self: start; flex-direction: column; align-items: center; justify-content: center; border: 1px solid var(--vp-c-divider); border-radius: 12px; color: var(--vp-c-text-2); background: var(--vp-c-bg-soft); cursor: pointer; }
.vote-button:hover { border-color: var(--request-accent); color: var(--request-accent); }
.vote-button.voted { border-color: var(--request-accent); color: var(--request-accent-dark); background: color-mix(in srgb, var(--request-accent) 12%, var(--vp-c-bg)); }
.dark .vote-button.voted { color: #72d2bc; }
.vote-button:disabled { opacity: .6; cursor: wait; }
.vote-button svg { width: 22px; fill: currentColor; }
.vote-button strong { margin-top: 2px; font-size: 20px; line-height: 1.1; }
.vote-button span { margin-top: 3px; font-size: 11px; font-weight: 650; text-transform: uppercase; letter-spacing: .05em; }
.request-card-title { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }
.request-card-title h3 { margin: 0; font-size: 20px; line-height: 1.3; }
.status-pill { padding: 4px 9px; border-radius: 999px; color: var(--vp-c-text-2); background: var(--vp-c-default-soft); font-size: 11px; font-weight: 700; letter-spacing: .03em; text-transform: uppercase; }
.ecosystem-pill { padding: 4px 9px; border: 1px solid var(--vp-c-divider); border-radius: 999px; color: var(--request-accent); background: var(--vp-c-bg-soft); font-size: 11px; font-weight: 700; }
.status-under_review { color: #795b00; background: #fff1bd; }
.status-accepted { color: #225ca8; background: #e5efff; }
.status-in_progress { color: #7445a0; background: #f0e5fb; }
.status-available { color: #09634f; background: #daf4ec; }
.dark .status-under_review, .dark .status-accepted, .dark .status-in_progress, .dark .status-available { color: var(--vp-c-text-1); background: var(--vp-c-bg-soft); }
.request-card-content > p { margin: 10px 0 0; color: var(--vp-c-text-2); line-height: 1.6; }
.request-card-content .use-case { padding-left: 12px; border-left: 2px solid var(--vp-c-divider); font-size: 14px; }
.request-card-content .maintainer-note { padding: 12px 14px; border-radius: 9px; color: var(--vp-c-text-1); background: color-mix(in srgb, var(--request-accent) 9%, var(--vp-c-bg-soft)); font-size: 14px; }
.delivery-links { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 14px; }
.delivery-links a { padding: 7px 10px; border: 1px solid color-mix(in srgb, var(--request-accent) 45%, var(--vp-c-divider)); border-radius: 8px; color: var(--request-accent); background: var(--vp-c-bg-soft); font-size: 13px; font-weight: 700; text-decoration: none; }
.request-meta { display: flex; flex-wrap: wrap; gap: 8px 18px; margin-top: 16px; color: var(--vp-c-text-3); font-size: 12px; }
.request-meta a { color: var(--request-accent); font-weight: 650; text-decoration: none; }
.discussion-toggle { display:flex; width:100%; align-items:center; justify-content:space-between; gap:16px; padding:11px 13px; margin-top:18px; border:1px solid var(--vp-c-divider); border-radius:9px; color:var(--vp-c-text-1); background:var(--vp-c-bg-soft); font:inherit; font-size:13px; font-weight:700; cursor:pointer; }
.discussion-toggle:hover { border-color:var(--request-accent); color:var(--request-accent); }
.discussion-count { color:var(--vp-c-text-3); font-size:11px; font-weight:600; }
.activity-panel { padding:18px; margin-top:10px; border:1px solid var(--vp-c-divider); border-radius:12px; background:var(--vp-c-bg-soft); }
.activity-heading,.post-form-heading { display:flex; justify-content:space-between; align-items:flex-start; gap:16px; }
.activity-heading h4 { margin:0; font-size:18px; }
.activity-loading { color:var(--vp-c-text-3); font-size:13px; }
.activity-timeline { position:relative; display:grid; gap:0; padding:0; margin:18px 0; list-style:none; }
.activity-timeline::before { content:""; position:absolute; width:2px; left:6px; top:9px; bottom:9px; background:var(--vp-c-divider); }
.activity-timeline li { position:relative; display:grid; grid-template-columns:14px minmax(0,1fr); gap:13px; padding:0 0 17px; }
.activity-timeline li:last-child { padding-bottom:0; }
.activity-marker { position:relative; z-index:1; width:12px; height:12px; margin-top:5px; border:3px solid var(--vp-c-bg-soft); border-radius:50%; background:var(--vp-c-text-3); box-shadow:0 0 0 1px var(--vp-c-divider); }
.activity-post .activity-marker { background:var(--request-accent); }
.activity-status .activity-marker { background:var(--vp-c-brand-1); }
.activity-entry { min-width:0; }
.activity-entry > strong { font-size:14px; }
.activity-entry > time { display:block; margin-top:5px; color:var(--vp-c-text-3); font-size:11px; }
.activity-entry > p { margin:6px 0; color:var(--vp-c-text-2); font-size:13px; line-height:1.55; }
.activity-context,.activity-author { margin-left:6px; color:var(--vp-c-text-3); font-size:12px; }
.post-heading { display:flex; flex-wrap:wrap; align-items:center; gap:7px; }
.post-kind,.maintainer-badge,.moderation-badge { display:inline-flex; padding:3px 7px; border-radius:999px; font-size:10px; font-weight:800; letter-spacing:.04em; text-transform:uppercase; }
.post-kind { color:var(--request-accent); border:1px solid color-mix(in srgb,var(--request-accent) 38%,var(--vp-c-divider)); background:var(--vp-c-bg); }
.maintainer-badge { color:#225ca8; background:#e5efff; }
.dark .maintainer-badge { color:#b9d3ff; background:#172942; }
.post-body { white-space:pre-wrap; overflow-wrap:anywhere; }
.owner-actions { display:inline-flex; gap:10px; margin-top:7px; }
.owner-actions button { padding:0; border:0; color:var(--request-accent); background:transparent; font:inherit; font-size:12px; font-weight:700; text-decoration:underline; cursor:pointer; }
.owner-actions button:last-child { color:var(--vp-c-danger-1); }
.own-posts { padding:14px; margin:16px 0; border:1px dashed var(--vp-c-divider); border-radius:10px; background:var(--vp-c-bg); }
.own-posts h5 { margin:0 0 10px; font-size:14px; }
.own-post { padding:10px 0; border-top:1px solid var(--vp-c-divider); }
.own-post:first-of-type { padding-top:0; border-top:0; }
.own-post:last-child { padding-bottom:0; }
.own-post p { margin:7px 0 0; color:var(--vp-c-text-2); font-size:13px; white-space:pre-wrap; }
.moderation-badge { margin-left:6px; color:#795b00; background:#fff1bd; }
.moderation-hidden { color:var(--vp-c-danger-1); background:var(--vp-c-danger-soft); }
.community-post-form { padding:16px; margin-top:16px; border:1px solid var(--vp-c-divider); border-radius:10px; background:var(--vp-c-bg); }
.post-form-heading { margin-bottom:14px; }
.post-form-heading strong,.post-form-heading span { display:block; }
.post-form-heading span { margin-top:2px; color:var(--vp-c-text-3); font-size:12px; }
.close-post-form { width:30px; height:30px; border:1px solid var(--vp-c-divider); border-radius:50%; color:var(--vp-c-text-2); background:var(--vp-c-bg-soft); font-size:20px; cursor:pointer; }
.post-form-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.community-post-form label { display:block; margin-bottom:13px; }
.community-post-form label > span { display:block; margin-bottom:5px; font-size:12px; font-weight:700; }
.community-post-form label small { color:var(--vp-c-text-3); font-weight:400; }
.community-post-form input:not([type="checkbox"]),.community-post-form select,.community-post-form textarea { box-sizing:border-box; width:100%; border:1px solid var(--vp-c-divider); border-radius:8px; color:var(--vp-c-text-1); background:var(--vp-c-bg-soft); font:inherit; outline:none; }
.community-post-form input:not([type="checkbox"]),.community-post-form select { height:40px; padding:0 11px; }
.community-post-form textarea { padding:10px 11px; resize:vertical; }
.community-post-form input:focus,.community-post-form select:focus,.community-post-form textarea:focus { border-color:var(--request-accent); box-shadow:0 0 0 3px color-mix(in srgb,var(--request-accent) 15%,transparent); }
.post-privacy { color:var(--vp-c-text-3); font-size:11px; line-height:1.5; }
.honeypot { position:absolute !important; width:1px; height:1px; overflow:hidden; clip:rect(0,0,0,0); }
.add-contribution { margin-top:6px; }
.request-skeletons { display: grid; gap: 12px; }
.request-skeleton { height: 142px; border-radius: 14px; background: linear-gradient(90deg, var(--vp-c-bg-soft), var(--vp-c-bg-alt), var(--vp-c-bg-soft)); background-size: 200% 100%; animation: shimmer 1.4s infinite linear; }
@keyframes shimmer { to { background-position: -200% 0; } }
.empty-state { padding: 70px 20px; border: 1px dashed var(--vp-c-divider); border-radius: 14px; text-align: center; }
.empty-state > div { font-size: 38px; }
.empty-state h3 { margin: 10px 0 4px; }
.empty-state p { margin: 0 0 20px; color: var(--vp-c-text-2); }
.visually-hidden { position: absolute !important; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }
@media (max-width: 760px) {
  .request-hero { grid-template-columns: 1fr; gap: 30px; padding: 34px 24px; }
  .request-hero h1 { font-size: 38px; }
  .request-stats div { min-height: 96px; }
  .form-grid, .board-controls, .bulk-row-grid, .post-form-grid { grid-template-columns: 1fr; }
  .request-form-panel, .request-board { padding: 20px; }
  .request-card { grid-template-columns: 58px minmax(0, 1fr); gap: 14px; padding: 17px; }
  .vote-button { width: 56px; min-height: 82px; }
  .board-heading { align-items: center; }
  .bulk-review-heading { align-items: flex-start; flex-direction: column; }
  .discussion-toggle { align-items:flex-start; flex-direction:column; gap:3px; }
  .activity-panel { padding:14px; }
  .identity-panel, .identity-panel > div { align-items:flex-start; flex-direction:column; }
  .identity-actions { width:100%; flex-direction:row !important; flex-wrap:wrap; }
  .request-owner-tools { align-items:flex-start; flex-direction:column; }
}
</style>
