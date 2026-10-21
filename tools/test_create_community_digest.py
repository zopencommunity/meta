import datetime as dt
import unittest

from tools.create_community_digest import (
    classify_releases,
    month_window,
    parse_bump,
    parse_json_reply,
    period_name,
    short_description,
    render_digest,
    split_prs,
    validate_narrative,
)


def release(tool, date, build=1):
    return {
        "date": date,
        "tag_name": f"STABLE_{tool}port_{build}",
        "assets": [{"url": f"https://github.com/zopencommunity/{tool}port/releases/download/x/{tool}.pax.Z", "version": "1.0"}],
    }


class CommunityDigestTests(unittest.TestCase):
    def test_month_window_defaults_to_last_month(self):
        self.assertEqual(month_window(None, dt.date(2026, 10, 21)), (dt.date(2026, 9, 1), dt.date(2026, 9, 30)))
        self.assertEqual(month_window("2026-02"), (dt.date(2026, 2, 1), dt.date(2026, 2, 28)))
        self.assertEqual(month_window(None, dt.date(2027, 1, 5)), (dt.date(2026, 12, 1), dt.date(2026, 12, 31)))
        self.assertEqual(month_window("2026-07", through="2026-09"), (dt.date(2026, 7, 1), dt.date(2026, 9, 30)))
        self.assertEqual(period_name(dt.date(2026, 7, 1), dt.date(2026, 9, 30)), "July–September 2026")
        self.assertEqual(period_name(dt.date(2026, 9, 1), dt.date(2026, 9, 30)), "September 2026")

    def test_short_description(self):
        self.assertEqual(short_description("Csmith is a generator. Its purpose is testing."), "Csmith is a generator")
        self.assertEqual(short_description("  zopen port of fd.  "), "zopen port of fd")
        self.assertEqual(short_description("Creates projects, e.g. Python ones. More."), "Creates projects, e.g. Python ones")
        self.assertTrue(short_description("word " * 40).endswith("…"))

    def test_parse_bump(self):
        self.assertEqual(parse_bump("Update vim-version to 9.1.1 from 9.1.0"), {"tool": "vim", "new": "9.1.1", "old": "9.1.0"})
        self.assertEqual(parse_bump("Update libpcre2-version to 10.46 from 10.45")["tool"], "libpcre2")
        self.assertIsNone(parse_bump("zopen-init: Add RPM configuration"))

    def test_classify_releases(self):
        data = {
            "gdu": [release("gdu", "2026-09-10T00:00:00Z")],
            "vim": [release("vim", "2026-09-12T00:00:00Z", 2), release("vim", "2025-01-01T00:00:00Z", 1)],
            "jq": [release("jq", "2026-08-01T00:00:00Z")],
        }
        first, updated = classify_releases(data, dt.date(2026, 9, 1), dt.date(2026, 9, 30))
        self.assertEqual([e["tool"] for e in first], ["gdu"])
        self.assertEqual([e["tool"] for e in updated], ["vim"])
        self.assertEqual(first[0]["release_url"], "https://github.com/zopencommunity/gduport/releases/tag/STABLE_gduport_1")

    def test_split_prs_separates_bot_bumps(self):
        prs = [
            {"title": "Update vim-version to 2 from 1", "author": "zosopentoolsmain", "url": "u1", "number": 1},
            {"title": "Update vim-version to 2 from 1", "author": "alice", "url": "u2", "number": 2},
            {"title": "Fix tagging", "author": "bob", "url": "u3", "number": 3},
            {"title": "Merge branch", "author": "github-actions[bot]", "url": "u4", "number": 4},
        ]
        bumps, human = split_prs(prs)
        self.assertEqual([b["url"] for b in bumps], ["u1"])
        self.assertEqual([p["url"] for p in human], ["u2", "u3"])

    def test_parse_json_reply_ignores_fences(self):
        self.assertEqual(parse_json_reply('Here you go:\n```json\n{"intro": "x"}\n```'), {"intro": "x"})
        with self.assertRaises(ValueError):
            parse_json_reply("no json here")

    def test_validate_narrative_drops_unknown_links(self):
        narrative = {
            "intro": "A busy month.",
            "enhancements": [
                {"title": "vim", "summary": "Real.", "urls": ["https://github.com/zopencommunity/vimport/pull/1"]},
                {"title": "ghost", "summary": "Invented.", "urls": ["https://github.com/zopencommunity/x/pull/9"]},
                {"title": "nolink", "summary": "No source.", "urls": []},
            ],
            "fixes": None,
        }
        clean = validate_narrative(narrative, {"https://github.com/zopencommunity/vimport/pull/1"})
        self.assertEqual([i["title"] for i in clean["enhancements"]], ["vim"])
        self.assertEqual(clean["fixes"], [])
        self.assertEqual(validate_narrative({"intro": "See https://evil"}, set())["intro"], "")

    def test_render_without_model_lists_changes(self):
        facts = {
            "month_name": "September 2026",
            "new_tools": [{"tool": "gdu", "description": "Disk usage analyzer", "release_url": "R", "contributors": ["alice"]}],
            "new_python_packages": [{"tool": "uv", "description": "", "release_url": "U", "contributors": [], "dev": True}],
            "python_packages": [
                {"name": "uv", "release_key": "uv", "version": "1", "url": "U"},
                {"name": "lxml", "release_key": "lxml", "version": "6", "url": "L"},
            ],
            "python_totals": {"packages": 2, "wheels": 6},
            "rpm_packages": [],
            "human_prs": [{"repo": "zopencommunity/meta", "title": "Fix it", "number": 7, "url": "P", "author": "bob"}],
            "upstream_prs": [],
            "upgrades": [{"tool": "vim", "old": "1", "new": "2"}],
            "coming_soon": [],
            "contributors": ["alice", "bob"],
            "first_time_contributors": ["bob"],
        }
        text = render_digest(facts, None)
        self.assertIn("**[gdu](R)** – Disk usage analyzer. Thank you @alice!", text)
        self.assertIn("<summary><b>meta</b> (1)</summary>", text)
        self.assertIn("* Fix it ([#7](P) by @bob)", text)
        self.assertIn("* vim 1 → 2", text)
        self.assertIn("* **[uv](U)** _(dev build)_.", text)
        self.assertIn("Updated in September 2026: [lxml 6](L).", text)
        self.assertIn("first merged pull request, @bob!", text)


if __name__ == "__main__":
    unittest.main()
