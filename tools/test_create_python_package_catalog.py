import unittest

from tools.create_python_package_catalog import (
    build_catalog,
    normalize_name,
    python_versions_for_wheel,
    version_from_wheel,
)


class PythonPackageCatalogTests(unittest.TestCase):
    def test_normalizes_python_project_names(self):
        self.assertEqual(normalize_name("zope.interface"), "zope-interface")
        self.assertEqual(normalize_name("pydantic_core"), "pydantic-core")

    def test_extracts_supported_interpreters(self):
        self.assertEqual(
            python_versions_for_wheel("demo-1.0-cp312-none-any.whl"),
            {"3.12"},
        )
        self.assertEqual(
            python_versions_for_wheel("demo-1.0-py3-none-any.whl"),
            {"3.12", "3.13", "3.14"},
        )
        self.assertEqual(version_from_wheel("pydantic_core-2.46.4-1-cp312-none-any.whl"), "2.46.4")

    def test_builds_catalog_and_hides_upload_test(self):
        root = """
        <a href="demo/">Demo</a>
        <a href="zopen-pulp-upload-test/">zopen-pulp-upload-test</a>
        """
        package_pages = {
            "demo": """
                <a href="demo-2.0-cp312-none-any.whl">demo-2.0-cp312-none-any.whl</a>
                <a href="demo-2.0-cp313-none-any.whl">demo-2.0-cp313-none-any.whl</a>
            """,
        }
        releases = {
            "release_data": {
                "demo": [{
                    "date": "2026-08-24T12:00:00Z",
                    "tag_name": "STABLE_demoport_1",
                    "assets": [{
                        "version": "2.0",
                        "categories": "development library",
                        "runtime_dependencies": "check_python meta openssl",
                        "passed_tests": "9",
                        "total_tests": "10",
                    }],
                }],
            },
        }
        descriptions = {"descriptions": {"demo": "Demo package"}}

        catalog = build_catalog(root, package_pages, releases, descriptions)

        self.assertEqual(catalog["packageCount"], 1)
        self.assertEqual(catalog["wheelCount"], 2)
        package = catalog["packages"][0]
        self.assertEqual(package["version"], "2.0")
        self.assertEqual(package["pythonVersions"], ["3.12", "3.13"])
        self.assertEqual(package["runtimeDependencies"], ["openssl"])
        self.assertEqual(package["verificationRate"], 90.0)


if __name__ == "__main__":
    unittest.main()
