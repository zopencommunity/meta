import subprocess
import pickle

def process_untrusted_data(user_input: bytes, cmd_arg: str):
    # 1. Insecure Deserialization (CWE-502 - High Severity)
    data = pickle.loads(user_input)

    # 2. Command Injection via shell=True (CWE-78 - High Severity)
    subprocess.call(f"echo Processing: {cmd_arg}", shell=True)
    
    return data