from pathlib import Path
import tempfile
import unittest

from tools.issue_plan_facts import (
    build_system,
    buildenv_info,
    definitions,
    grep_meta,
    issue_number,
    map_dependencies,
    parse_title,
    rank_templates,
    search_terms,
)


PACKAGES = {
    "cmake": {"version": "4.4.4", "runtime": [], "repo": "cmakeport"},
    "make": {"version": "4.4.1", "runtime": [], "repo": "makeport"},
    "openssl": {"version": "4.0.2", "runtime": [], "repo": "opensslport"},
    "m4": {"version": "1.4", "runtime": [], "repo": "m4port"},
    "flex": {"version": "2.6", "runtime": ["m4"], "repo": "flexport"},
}


class IssuePlanFactsTests(unittest.TestCase):
    def test_parse_title(self):
        self.assertEqual(parse_title("[New Port]: pre-commit"), ("new-port", "pre-commit"))
        self.assertEqual(parse_title("[New Port]: Foo Bar"), ("new-port", "foo-bar"))
        self.assertEqual(parse_title("[New Port]: hyperfineport"), ("new-port", "hyperfine"))
        self.assertEqual(parse_title("[New Python Port]: lxml"), ("new-python-port", "lxml"))
        self.assertEqual(parse_title("[New Port]: $(rm -rf /)"), ("new-port", "rm-rf"))
        self.assertEqual(parse_title("zopen-config leaves a trailing colon"), ("other", ""))

    def test_map_dependencies_uses_zopen_names_and_companions(self):
        mapped, missing = map_dependencies([("cmake", "build"), ("python@3.15", "runtime"), ("flex", "build"), ("openssl@4", "runtime"), ("llhttp", "runtime")], PACKAGES)
        self.assertEqual([m["zopen"] for m in mapped], ["make", "cmake", "check_python", "m4", "flex", "openssl"])
        self.assertEqual(mapped[0]["homebrew"], "(needed with cmake)")
        self.assertEqual(missing, ["llhttp"])

    def test_build_system(self):
        self.assertEqual(build_system(["pkgconf", "cmake"]), "CMake")
        self.assertEqual(build_system(["go"]), "Go")
        self.assertEqual(build_system(["python@3.15", "libyaml"]), "Python")
        self.assertEqual(build_system(["autoconf", "automake"]), "autotools")
        self.assertEqual(build_system(["openssl@3"]), "")

    def test_buildenv_info(self):
        self.assertEqual(buildenv_info('export ZOPEN_STABLE_DEPS="make cmake curl"\nexport ZOPEN_CONFIGURE="cmake"\n'), {"system": "CMake", "deps": ["cmake", "curl", "make"]})
        self.assertEqual(buildenv_info("export ZOPEN_CONFIGURE=\"skip\"\nexport ZOPEN_COMP=GO\n")["system"], "Go")
        self.assertEqual(buildenv_info('export ZOPEN_BUILD_SYSTEM="Python"\n')["system"], "Python")
        self.assertEqual(buildenv_info('export ZOPEN_BOOTSTRAP="autoreconf"\n')["system"], "autotools")

    def test_rank_templates_prefers_build_system(self):
        candidates = {
            "aport": {"system": "autotools", "deps": ["cmake", "make", "openssl", "zlib"]},
            "bport": {"system": "CMake", "deps": ["cmake", "make"]},
            "cport": {"system": "Go", "deps": []},
        }
        ranked = rank_templates(candidates, "CMake", {"cmake", "make", "openssl"})
        self.assertEqual([r["repo"] for r in ranked], ["bport", "aport"])
        self.assertEqual(ranked[0]["shared"], ["cmake", "make"])

    def test_search_terms(self):
        text = "Running `zopen install foo` fails in sanitizeEnvVar with FSUM7332 and zopen-config"
        self.assertEqual(search_terms(text), ["zopen-install", "zopen-config", "FSUM7332", "sanitizeEnvVar"])

    def test_grep_and_definitions(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "include").mkdir()
            (root / "bin").mkdir()
            (root / "include" / "common.sh").write_text("x=1\nsanitizeEnvVar()\n{\n  echo hi\n}\n\nother()\n{\n}\n")
            (root / "bin" / "zopen-install").write_text("# sanitizeEnvVar is used here\n")
            hits = grep_meta(root, ["zopen-install", "sanitizeEnvVar"])
            self.assertIn("`bin/zopen-install` is the `zopen-install` command", hits)
            self.assertIn("`include/common.sh:2` (sanitizeEnvVar): sanitizeEnvVar()", hits)
            blocks = definitions(root, ["sanitizeEnvVar"])
            self.assertEqual(blocks, ["`include/common.sh:2`:\n```sh\nsanitizeEnvVar()\n{\n  echo hi\n}\n```"])

    def test_issue_number_from_aw_context(self):
        import os
        os.environ["AW_CONTEXT"] = '{"item_type": "issue", "item_number": 1225}'
        try:
            self.assertEqual(issue_number(None), 1225)
            self.assertEqual(issue_number("7"), 7)
            os.environ["AW_CONTEXT"] = '{"item_type": "pull_request", "item_number": 3}'
            self.assertIsNone(issue_number(None))
        finally:
            del os.environ["AW_CONTEXT"]


if __name__ == "__main__":
    unittest.main()
