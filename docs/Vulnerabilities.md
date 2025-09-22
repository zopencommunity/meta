# Package Vulnerabilities

[Vulnerabilities RSS feed XML file](https://raw.githubusercontent.com/zopencommunity/meta/main/docs/vulnerabilities_rss.xml)

## vim

<details>
<summary>vim (Build 2178) - (STABLE) -- 13 vulnerabilities (3 high, 10 medium)</summary>

- Affected release URL: [vim (Build 2178) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2178)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43374**: The UNIX editor Vim prior to version 9.1.0678 has a use-after-free error in argument list handling. When adding a new file to the argument list, this triggers `Buf*` autocommands. If in such an autocommand the buffer that was just opened is closed (including the window where it is shown), this causes the window structure to be freed which contains a reference to the argument list that we are actually modifying. Once the autocommands are completed, the references to the window and argument list are no longer valid and as such cause an use-after-free. Impact is low since the user must either intentionally add some unusual autocommands that wipe a buffer during creation (either manually or by sourcing a malicious plugin), but it will crash Vim. The issue has been fixed as of Vim patch v9.1.0678.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2204) - (STABLE) -- 13 vulnerabilities (3 high, 10 medium)</summary>

- Affected release URL: [vim (Build 2204) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2204)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43374**: The UNIX editor Vim prior to version 9.1.0678 has a use-after-free error in argument list handling. When adding a new file to the argument list, this triggers `Buf*` autocommands. If in such an autocommand the buffer that was just opened is closed (including the window where it is shown), this causes the window structure to be freed which contains a reference to the argument list that we are actually modifying. Once the autocommands are completed, the references to the window and argument list are no longer valid and as such cause an use-after-free. Impact is low since the user must either intentionally add some unusual autocommands that wipe a buffer during creation (either manually or by sourcing a malicious plugin), but it will crash Vim. The issue has been fixed as of Vim patch v9.1.0678.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2224) - (STABLE) -- 13 vulnerabilities (3 high, 10 medium)</summary>

- Affected release URL: [vim (Build 2224) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2224)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43374**: The UNIX editor Vim prior to version 9.1.0678 has a use-after-free error in argument list handling. When adding a new file to the argument list, this triggers `Buf*` autocommands. If in such an autocommand the buffer that was just opened is closed (including the window where it is shown), this causes the window structure to be freed which contains a reference to the argument list that we are actually modifying. Once the autocommands are completed, the references to the window and argument list are no longer valid and as such cause an use-after-free. Impact is low since the user must either intentionally add some unusual autocommands that wipe a buffer during creation (either manually or by sourcing a malicious plugin), but it will crash Vim. The issue has been fixed as of Vim patch v9.1.0678.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2253) - (STABLE) -- 13 vulnerabilities (3 high, 10 medium)</summary>

- Affected release URL: [vim (Build 2253) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2253)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43374**: The UNIX editor Vim prior to version 9.1.0678 has a use-after-free error in argument list handling. When adding a new file to the argument list, this triggers `Buf*` autocommands. If in such an autocommand the buffer that was just opened is closed (including the window where it is shown), this causes the window structure to be freed which contains a reference to the argument list that we are actually modifying. Once the autocommands are completed, the references to the window and argument list are no longer valid and as such cause an use-after-free. Impact is low since the user must either intentionally add some unusual autocommands that wipe a buffer during creation (either manually or by sourcing a malicious plugin), but it will crash Vim. The issue has been fixed as of Vim patch v9.1.0678.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2265) - (STABLE) -- 13 vulnerabilities (3 high, 10 medium)</summary>

- Affected release URL: [vim (Build 2265) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2265)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43374**: The UNIX editor Vim prior to version 9.1.0678 has a use-after-free error in argument list handling. When adding a new file to the argument list, this triggers `Buf*` autocommands. If in such an autocommand the buffer that was just opened is closed (including the window where it is shown), this causes the window structure to be freed which contains a reference to the argument list that we are actually modifying. Once the autocommands are completed, the references to the window and argument list are no longer valid and as such cause an use-after-free. Impact is low since the user must either intentionally add some unusual autocommands that wipe a buffer during creation (either manually or by sourcing a malicious plugin), but it will crash Vim. The issue has been fixed as of Vim patch v9.1.0678.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2271) - (STABLE) -- 13 vulnerabilities (3 high, 10 medium)</summary>

