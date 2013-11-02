#! /usr/bin/python
from TOSSIM import *
import sys

t = Tossim([])
r = t.radio()

r.add(1, 2, -54.0)
r.add(2, 1, -54.0)

noise = open("meyer-heavy.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in range(1, 3):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(1, 3):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()

t.addChannel("MySocketApp", sys.stdout)
t.addChannel("Boot", sys.stdout)

t.getNode(1).bootAtTime(1000);
t.getNode(2).bootAtTime(8500);

for i in range(10000):
  t.runNextEvent()
