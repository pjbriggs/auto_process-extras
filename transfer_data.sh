#!/bin/bash
#
# Transfer data to webserver or cluster shared area
#
if [ $# -lt 2 ] || [ $# -gt 3 ] ; then
    echo Usage: $(basename $0) DEST ANALYSIS_DIR \[ PROJECT \]
    echo Transfer data from PROJECT in ANALYSIS_DIR to DEST
    echo which can be either \"webserver\", \"cluster\" or an
    echo arbitrary location of the form \[\[USER@\]\[HOST:\]DIR
    exit
fi
METHOD=$1
ANALYSIS_DIR=$2
PROJECT=$3
SCRATCH=/scratch/$USER
#
if [ ! -d "$ANALYSIS_DIR" ] ; then
    echo "$ANALYSIS_DIR: not found" >&2
    exit 1
fi
MANAGE_FASTQS=$(which manage_fastqs.py)
if [ ! -x "$MANAGE_FASTQS" ] ; then
    echo "manage_fastqs.py: not found" >&2
    exit 1
fi
if [ -z "$PROJECT" ] ; then
    $MANAGE_FASTQS $ANALYSIS_DIR
    exit
fi
if [ ! -d "$ANALYSIS_DIR/$PROJECT" ] ; then
    echo "$PROJECT: project not found" >&2
    exit 1
fi
$MANAGE_FASTQS $ANALYSIS_DIR $PROJECT
metadata_file=$ANALYSIS_DIR/metadata.info
if [ ! -f "$metadata_file" ] ; then
    echo "metadata.info file not found for analysis dir" >&2
    metadata_file=$ANALYSIS_DIR/auto_process.info
    if [ ! -f "$metadata_file" ] ; then
	echo "auto_process.info file not found for analysis dir" >&2
	exit 1
    fi
    echo "Falling back to auto_process.info" >&2
fi
SETTINGS_FILE=$(dirname $0)/site.sh
if [ ! -f $SETTINGS_FILE ] ; then
    echo "$SETTINGS_FILE: not found" >&2
    exit 1
fi
. $SETTINGS_FILE
if [ -z "$WEBDIR" ] || [ -z "$WEBURL" ] || [ -z "$CLUSTERDIR" ] ; then
    echo "Some or all required env variables not set" >&2
    exit 1
fi
PLATFORM=$(grep ^platform $metadata_file | cut -f2 | tr [:lower:] [:upper:])
RUN_NUMBER=$(grep ^run_number $metadata_file | cut -f2)
DATESTAMP=$(echo $(basename $ANALYSIS_DIR) | cut -d_ -f1)
FIND_RANDOM_BIN=$(dirname $0)/find_random_bin.sh
case $METHOD in
    webserver)
	echo "Copying $PROJECT to webserver"
	if [ ! -d "$WEBDIR" ] ; then
	    echo "$WEBDIR: top level webserver directory not found" >&2
    	    exit 1
	fi
	BIN=$($FIND_RANDOM_BIN $WEBDIR)
	TARGETDIR=$WEBDIR/$BIN
	if [ ! -d $TARGETDIR ] ; then
	    echo "Failed to acquire random bin" >&2
	    exit 1
	fi
	echo "Target bin: $TARGETDIR"
	qsub -sync y -b y -j y -wd $SCRATCH -N copy.$PROJECT -V $MANAGE_FASTQS $ANALYSIS_DIR $PROJECT copy $TARGETDIR
	if [ $? -ne 0 ] ; then
	    echo "Copying to webserver failed" >&2
            exit 1
	fi
	echo "Copying download_fastqs.py"
	cp $(dirname $MANAGE_FASTQS)/download_fastqs.py $TARGETDIR
	if [ ! -z "$WEBREADME" ] && [ -f "$WEBREADME" ] ; then
	    echo "Copying README file"
	    cp "$WEBREADME" $TARGETDIR/README
	    echo "Substituting template variables into README"
	    sed -i "s,%PLATFORM%,$PLATFORM,g" $TARGETDIR/README
	    sed -i "s,%RUN_NUMBER%,$RUN_NUMBER,g" $TARGETDIR/README
	    sed -i "s,%DATESTAMP%,$DATESTAMP,g" $TARGETDIR/README
	    sed -i "s,%PROJECT%,$PROJECT,g" $TARGETDIR/README
	    sed -i "s,%WEBURL%,$WEBURL,g" $TARGETDIR/README
	    sed -i "s,%BIN%,$BIN,g" $TARGETDIR/README
	    sed -i "s,%TODAY%,$(date +'%A %d %B %Y'),g" $TARGETDIR/README
	fi
	echo "Files now at $WEBURL/$BIN"
	;;
    cluster)
	echo "Copying $PROJECT to cluster"
        if [ ! -d "$CLUSTERDIR" ] ; then
            echo "$CLUSTERDIR: top level cluster data directory not found" >&2
            exit 1
        fi
	TARGETDIR=$CLUSTERDIR/${PLATFORM}_${DATESTAMP}.${RUN_NUMBER}/$PROJECT
	echo "Target directory: $TARGETDIR"
	if [ -d $TARGETDIR ] ; then
            echo "$TARGETDIR: directory already exists" >&2
	    exit 1
 	fi
	mkdir -p $TARGETDIR
	qsub -sync y -b y -j y -wd $SCRATCH -N copy.$PROJECT -V $MANAGE_FASTQS $ANALYSIS_DIR $PROJECT copy $TARGETDIR
	if [ $? -ne 0 ] ; then
            echo "Copying to cluster failed" >&2
            exit 1
        fi
	echo "Files now at $TARGETDIR"
	;;
    *)
	echo "Attempting to copy to specified location"
	TARGETDIR=$METHOD
	echo "Target directory: $TARGETDIR"
	qsub -sync y -b y -j y -wd $SCRATCH -N copy.$PROJECT -V $MANAGE_FASTQS $ANALYSIS_DIR $PROJECT copy $TARGETDIR
	if [ $? -ne 0 ] ; then
            echo "Copying to $TARGETDIR failed" >&2
            exit 1
        fi
	echo "Files now at $TARGETDIR"
	;;
esac
echo Done
##
#