- Affected release URL: [vim (Build 2271) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2271)

- **(MEDIUM severity) CVE-2024-41957**: Vim is an open source command line text editor. Vim < v9.1.0647 has double free in src/alloc.c:616. When closing a window, the corresponding tagstack data will be cleared and freed. However a bit later, the quickfix list belonging to that window will also be cleared and if that quickfix list points to the same tagstack data, Vim will try to free it again, resulting in a double-free/use-after-free access exception. Impact is low since the user must intentionally execute vim with several non-default flags,
but it may cause a crash of Vim. The issue has been fixed as of Vim patch v9.1.0647
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-41965**: Vim is an open source command line text editor. double-free in dialog_changed() in Vim < v9.1.0648. When abandoning a buffer, Vim may ask the user what to do with the modified buffer. If the user wants the changed buffer to be saved, Vim may create a new Untitled file, if the buffer did not have a name yet. However, when setting the buffer name to Unnamed, Vim will falsely free a pointer twice, leading to a double-free and possibly later to a heap-use-after-free, which can lead to a crash. The issue has been fixed as of Vim patch v9.1.0648.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43374**: The UNIX editor Vim prior to version 9.1.0678 has a use-after-free error in argument list handling. When adding a new file to the argument list, this triggers `Buf*` autocommands. If in such an autocommand the buffer that was just opened is closed (including the window where it is shown), this causes the window structure to be freed which contains a reference to the argument list that we are actually modifying. Once the autocommands are completed, the references to the window and argument list are no longer valid and as such cause an use-after-free. Impact is low since the user must either intentionally add some unusual autocommands that wipe a buffer during creation (either manually or by sourcing a malicious plugin), but it will crash Vim. The issue has been fixed as of Vim patch v9.1.0678.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2389) - (STABLE) -- 10 vulnerabilities (3 high, 7 medium)</summary>

- Affected release URL: [vim (Build 2389) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2389)

- **(MEDIUM severity) CVE-2024-43790**: Vim is an open source command line text editor. When performing a search and displaying the search-count message is disabled (:set shm+=S), the search pattern is displayed at the bottom of the screen in a buffer (msgbuf). When right-left mode (:set rl) is enabled, the search pattern is reversed. This happens by allocating a new buffer. If the search pattern contains some ASCII NUL characters, the buffer allocated will be smaller than the original allocated buffer (because for allocating the reversed buffer, the strlen() function is called, which only counts until it notices an ASCII NUL byte ) and thus the original length indicator is wrong. This causes an overflow when accessing characters inside the msgbuf by the previously (now wrong) length of the msgbuf. The issue has been fixed as of Vim patch v9.1.0689.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2408) - (STABLE) -- 9 vulnerabilities (3 high, 6 medium)</summary>

- Affected release URL: [vim (Build 2408) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2408)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2421) - (STABLE) -- 9 vulnerabilities (3 high, 6 medium)</summary>

- Affected release URL: [vim (Build 2421) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2421)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2423) - (Alpha) - Dataset I/O -- 9 vulnerabilities (3 high, 6 medium)</summary>

- Affected release URL: [vim (Build 2423) - (Alpha) - Dataset I/O](https://github.com/zopencommunity/vimport/releases/tag/datasetio)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2436) - (STABLE) -- 8 vulnerabilities (3 high, 5 medium)</summary>

- Affected release URL: [vim (Build 2436) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2436)

- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2461) - (STABLE) -- 8 vulnerabilities (3 high, 5 medium)</summary>

- Affected release URL: [vim (Build 2461) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2461)

- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2493) - (STABLE) -- 8 vulnerabilities (3 high, 5 medium)</summary>

- Affected release URL: [vim (Build 2493) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2493)

- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2697) - (STABLE) -- 8 vulnerabilities (3 high, 5 medium)</summary>

- Affected release URL: [vim (Build 2697) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2697)

- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2736) - (STABLE) -- 7 vulnerabilities (3 high, 4 medium)</summary>

- Affected release URL: [vim (Build 2736) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2736)

- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2810) - (STABLE) -- 6 vulnerabilities (3 high, 3 medium)</summary>

- Affected release URL: [vim (Build 2810) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2810)

- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 2958) - (STABLE) -- 6 vulnerabilities (3 high, 3 medium)</summary>

- Affected release URL: [vim (Build 2958) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_2958)

- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3052) - (STABLE) -- 6 vulnerabilities (3 high, 3 medium)</summary>

- Affected release URL: [vim (Build 3052) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3052)

- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3107) - (STABLE) -- 4 vulnerabilities (2 high, 2 medium)</summary>

- Affected release URL: [vim (Build 3107) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3107)

- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3115) - (STABLE) -- 4 vulnerabilities (2 high, 2 medium)</summary>

- Affected release URL: [vim (Build 3115) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3115)

- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim 9.1.1016.0 (zusage) - (STABLE) -- 6 vulnerabilities (3 high, 3 medium)</summary>

- Affected release URL: [vim 9.1.1016.0 (zusage) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/zusage)

- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3153) - (STABLE) -- 4 vulnerabilities (2 high, 2 medium)</summary>

- Affected release URL: [vim (Build 3153) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3153)

- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3192) - (STABLE) -- 4 vulnerabilities (2 high, 2 medium)</summary>

- Affected release URL: [vim (Build 3192) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3192)

- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3315) - (STABLE) -- 4 vulnerabilities (2 high, 2 medium)</summary>

- Affected release URL: [vim (Build 3315) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3315)

- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3334) - (STABLE) -- 3 vulnerabilities (2 high, 1 medium)</summary>

- Affected release URL: [vim (Build 3334) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3334)

- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3351) - (STABLE) -- 3 vulnerabilities (2 high, 1 medium)</summary>

- Affected release URL: [vim (Build 3351) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3351)

- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3365) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3365) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3365)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3404) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3404) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3404)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3406) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3406) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3406)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3429) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3429) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3429)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3437) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3437) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3437)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3438) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3438) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3438)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3457) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3457) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3457)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3463) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3463) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3463)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3473) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3473) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3473)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3474) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3474) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3474)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3495) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3495) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3495)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3515) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3515) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3515)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3529) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3529) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3529)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3542) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3542) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3542)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3551) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3551) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3551)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3560) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3560) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3560)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3569) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3569) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3569)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3585) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3585) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3585)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3594) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3594) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3594)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3601) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3601) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3601)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim (Build 3632) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [vim (Build 3632) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3632)

- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

<details>
<summary>vim 9.1.697 (datasetio_ispf) - (STABLE) -- 9 vulnerabilities (3 high, 6 medium)</summary>

