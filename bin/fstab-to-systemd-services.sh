#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo "This script needs at least two paramters. Usage: $0 <FSTABLEFILE> <OUTPUTDIR> <MAPPINGFILE>"
  exit 1
fi

FSTABFILE=$1
OUTPUTDIR=$2
MAPPINGS=$3

if [[ ! -e $FSTABFILE ]]; then
  echo "ERROR: File '$FSTABFILE' not found."
  exit 1
fi

# TODO: This script should also have blacklist of certain mount points
# That should not be mounted in host system.

mkdir -p $OUTPUTDIR/local-fs.target.wants/

while read -r LINE
do
  if [[ "$LINE" =~ ^# ]] ; then
    continue
  fi

  read src mntpoint fstype fsoptions flags <<< $LINE 

  if [[ -z $src ]]; then
    continue
  fi
 
  NAME=$(echo $mntpoint | sed 's!^/!!g' | sed 's!/!-!g')

  MAPPING_SRC=$(awk -F, "\$1 == \"$src\"{print \$2}" $MAPPINGS)

  if [[ ! -z $MAPPING_SRC ]]; then
    src=$MAPPING_SRC
  fi 

  cat > $OUTPUTDIR/$NAME.mount << EOF
[Unit]
Description=$NAME mount
Before=local-fs.target

[Mount]
What=$src
Where=$mntpoint
Type=$fstype
Options=$fsoptions
# Default is 90 which makes mount period too long in case of
# errors so drop it down a notch.
TimeoutSec=10

[Install]
WantedBy=local-fs.target
EOF

  ln -sf ../$NAME.mount $OUTPUTDIR/local-fs.target.wants/$NAME.mount

done < $FSTABFILE

# Comment lines so that we don't mount anything twice.
sed -i 's/^/#/' $FSTABFILE

echo "Mount files for systemd created '$1' should be now removed or lines commented out."

