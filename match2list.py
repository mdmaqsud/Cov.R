#!/usr/bin/env python

import sys 

def main():
  '''useage tester.py masterList testList'''   


  #open files
  masterListFile = open(sys.argv[1], 'r')
  testListFile = open(sys.argv[2], 'r')

  #bulid master list
  # .strip() off '\n' new line
  # set to lower case. Intrusion != intrusion, but should.
  masterList = [ line.strip() for line in masterListFile ]
  #run test
  for line in testListFile:
    term = line.strip()
    if term  in masterList:
      print term, 1
      #perhaps grab your metadata using a like %%
    else:
      print term, 0

  #close files
  masterListFile.close()
  testListFile.close()

if __name__ == '__main__':
  main()
