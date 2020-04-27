#!/bin/sh
whatsonBuffer -format cols
grep " -1" /triacq/onshdsk.txt | grep " 1" | grep " $1" | grep " 3"
