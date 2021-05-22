import tempfile
import subprocess
import sys
import os


hlepor_path = "hlepor/hlepor.perl"


class HLEPOR(object):
    def __init__(self, cmd):
        self.cmd = cmd
        self.proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)


if __name__ == "__main__":
    ref_file = sys.argv[1]
    cand_file = sys.argv[2]

    # File-level
    if os.path.exists(ref_file) and os.path.exists(cand_file):
        ref_count = sum(1 for line in open(ref_file))
        cand_count = sum(1 for line in open(cand_file))

        if ref_count == 0 and cand_count == 0 or ref_count != cand_count:
            print("FAILED")
        if ref_count == cand_count:
            hlepor_run = HLEPOR(["perl", hlepor_path, "-ref", str(ref_file), "-cand", str(cand_file)])
            hlepor_out, hlepor_err = hlepor_run.proc.communicate()

            print(hlepor_out)
    else:
        # Sentence-level
        try:
            ref_tmp = tempfile.NamedTemporaryFile(mode="w+t", delete=False, prefix="hlepor-ref-", suffix=".txt",newline="\n")
            cand_tmp = tempfile.NamedTemporaryFile(mode="w+t", delete=False, prefix="hlepor-cand-", suffix=".txt",newline="\n")

            ref_str = ref_file.replace(r"\n", "\n")
            cand_str = cand_file.replace(r"\n", "\n")

            ref_count = 0
            cand_count = 0

            for i in ref_str.split("\n"):
                ref_tmp.write(i + "\n")
                ref_count += 1
            for i in cand_str.split("\n"):
                cand_tmp.write(i + "\n")
                cand_count += 1
        finally:
            ref_tmp.close()
            cand_tmp.close()

        if ref_count == 0 and cand_count == 0 or ref_count != cand_count:
            print("FAILED")
        if ref_count == cand_count:
            hlepor_run = HLEPOR(["perl", hlepor_path, "-ref", str(ref_tmp.name), "-cand", str(cand_tmp.name)])
            hlepor_out, hlepor_err = hlepor_run.proc.communicate()

            print(hlepor_out)
        
        # Housekeeping
        os.remove(ref_tmp.name)
        os.remove(cand_tmp.name)
