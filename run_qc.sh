#!/bin/bash
#
# Script to enable auto_process QC pipeline to run on
# arbitrary collection of Fastq files
usage() {
    echo $0 NAME FASTQ [FASTQ...]
}
if [ $# -lt 2 ] ; then
    usage
    exit 1
fi
name=$1
shift
wd=$(pwd)/run_qc.$name
mkdir -p $wd
cd $wd
mkdir -p $name/fastqs
for fq in $@ ; do
    echo $fq
    ln -s $fq $name/fastqs/$(basename $fq)
done
auto_process.py run_qc --projects=$name
retval=$?
if [ $retval -eq 0 ] ; then
    echo Finished OK
else
    echo Error: $retval
fi
exit $retval
##
#

