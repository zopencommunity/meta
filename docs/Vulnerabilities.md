# Package Vulnerabilities

[Vulnerabilities RSS feed XML file](https://raw.githubusercontent.com/zopencommunity/meta/main/docs/vulnerabilities_rss.xml)

## vim

<details>
<summary>vim (Build 2178) - (STABLE) -- 3 medium vulnerabilities</summary>

- Affected release URL: [vim (Build 2178) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2178)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2204) - (STABLE) -- 3 medium vulnerabilities</summary>

- Affected release URL: [vim (Build 2204) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2204)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2224) - (STABLE) -- 3 medium vulnerabilities</summary>

- Affected release URL: [vim (Build 2224) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2224)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2253) - (STABLE) -- 3 medium vulnerabilities</summary>

- Affected release URL: [vim (Build 2253) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2253)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2265) - (STABLE) -- 3 medium vulnerabilities</summary>

- Affected release URL: [vim (Build 2265) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2265)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2271) - (STABLE) -- 3 medium vulnerabilities</summary>

- Affected release URL: [vim (Build 2271) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2271)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2389) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 2389) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2389)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2408) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 2408) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2408)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2421) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 2421) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2421)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

<details>
<summary>vim (Build 2423) - (Alpha) - Dataset I/O -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 2423) - (Alpha) - Dataset I/O](https://github.com/zopencommunity/vimport/releases/tag/datasetio)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)**.

</details>

## zlib

<details>
<summary>zlib (Build 2529) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [zlib (Build 2529) - (STABLE)](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_2529)

- **(CRITICAL severity) CVE-2023-45853**: MiniZip in zlib through 1.3 has an integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_64 via a long filename, comment, or extra field. NOTE: MiniZip is not a supported part of the zlib product. NOTE: pyminizip through 0.2.6 is also vulnerable because it bundles an affected zlib version, and exposes the applicable MiniZip code through its compress API.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_3574)**.

</details>

<details>
<summary>zlib (Build 2700) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [zlib (Build 2700) - (STABLE)](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_2700)

- **(CRITICAL severity) CVE-2023-45853**: MiniZip in zlib through 1.3 has an integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_64 via a long filename, comment, or extra field. NOTE: MiniZip is not a supported part of the zlib product. NOTE: pyminizip through 0.2.6 is also vulnerable because it bundles an affected zlib version, and exposes the applicable MiniZip code through its compress API.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_3574)**.

</details>

<details>
<summary>zlib (Build 2930) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [zlib (Build 2930) - (STABLE)](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_2930)

- **(CRITICAL severity) CVE-2023-45853**: MiniZip in zlib through 1.3 has an integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_64 via a long filename, comment, or extra field. NOTE: MiniZip is not a supported part of the zlib product. NOTE: pyminizip through 0.2.6 is also vulnerable because it bundles an affected zlib version, and exposes the applicable MiniZip code through its compress API.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_3574)**.

</details>

<details>
<summary>zlib (Build 2985) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [zlib (Build 2985) - (STABLE)](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_2985)

- **(CRITICAL severity) CVE-2023-45853**: MiniZip in zlib through 1.3 has an integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_64 via a long filename, comment, or extra field. NOTE: MiniZip is not a supported part of the zlib product. NOTE: pyminizip through 0.2.6 is also vulnerable because it bundles an affected zlib version, and exposes the applicable MiniZip code through its compress API.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/zlibport/releases/tag/STABLE_zlibport_3574)**.

</details>

## githubcli

<details>
<summary>githubcli (Build 2550) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [githubcli (Build 2550) - (STABLE)](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_2550)

- **(CRITICAL severity) CVE-2024-52308**: The GitHub CLI version 2.6.1 and earlier are vulnerable to remote code execution through a malicious codespace SSH server when using `gh codespace ssh` or `gh codespace logs` commands. This has been patched in the cli v2.62.0.

