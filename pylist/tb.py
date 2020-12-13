#!/usr/bin/env python3

import pandas as pd
import sys

pd.set_option('display.max_rows', None)

ct = [line.strip().split('\t') for line in sys.stdin.readlines()]
ct = pd.DataFrame(ct)

if len(sys.argv) > 1:
    print(ct.head(int(sys.argv[1])))
else:
    print(ct)