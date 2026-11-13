import subprocess
import re
import os

def run_analyze():
    print("Running dart analyze...")
    result = subprocess.run(['dart', 'analyze'], capture_output=True, text=True, shell=True)
    return result.stdout + result.stderr

def fix_errors(output):
    # Regex to match: error - lib\screens\...\file.dart:line:col - Invalid constant value. - invalid_constant
    pattern = re.compile(r'error - (lib[/\\][^:]+\.dart):(\d+):(\d+) - .*?(invalid_constant|non_constant_list_element|non_constant_default_value)')
    
    fixes = {}
    for line in output.split('\n'):
        match = pattern.search(line)
        if match:
            file_path = match.group(1).strip()
            line_num = int(match.group(2))
            
            if file_path not in fixes:
                fixes[file_path] = set()
            fixes[file_path].add(line_num)
            
    for file_path, lines in fixes.items():
        if not os.path.exists(file_path):
            continue
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.readlines()
            
        changed = False
        # Sort in reverse to modify safely if needed (though we just modify in place line by line)
        for line_num in lines:
            idx = line_num - 1
            if idx < len(content):
                # Simply replace 'const ' with '' on that line. 
                # If 'const' is not on this line, check the previous line.
                if 'const ' in content[idx]:
                    content[idx] = content[idx].replace('const ', '')
                    changed = True
                elif idx > 0 and 'const ' in content[idx-1]:
                    content[idx-1] = content[idx-1].replace('const ', '')
                    changed = True
                elif idx > 1 and 'const ' in content[idx-2]:
                    content[idx-2] = content[idx-2].replace('const ', '')
                    changed = True
                    
        if changed:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(content)
            print(f"Fixed const errors in {file_path}")

def main():
    while True:
        out = run_analyze()
        if 'invalid_constant' not in out and 'non_constant_list_element' not in out and 'non_constant_default_value' not in out:
            print("No more const errors found!")
            break
        fix_errors(out)

if __name__ == '__main__':
    main()
