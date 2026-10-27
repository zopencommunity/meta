import sys
import subprocess
import pickle
import base64

# CodeQL flags source-to-sink dataflow (sys.argv / input -> sink)

def run():
    # Source of untrusted input
    user_input = sys.argv[1]

    # 1. Code Injection (CWE-95 - High / Critical)
    eval(user_input)

    # 2. Command Injection (CWE-78 - High)
    subprocess.call(f"echo {user_input}", shell=True)

    # 3. Unsafe Deserialization (CWE-502 - High)
    raw_bytes = base64.b64decode(user_input)
    pickle.loads(raw_bytes)

if __name__ == "__main__":
    run()
