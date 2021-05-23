import json
import os
import re
import random
import tempfile
import subprocess
import sys

hlepor_path = "hlepor/hlepor.perl"


class HLEPOR(object):
    def __init__(self, cmd):
        self.cmd = cmd
        self.proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=False)

    def generate_json(self, ref_list, cand_list, raw_stdout):
        stdout = raw_stdout.decode("utf-8").replace(r"\n", "\n")
        hlepor_regex = r"(.*):(.*)"
        matches = re.finditer(hlepor_regex, stdout, re.MULTILINE)

        data = {}
        data["id"] = random.randint(0, 999)
        data["reference_sentence"] = ref_list
        data["candidate_sentence"] = cand_list

        for i in matches:
            label = str(i.group(1)).strip().replace(" ", "_").lower()
            value = str(i.group(2)).strip().split()
            data[label] = value
        
        json_output = json.dumps(data,ensure_ascii=False)
        return json_output


if __name__ == "__main__":
    ref_file = sys.argv[1]
    cand_file = sys.argv[2]

    ref_list = []
    cand_list = []

    # File-level
    if os.path.exists(ref_file) and os.path.exists(cand_file):
        ref_count = len([ref_list.append(line.strip()) for line in open(ref_file)])
        cand_count = len([cand_list.append(line.strip()) for line in open(cand_file)])

        if ref_count == 0 and cand_count == 0 or ref_count != cand_count:
            print("FAILED")

        if ref_count == cand_count:
            hlepor_run = HLEPOR(["perl", hlepor_path, "-ref", str(ref_file), "-cand", str(cand_file)])
            hlepor_out, hlepor_err = hlepor_run.proc.communicate()

            print(hlepor_run.generate_json(ref_list, cand_list, hlepor_out), flush=True)
    else:
        # Sentence-level
        try:
            ref_tmp = tempfile.NamedTemporaryFile(mode="w+t", delete=False, prefix="hlepor-ref-", suffix=".txt", newline="\n")
            cand_tmp = tempfile.NamedTemporaryFile(mode="w+t", delete=False, prefix="hlepor-cand-", suffix=".txt", newline="\n")

            ref_str = ref_file.replace(r"\n", "\n")
            cand_str = cand_file.replace(r"\n", "\n")

            for line in ref_str.split("\n"):
                ref_tmp.write(line + "\n")
                ref_list.append(line)
            for line in cand_str.split("\n"):
                cand_tmp.write(line + "\n")
                cand_list.append(line)

        finally:
            ref_tmp.close()
            cand_tmp.close()

        ref_count = len(ref_list)
        cand_count = len(cand_list)

        if ref_count == 0 and cand_count == 0 or ref_count != cand_count:
            print("FAILED")
        if ref_count == cand_count:
            hlepor_run = HLEPOR(["perl", hlepor_path, "-ref", str(ref_tmp.name), "-cand", str(cand_tmp.name)])
            hlepor_out, hlepor_err = hlepor_run.proc.communicate()

            print(hlepor_run.generate_json(ref_list, cand_list, hlepor_out), flush=True)

        # Housekeeping
        os.remove(ref_tmp.name)
        os.remove(cand_tmp.name)
