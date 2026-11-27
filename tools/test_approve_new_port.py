import os
from pathlib import Path
import subprocess
import tempfile
import textwrap
import unittest


WORKFLOW = (Path(__file__).resolve().parents[1] /
            ".github/workflows/approve_new_port.yml").read_text()


def run_block(name):
    lines = WORKFLOW.splitlines()
    start = lines.index(f"    - name: {name}")
    start = lines.index("      run: |", start) + 1
    end = start
    while end < len(lines) and (not lines[end] or lines[end].startswith("        ")):
        end += 1
    return textwrap.dedent("\n".join(lines[start:end]))


class ApproveNewPortTests(unittest.TestCase):
    def run_step(self, name, **overrides):
        with tempfile.TemporaryDirectory() as tmp:
            env_file = Path(tmp) / "env"
            calls_file = Path(tmp) / "calls"
            env = {
                **os.environ,
                "GITHUB_ENV": str(env_file),
                "CALL_LOG": str(calls_file),
                "GH_TOKEN": "mock-installation",
                "COMMENT_TOKEN": "mock-comments",
                "ORGANIZATION": "zopencommunity",
                "PORT_NAME": "foo",
                "ISSUE_NUMBER": "123",
                "ISSUE_CREATOR": "requester",
                "HTTP_STATUS": "404",
                "CREATE_RESULT": "0",
                "GRANT_RESULT": "0",
                **overrides,
            }
            mock = """
                gh() {
                    printf '%s\\t' "$GH_TOKEN" "$@" >> "$CALL_LOG"
                    printf '\\n' >> "$CALL_LOG"
                    case "$*" in
                        "api --include "*)
                            if [ "$HTTP_STATUS" = network ]; then
                                echo "network error"
                                return 1
                            fi
                            printf 'HTTP/2.0 %s Noted\\n\\n{}\\n' "$HTTP_STATUS"
                            [ "$HTTP_STATUS" = 200 ]
                            ;;
                        "api --method POST "*) return "$CREATE_RESULT" ;;
                        "api --method PUT "*) return "$GRANT_RESULT" ;;
                        "issue comment "*) return 0 ;;
                        *) return 99 ;;
                    esac
                }
            """
            result = subprocess.run(
                ["bash", "-e", "-o", "pipefail", "-c",
                 textwrap.dedent(mock) + run_block(name)],
                env=env, capture_output=True, text=True,
            )
            calls = calls_file.read_text().splitlines() if calls_file.exists() else []
            output = env_file.read_text() if env_file.exists() else ""
            return result, calls, output

    def test_valid_names_keep_existing_normalization(self):
        for title, port in [
            ("[New Port]: Foo Bar", "foobar"),
            ("[New Port]: msgpack-c", "msgpack-c"),
            ("[New Port]: foo_1.2", "foo_1.2"),
            ("a" * 96, "a" * 96),
        ]:
            with self.subTest(title=title):
                result, calls, output = self.run_step(
                    "Extract Port Name", GITHUB_EVENT_ISSUE_TITLE=title)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(output, f"PORT_NAME={port}\n")
                self.assertEqual(calls, [])

    def test_unsafe_names_never_write_environment(self):
        for name in ["", " ", "foo\nGH_TOKEN=injected", "foo\rbar",
                     "../foo", "$(echo unsafe)", "foo:bar", "a" * 97]:
            with self.subTest(name=name):
                result, calls, output = self.run_step(
                    "Extract Port Name", GITHUB_EVENT_ISSUE_TITLE=f"[New Port]: {name}")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(output, "")
                self.assertEqual(calls, [])

    def test_only_404_creates_public_repository(self):
        result, calls, _ = self.run_step("Check if Repository Exists")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(calls), 2)
        self.assertIn("mock-installation\tapi\t--method\tPOST\torgs/zopencommunity/repos"
                      "\t-f\tname=fooport\t-F\tprivate=false", calls[1])

    def test_duplicate_comments_without_creating(self):
        result, calls, _ = self.run_step("Check if Repository Exists", HTTP_STATUS="200")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 2)
        self.assertTrue(calls[1].startswith("mock-comments\tissue\tcomment\t123\t"))
        self.assertIn("Repository already exists: https://github.com/zopencommunity/fooport", calls[1])

    def test_other_errors_fail_closed(self):
        for status in ["401", "403", "429", "500", "network", ""]:
            with self.subTest(status=status):
                result, calls, _ = self.run_step(
                    "Check if Repository Exists", HTTP_STATUS=status)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(len(calls), 1)

    def test_creation_failure_stops_workflow(self):
        result, calls, _ = self.run_step("Check if Repository Exists", CREATE_RESULT="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 2)

    def test_admin_grant_uses_fresh_token_and_comment_uses_workflow_token(self):
        result, calls, _ = self.run_step(
            "Assign Admin and Comment", GH_TOKEN="mock-fresh-installation")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("mock-fresh-installation\tapi\t--method\tPUT\t"
                      "repos/zopencommunity/fooport/collaborators/requester\t-f\tpermission=admin",
                      calls[0])
        self.assertTrue(calls[1].startswith("mock-comments\tissue\tcomment\t123\t"))
        self.assertIn("Repository created: https://github.com/zopencommunity/fooport", calls[1])

    def test_grant_failure_does_not_post_success(self):
        result, calls, _ = self.run_step("Assign Admin and Comment", GRANT_RESULT="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)

    def test_authentication_and_step_order(self):
        self.assertIn("types: [labeled]", WORKFLOW)
        self.assertIn("if: github.event.label.name == 'approved'", WORKFLOW)
        self.assertIn("permissions:\n  issues: write\n", WORKFLOW)
        for obsolete in ["REPO_GITHUB_TOKEN", "gh api user", "actions/checkout",
                         "gh repo create", "repositories:"]:
            self.assertNotIn(obsolete, WORKFLOW)
        self.assertEqual(WORKFLOW.count("uses: actions/create-github-app-token@v3.3.0"), 2)
        self.assertEqual(WORKFLOW.count("owner: zopencommunity"), 2)
        self.assertEqual(WORKFLOW.count("permission-administration: write"), 2)
        self.assertEqual(WORKFLOW.count("app-id: ${{ secrets.MERGE_APP_ID }}"), 2)
        self.assertEqual(WORKFLOW.count("private-key: ${{ secrets.MERGE_APP_PRIVATE_KEY }}"), 2)
        self.assertIn("GH_TOKEN: ${{ steps.collaborator-token.outputs.token }}", WORKFLOW)
        self.assertLess(WORKFLOW.index("gh api --method POST"),
                        WORKFLOW.index("- name: Generate Collaborator Token"))
        for name in ["Extract Port Name", "Check if Repository Exists", "Assign Admin and Comment"]:
            self.assertNotIn("${{", run_block(name))


if __name__ == "__main__":
    unittest.main()