- Affected release URL: [vim 9.1.697 (datasetio_ispf) - (STABLE)](https://github.com/zopencommunity/vimport/releases/tag/datasetio_ispf)

- **(MEDIUM severity) CVE-2024-45306**: Vim is an open source, command line text editor. Patch v9.1.0038 optimized how the cursor position is calculated and removed a loop, that verified that the cursor position always points inside a line and does not become invalid by pointing beyond the end of
a line. Back then we assumed this loop is unnecessary. However, this change made it possible that the cursor position stays invalid and points beyond the end of a line, which would eventually cause a heap-buffer-overflow when trying to access the line pointer at
the specified cursor position. It's not quite clear yet, what can lead to this situation that the cursor points to an invalid position. That's why patch v9.1.0707 does not include a test case. The only observed impact has been a program crash. This issue has been addressed in with the patch v9.1.0707. All users are advised to upgrade.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2024-47814**: Vim is an open source, command line text editor. A use-after-free was found in Vim < 9.1.0764. When closing a buffer (visible in a window) a BufWinLeave auto command can cause an use-after-free if this auto command happens to re-open the same buffer in a new split window. Impact is low since the user must have intentionally set up such a strange auto command and run some buffer unload commands. However this may lead to a crash. This issue has been addressed in version 9.1.0764 and all users are advised to upgrade. There are no known workarounds for this vulnerability.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-1215**: A vulnerability classified as problematic was found in vim up to 9.1.1096. This vulnerability affects unknown code of the file src/main.c. The manipulation of the argument --log leads to memory corruption. It is possible to launch the attack on the local host. Upgrading to version 9.1.1097 is able to address this issue. The patch is identified as c5654b84480822817bb7b69ebc97c174c91185e9. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-22134**: When switching to other buffers using the :all command and visual mode still being active, this may cause a heap-buffer overflow, because Vim does not properly end visual mode and therefore may try to access beyond the end of a line in a buffer. In Patch 9.1.1003 Vim will correctly reset the visual mode before opening other windows and buffers and therefore fix this bug. In addition it does verify that it won't try to access a position if the position is greater than the corresponding buffer line. Impact is medium since the user must have switched on visual mode when executing the :all ex command. The Vim project would like to thank github user gandalf4a for reporting this issue. The issue has been fixed as of Vim patch v9.1.1003
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-24014**: Vim is an open source, command line text editor. A segmentation fault was found in Vim before 9.1.1043. In silent Ex mode (-s -e), Vim typically doesn't show a screen and just operates silently in batch mode. However, it is still possible to trigger the function that handles the scrolling of a gui version of Vim by feeding some binary characters to Vim. The function that handles the scrolling however may be triggering a redraw, which will access the ScreenLines pointer, even so this variable hasn't been allocated (since there is no screen). This vulnerability is fixed in 9.1.1043.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-29768**: Vim, a text editor, is vulnerable to potential data loss with zip.vim and special crafted zip files in versions prior to 9.1.1198. The impact is medium because a user must be made to view such an archive with Vim and then press 'x' on such a strange filename. The issue has been fixed as of Vim patch v9.1.1198.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55157**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1400, When processing nested tuples in Vim script, an error during evaluation can trigger a use-after-free in Vim’s internal tuple reference management. Specifically, the tuple_unref() function may access already freed memory due to improper lifetime handling, leading to memory corruption. The exploit requires direct user interaction, as the script must be explicitly executed within Vim. This issue has been patched in version 9.1.1400.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(HIGH severity) CVE-2025-55158**: Vim is an open source, command line text editor. In versions from 9.1.1231 to before 9.1.1406, when processing nested tuples during Vim9 script import operations, an error during evaluation can trigger a double-free in Vim’s internal typed value (typval_T) management. Specifically, the clear_tv() function may attempt to free memory that has already been deallocated, due to improper lifetime handling in the handle_import / ex_import code paths. The vulnerability can only be triggered if a user explicitly opens and executes a specially crafted Vim script. This issue has been patched in version 9.1.1406.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.
- **(MEDIUM severity) CVE-2025-9390**: A security flaw has been discovered in vim up to 9.1.1615. Affected by this vulnerability is the function main of the file src/xxd/xxd.c of the component xxd. The manipulation results in buffer overflow. The attack requires a local approach. The exploit has been released to the public and may be exploited. Upgrading to version 9.1.1616 addresses this issue. The patch is identified as eeef7c77436a78cd27047b0f5fa6925d56de3cb0. It is recommended to upgrade the affected component.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/vimport/releases/tag/STABLE_vimport_3745)**.

</details>

## cmake

<details>
<summary>cmake (Build 2795) - (STABLE) -- 1 low vulnerability</summary>

