#!/usr/bin/env python3

from sys import argv
import pandas as pd

pd.set_option('display.max_rows', None)
ct = pd.read_csv('./pylist/countries.csv')
ct.index += 1
print(ct.head(int(argv[1])))