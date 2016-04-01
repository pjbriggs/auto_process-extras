#!/bin/bash
#
# Find a random 'bin' i.e. empty subdirectory under
# the supplied directory
if [ $# -ne 1 ] ; then
  echo Usage: $(basename $0) DIR
  echo Find a random empty bin under DIR
  exit
fi
if [ ! -d $1 ] ; then
  echo $1: not a directory >&2
  exit 1
fi
for d in $(ls -c1 $1 | sort -R) ; do
  if [ -z "$(ls $1/$d)" ] ; then
    echo $d
    exit
  fi
done
echo No suitable bin found in $1 >&2
exit 1
##
#