- Affected release URL: [cmake (Build 2795) - (STABLE)](https://github.com/zopencommunity/cmakeport/releases/tag/STABLE_cmakeport_2795)

- **(LOW severity) CVE-2025-9301**: A vulnerability was determined in cmake 4.1.20250725-gb5cce23. This affects the function cmForEachFunctionBlocker::ReplayItems of the file cmForEachCommand.cxx. This manipulation causes reachable assertion. The attack needs to be launched locally. The exploit has been publicly disclosed and may be utilized. Patch name: 37e27f71bc356d880c908040cd0cb68fa2c371b8. It is suggested to install a patch to address this issue.
  - **Currently no fix -- still affects the [latest release](https://github.com/zopencommunity/cmakeport/releases/tag/STABLE_cmakeport_3201)**.

</details>

<details>
<summary>cmake (Build 2914) - (STABLE) -- 1 low vulnerability</summary>

- Affected release URL: [cmake (Build 2914) - (STABLE)](https://github.com/zopencommunity/cmakeport/releases/tag/STABLE_cmakeport_2914)

- **(LOW severity) CVE-2025-9301**: A vulnerability was determined in cmake 4.1.20250725-gb5cce23. This affects the function cmForEachFunctionBlocker::ReplayItems of the file cmForEachCommand.cxx. This manipulation causes reachable assertion. The attack needs to be launched locally. The exploit has been publicly disclosed and may be utilized. Patch name: 37e27f71bc356d880c908040cd0cb68fa2c371b8. It is suggested to install a patch to address this issue.
  - **Currently no fix -- still affects the [latest release](https://github.com/zopencommunity/cmakeport/releases/tag/STABLE_cmakeport_3201)**.

</details>

<details>
<summary>cmake (Build 3201) - (STABLE) -- 1 low vulnerability</summary>

- Affected release URL: [cmake (Build 3201) - (STABLE)](https://github.com/zopencommunity/cmakeport/releases/tag/STABLE_cmakeport_3201)

- **(LOW severity) CVE-2025-9301**: A vulnerability was determined in cmake 4.1.20250725-gb5cce23. This affects the function cmForEachFunctionBlocker::ReplayItems of the file cmForEachCommand.cxx. This manipulation causes reachable assertion. The attack needs to be launched locally. The exploit has been publicly disclosed and may be utilized. Patch name: 37e27f71bc356d880c908040cd0cb68fa2c371b8. It is suggested to install a patch to address this issue.
  - **Currently no fix -- this is the latest release**.
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

## redis

<details>
<summary>redis (Build 3219) - (STABLE) -- 2 vulnerabilities (1 critical, 1 high)</summary>

- Affected release URL: [redis (Build 3219) - (STABLE)](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3219)

- **(CRITICAL severity) CVE-2025-27151**: Redis is an open source, in-memory database that persists on disk. In versions starting from 7.0.0 to before 8.0.2, a stack-based buffer overflow exists in redis-check-aof due to the use of memcpy with strlen(filepath) when copying a user-supplied file path into a fixed-size stack buffer. This allows an attacker to overflow the stack and potentially achieve code execution. This issue has been patched in version 8.0.2.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.
- **(HIGH severity) CVE-2025-32023**: Redis is an open source, in-memory database that persists on disk. From 2.8 to before 8.0.3, 7.4.5, 7.2.10, and 6.2.19, an authenticated user may use a specially crafted string to trigger a stack/heap out of bounds write on hyperloglog operations, potentially leading to remote code execution. The bug likely affects all Redis versions with hyperloglog operations implemented. This vulnerability is fixed in 8.0.3, 7.4.5, 7.2.10, and 6.2.19. An additional workaround to mitigate the problem without patching the redis-server executable is to prevent users from executing hyperloglog operations. This can be done using ACL to restrict HLL commands.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.

</details>

<details>
<summary>redis (Build 3258) - (STABLE) -- 2 vulnerabilities (1 critical, 1 high)</summary>

- Affected release URL: [redis (Build 3258) - (STABLE)](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3258)

- **(CRITICAL severity) CVE-2025-27151**: Redis is an open source, in-memory database that persists on disk. In versions starting from 7.0.0 to before 8.0.2, a stack-based buffer overflow exists in redis-check-aof due to the use of memcpy with strlen(filepath) when copying a user-supplied file path into a fixed-size stack buffer. This allows an attacker to overflow the stack and potentially achieve code execution. This issue has been patched in version 8.0.2.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.
- **(HIGH severity) CVE-2025-32023**: Redis is an open source, in-memory database that persists on disk. From 2.8 to before 8.0.3, 7.4.5, 7.2.10, and 6.2.19, an authenticated user may use a specially crafted string to trigger a stack/heap out of bounds write on hyperloglog operations, potentially leading to remote code execution. The bug likely affects all Redis versions with hyperloglog operations implemented. This vulnerability is fixed in 8.0.3, 7.4.5, 7.2.10, and 6.2.19. An additional workaround to mitigate the problem without patching the redis-server executable is to prevent users from executing hyperloglog operations. This can be done using ACL to restrict HLL commands.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.

</details>

<details>
<summary>redis (Build 3427) - (STABLE) -- 1 high vulnerability</summary>

- Affected release URL: [redis (Build 3427) - (STABLE)](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3427)

- **(HIGH severity) CVE-2025-32023**: Redis is an open source, in-memory database that persists on disk. From 2.8 to before 8.0.3, 7.4.5, 7.2.10, and 6.2.19, an authenticated user may use a specially crafted string to trigger a stack/heap out of bounds write on hyperloglog operations, potentially leading to remote code execution. The bug likely affects all Redis versions with hyperloglog operations implemented. This vulnerability is fixed in 8.0.3, 7.4.5, 7.2.10, and 6.2.19. An additional workaround to mitigate the problem without patching the redis-server executable is to prevent users from executing hyperloglog operations. This can be done using ACL to restrict HLL commands.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.

</details>

<details>
<summary>redis (Build 3466) - (STABLE) -- 1 high vulnerability</summary>

- Affected release URL: [redis (Build 3466) - (STABLE)](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3466)

- **(HIGH severity) CVE-2025-32023**: Redis is an open source, in-memory database that persists on disk. From 2.8 to before 8.0.3, 7.4.5, 7.2.10, and 6.2.19, an authenticated user may use a specially crafted string to trigger a stack/heap out of bounds write on hyperloglog operations, potentially leading to remote code execution. The bug likely affects all Redis versions with hyperloglog operations implemented. This vulnerability is fixed in 8.0.3, 7.4.5, 7.2.10, and 6.2.19. An additional workaround to mitigate the problem without patching the redis-server executable is to prevent users from executing hyperloglog operations. This can be done using ACL to restrict HLL commands.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.

</details>

<details>
<summary>redis (Build 3497) - (STABLE) -- 1 high vulnerability</summary>

- Affected release URL: [redis (Build 3497) - (STABLE)](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3497)

- **(HIGH severity) CVE-2025-32023**: Redis is an open source, in-memory database that persists on disk. From 2.8 to before 8.0.3, 7.4.5, 7.2.10, and 6.2.19, an authenticated user may use a specially crafted string to trigger a stack/heap out of bounds write on hyperloglog operations, potentially leading to remote code execution. The bug likely affects all Redis versions with hyperloglog operations implemented. This vulnerability is fixed in 8.0.3, 7.4.5, 7.2.10, and 6.2.19. An additional workaround to mitigate the problem without patching the redis-server executable is to prevent users from executing hyperloglog operations. This can be done using ACL to restrict HLL commands.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/redisport/releases/tag/STABLE_redisport_3655)**.

</details>

## githubcli

<details>
<summary>githubcli (Build 2550) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [githubcli (Build 2550) - (STABLE)](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_2550)

- **(CRITICAL severity) CVE-2024-52308**: The GitHub CLI version 2.6.1 and earlier are vulnerable to remote code execution through a malicious codespace SSH server when using `gh codespace ssh` or `gh codespace logs` commands. This has been patched in the cli v2.62.0.

Developers connect to remote codespaces through an SSH server running within the devcontainer, which is generally provided through the [default devcontainer image]( https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-... https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers#using-the-default-dev-container-configuration) . GitHub CLI [retrieves SSH connection details]( https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/inv... https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/invoker.go#L230-L244 ), such as remote username, which is used in [executing `ssh` commands]( https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L2... https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L263 ) for `gh codespace ssh` or `gh codespace logs` commands.

This exploit occurs when a malicious third-party devcontainer contains a modified SSH server that injects `ssh` arguments within the SSH connection details. `gh codespace ssh` and `gh codespace logs` commands could execute arbitrary code on the user's workstation if the remote username contains something like `-oProxyCommand="echo hacked" #`.  The `-oProxyCommand` flag causes `ssh` to execute the provided command while `#` shell comment causes any other `ssh` arguments to be ignored.

In `2.62.0`, the remote username information is being validated before being used.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_3674)**.

</details>

<details>
<summary>githubcli (Build 2573) - (DEV) -- 1 critical vulnerability</summary>

- Affected release URL: [githubcli (Build 2573) - (DEV)](https://github.com/zopencommunity/githubcliport/releases/tag/DEV_githubcliport_2573)

- **(CRITICAL severity) CVE-2024-52308**: The GitHub CLI version 2.6.1 and earlier are vulnerable to remote code execution through a malicious codespace SSH server when using `gh codespace ssh` or `gh codespace logs` commands. This has been patched in the cli v2.62.0.

Developers connect to remote codespaces through an SSH server running within the devcontainer, which is generally provided through the [default devcontainer image]( https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-... https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers#using-the-default-dev-container-configuration) . GitHub CLI [retrieves SSH connection details]( https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/inv... https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/invoker.go#L230-L244 ), such as remote username, which is used in [executing `ssh` commands]( https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L2... https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L263 ) for `gh codespace ssh` or `gh codespace logs` commands.

This exploit occurs when a malicious third-party devcontainer contains a modified SSH server that injects `ssh` arguments within the SSH connection details. `gh codespace ssh` and `gh codespace logs` commands could execute arbitrary code on the user's workstation if the remote username contains something like `-oProxyCommand="echo hacked" #`.  The `-oProxyCommand` flag causes `ssh` to execute the provided command while `#` shell comment causes any other `ssh` arguments to be ignored.

In `2.62.0`, the remote username information is being validated before being used.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_3674)**.

</details>

<details>
<summary>githubcli (Build 2995) - (STABLE) -- 1 critical vulnerability</summary>

- Affected release URL: [githubcli (Build 2995) - (STABLE)](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_2995)

- **(CRITICAL severity) CVE-2024-52308**: The GitHub CLI version 2.6.1 and earlier are vulnerable to remote code execution through a malicious codespace SSH server when using `gh codespace ssh` or `gh codespace logs` commands. This has been patched in the cli v2.62.0.

Developers connect to remote codespaces through an SSH server running within the devcontainer, which is generally provided through the [default devcontainer image]( https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-... https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers#using-the-default-dev-container-configuration) . GitHub CLI [retrieves SSH connection details]( https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/inv... https://github.com/cli/cli/blob/30066b0042d0c5928d959e288144300cb28196c9/internal/codespaces/rpc/invoker.go#L230-L244 ), such as remote username, which is used in [executing `ssh` commands]( https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L2... https://github.com/cli/cli/blob/e356c69a6f0125cfaac782c35acf77314f18908d/pkg/cmd/codespace/ssh.go#L263 ) for `gh codespace ssh` or `gh codespace logs` commands.

This exploit occurs when a malicious third-party devcontainer contains a modified SSH server that injects `ssh` arguments within the SSH connection details. `gh codespace ssh` and `gh codespace logs` commands could execute arbitrary code on the user's workstation if the remote username contains something like `-oProxyCommand="echo hacked" #`.  The `-oProxyCommand` flag causes `ssh` to execute the provided command while `#` shell comment causes any other `ssh` arguments to be ignored.

In `2.62.0`, the remote username information is being validated before being used.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/githubcliport/releases/tag/STABLE_githubcliport_3674)**.

</details>

## grafana

<details>
<summary>grafana (Build 2266) - (STABLE) -- 1 medium vulnerability</summary>

- Affected release URL: [grafana (Build 2266) - (STABLE)](https://github.com/zopencommunity/grafanaport/releases/tag/STABLE_grafanaport_2266)

- **(MEDIUM severity) CVE-2025-4123**: A cross-site scripting (XSS) vulnerability exists in Grafana caused by combining a client path traversal and open redirect. This allows attackers to redirect users to a website that hosts a frontend plugin that will execute arbitrary JavaScript. This vulnerability does not require editor permissions and if anonymous access is enabled, the XSS will work. If the Grafana Image Renderer plugin is installed, it is possible to exploit the open redirect to achieve a full read SSRF.

The default Content-Security-Policy (CSP) in Grafana will block the XSS though the `connect-src` directive.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/grafanaport/releases/tag/STABLE_grafanaport_2268)**.

</details>

<details>
<summary>grafana (Build 2267) - (STABLE) -- 1 high vulnerability</summary>

- Affected release URL: [grafana (Build 2267) - (STABLE)](https://github.com/zopencommunity/grafanaport/releases/tag/STABLE_grafanaport_67)

- **(HIGH severity) CVE-2024-9264**: The SQL Expressions experimental feature of Grafana allows for the evaluation of `duckdb` queries containing user input. These queries are insufficiently sanitized before being passed to `duckdb`, leading to a command injection and local file inclusion vulnerability. Any user with the VIEWER or higher permission is capable of executing this attack.  The `duckdb` binary must be present in Grafana's $PATH for this attack to function; by default, this binary is not installed in Grafana distributions.
  - **This vulnerability is resolved in the [latest release](https://github.com/zopencommunity/grafanaport/releases/tag/STABLE_grafanaport_2268)**.

</details>

