#!/usr/bin/env python3

import sys
f=open("./countries.txt","r")
lines = f.readlines()
array = [line.strip().split('\t') for line in lines]
if len(sys.argv) < 1:
    print("error")
for r in array:
    for c in r:
        if (sys.argv[1] == c):
            print("ok")
f.close()
