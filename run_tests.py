#!/usr/bin/python

import subprocess
from sys import argv
import re

script = "./compile"
cleanup_script = "./cleanup"

if len(argv) != 2:
    print("Usage: ./run_tests.py <triangle-size>")
    exit(1)

try:
    trisize = int(argv[1])
except ValueError:
    print("Invalid argument: size must be an integer")
    exit(1)

for x in range(trisize):
    for y in range(trisize - x):
        # run the test script with the hole at (x,y)
        out = subprocess.check_output([script, str(trisize), str(x), str(y)])
        # use regex to see if the state was solvable (if it threw an error, it
        # was solvable)
        solved = re.search("errors: (\d*)", out)
        # print the result
        print("(" + str(x) + ", " + str(y) + "): " + solved.group(1))

# cleanup
subprocess.call([cleanup_script])

