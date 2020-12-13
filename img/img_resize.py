#!/usr/bin/env python3
from PIL import Image
from sys import argv

basewidth = 50
img = Image.open(argv[1])
wpercent = (basewidth/float(img.size[0]))
hsize = int((float(img.size[1])*float(wpercent)))
img = img.resize((basewidth,hsize), Image.ANTIALIAS)
img.save(argv[1]) 
