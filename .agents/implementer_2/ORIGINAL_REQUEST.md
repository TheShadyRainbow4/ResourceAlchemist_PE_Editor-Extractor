## 2026-07-11T01:00:00Z

You are a Worker subagent.
Objective: Implement and run programmatic integration tests for `ResourceAlchemyHacker_CLI.exe`.

Input files:
- Compiled CLI location: C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\x64\Release\ResourceAlchemyHacker_CLI.exe
- Compiler tools: cl.exe and rc.exe (Visual Studio Build Tools and Windows Kits)

Tasks:
1. Create a `tests` directory under the project root (`C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\tests`).
2. Write a PowerShell script `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\tests\run_tests.ps1` that performs the following test pipeline:
   - Create a dummy data file `original_data.txt` containing a known text string, and `replacement_data.txt` containing a new text string.
   - Create a dummy C++ source file `test_target.cpp` and a resource definition file `test_target.rc` in the `tests` directory. The resource file should define a custom resource type (e.g. `101 MYTYPE "original_data.txt"`).
   - Compile the dummy target PE using `rc.exe` and `cl.exe` (make sure to set the environment paths using VS Build Tools vcvarsall.bat or using absolute paths). Make sure the output is `test_target.exe`.
   - Run the compiled `ResourceAlchemyHacker_CLI.exe /list test_target.exe` and verify it exits with 0 and prints the resource details.
   - Run `ResourceAlchemyHacker_CLI.exe /extract test_target.exe MYTYPE 101 1033 tests\extracted_string.txt`.
   - Assert that the output file exists and the contents match `original_data.txt` exactly.
   - Run `ResourceAlchemyHacker_CLI.exe /replace test_target.exe MYTYPE 101 1033 tests\replacement_data.txt`.
   - Assert that `test_target_1.bak` is created.
   - Assert that `test_target_1.bak` is identical to the original `test_target.exe`.
   - Assert that the modified `test_target.exe` now contains the replacement data (e.g. by running `/extract` on it and verifying the extracted content matches `replacement_data.txt`).
   - Run `/replace` again with another data file to verify `test_target_2.bak` is created and the target is updated.
3. Run `tests\run_tests.ps1` and verify that all assertions pass successfully.
4. Save the results and output in C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\.agents\implementer_2\progress.md and write a handoff report at C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\.agents\implementer_2\handoff.md.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
