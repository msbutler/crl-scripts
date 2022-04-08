import sys
import subprocess
import shutil
# args
# - iters: the number of times to run the cmd for a given binary
# - cmd: the benchmark command 
# - binary1: the name of binary file to benchmark
# - binary2: (optional): the name of the second binary file to also benchmark. If the user
#   specifies a second binary, 'benchstat' will run on the two benchmarks.
# -tempdir: specify directory for created SSTs. Do not define the dir in the cmd!
# e.g. python3 pebble_bench.py 1 'bench ycsb --workload F --initial-keys 100000 -c 64 -d 1m' temp myBinary
def main():
    iters = int(sys.argv[1])
    cmd = sys.argv[2]
    tempDir = sys.argv[3]
    binary1 = sys.argv[4]
    sumFileName1 = bench(binary1,cmd,iters, tempDir)

    binary2 = ""
    # if the user passed a second binary, benchmark it and compare to first binary benchmark
    if len(sys.argv[1:])>4:
        binary2 = sys.argv[5]
        sumFileName2 = bench(binary2,cmd,iters, tempDir)
        popen = subprocess.Popen(("benchstat",sumFileName1,sumFileName2), stdout= subprocess.PIPE)
        benchStatFile = open("benchstatRes.txt","w+")
        output = popen.stdout.read().decode('utf-8').split("\n")
        for line in output:
            print(line)
            benchStatFile.write(line)
            benchStatFile.write("\n")
        benchStatFile.close()

def bench(binary, cmd, iters, tempDir):
    sumFileName = "summary"+binary+".txt"
    sumFile = open(sumFileName,"w+")

    verbFileName = "verbose"+binary+".txt"
    verbFile = open(verbFileName,"w+")
    

    args = "./" + binary + " " + cmd + " " + tempDir
    for i in range(iters):
        prog = f"\nRun {i+1} of {binary} binary"
        verbFile.write(prog)
        print(prog)

        popen = subprocess.Popen(args.split(), stdout= subprocess.PIPE)
        popen.wait()
        output = popen.stdout.read().decode('utf-8').split("\n\n")
        print(output[2])
        sumFile.write(output[2])
        sumFile.write("\n")
        for sec in output:
            verbFile.write(sec)
            verbFile.write("\n \n")
    sumFile.close()
    verbFile.close()
    shutil.rmtree(tempDir)
    return sumFileName
        


if __name__ == "__main__":
    main()