Developers connect to remote codespaces through an SSH server running within the devcontainer, which is generally provided through the [default devcontainer image]( https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-... https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers#using-the-default-dev-container-configuration) . GitHub CLI [retrieves SSH connection details]( https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/inv... https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/invoker.go#L230-L244 ), such as remote username, which is used in [executing `ssh` commands]( https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L2... https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L263 ) for `gh codespace ssh` or `gh codespace logs` commands.

This exploit occurs when a malicious third-party devcontainer contains a modified SSH server that injects `ssh` arguments within the SSH connection details. `gh codespace ssh` and `gh codespace logs` commands could execute arbitrary code on the user's workstation if the remote username contains something like `-oProxyCommand="echo hacked" #`.  The `-oProxyCommand` flag causes `ssh` to execute the provided command while `#` shell comment causes any other `ssh` arguments to be ignored.

In `2.62.0`, the remote username information is being validated before being used.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_3630)**.

</details>

<details>
<summary>githubcli (Build 2573) - (DEV) -- 1 critical vulnerability</summary>

- Affected release URL: [githubcli (Build 2573) - (DEV)](https://github.com/zopencommunity/githubcliport/releases/tag/DEV_githubcliport_2573)

- **(CRITICAL severity) CVE-2024-52308**: The GitHub CLI version 2.6.1 and earlier are vulnerable to remote code execution through a malicious codespace SSH server when using `gh codespace ssh` or `gh codespace logs` commands. This has been patched in the cli v2.62.0.

Developers connect to remote codespaces through an SSH server running within the devcontainer, which is generally provided through the [default devcontainer image]( https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-... https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers#using-the-default-dev-container-configuration) . GitHub CLI [retrieves SSH connection details]( https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/inv... https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/invoker.go#L230-L244 ), such as remote username, which is used in [executing `ssh` commands]( https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L2... https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L263 ) for `gh codespace ssh` or `gh codespace logs` commands.

This exploit occurs when a malicious third-party devcontainer contains a modified SSH server that injects `ssh` arguments within the SSH connection details. `gh codespace ssh` and `gh codespace logs` commands could execute arbitrary code on the user's workstation if the remote username contains something like `-oProxyCommand="echo hacked" #`.  The `-oProxyCommand` flag causes `ssh` to execute the provided command while `#` shell comment causes any other `ssh` arguments to be ignored.

In `2.62.0`, the remote username information is being validated before being used.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_3630)**.

</details>

<details>
<summary>githubcli (Build 2995) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [githubcli (Build 2995) - (STABLE)](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_2995)

- **(CRITICAL severity) CVE-2024-52308**: The GitHub CLI version 2.6.1 and earlier are vulnerable to remote code execution through a malicious codespace SSH server when using `gh codespace ssh` or `gh codespace logs` commands. This has been patched in the cli v2.62.0.

Developers connect to remote codespaces through an SSH server running within the devcontainer, which is generally provided through the [default devcontainer image]( https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-... https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers#using-the-default-dev-container-configuration) . GitHub CLI [retrieves SSH connection details]( https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/inv... https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/invoker.go#L230-L244 ), such as remote username, which is used in [executing `ssh` commands]( https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L2... https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L263 ) for `gh codespace ssh` or `gh codespace logs` commands.

This exploit occurs when a malicious third-party devcontainer contains a modified SSH server that injects `ssh` arguments within the SSH connection details. `gh codespace ssh` and `gh codespace logs` commands could execute arbitrary code on the user's workstation if the remote username contains something like `-oProxyCommand="echo hacked" #`.  The `-oProxyCommand` flag causes `ssh` to execute the provided command while `#` shell comment causes any other `ssh` arguments to be ignored.

In `2.62.0`, the remote username information is being validated before being used.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_3630)**.

</details>

## grafana

<details>
<summary>grafana (Build 2267) - (STABLE) -- 1 high vulnerability</summary>

- Affected release URL: [grafana (Build 2267) - (STABLE)](https://github.com/zopencommunity/grafanaport/releases/tag/STABLE_grafanaport_67)

- **(HIGH severity) CVE-2024-9264**: The SQL Expressions experimental feature of Grafana allows for the evaluation of `duckdb` queries containing user input. These queries are insufficiently sanitized before being passed to `duckdb`, leading to a command injection and local file inclusion vulnerability. Any user with the VIEWER or higher permission is capable of executing this attack.  The `duckdb` binary must be present in Grafana's $PATH for this attack to function; by default, this binary is not installed in Grafana distributions.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/grafanaport/releases/tag/STABLE_grafanaport_2268)**.

</details>

