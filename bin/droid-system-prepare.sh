#!/bin/bash

# Copyright (c) 2013, Jolla Ltd.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

if [ $# -ne 3 ]; then
  echo "$0 needs three parameters, BUILD_ROOT, DEVICE and DROID_BIN_PATH"
  exit 1
fi

RPM_BUILD_ROOT=$1
DEVICE=$2
DROID_BIN_PATH=$3

if [ ! -x ${DROID_BIN_PATH}/filesgen ]; then
  echo "${DROID_BIN_PATH}/filesgen was not found"
  exit 1
fi

echo "Creating udev rules.."
mkdir -p $RPM_BUILD_ROOT/lib/udev/rules.d/

grep -v -E "(^\#|^$|^/dev/[^\w]*/[^\w]*|/sys)" $RPM_BUILD_ROOT/ueventd.rc | sed "s|/dev/||g" | awk '{ print "KERNEL==\"" $1 "\", MODE=\"" $2 "\", GROUP=\"" $4 "\", OWNER=\"" $3 "\"" }' >> $RPM_BUILD_ROOT/lib/udev/rules.d/999-android-system.rules
grep -v -E "(^\#|^$|^/dev/[^\w]*/[^\w]*|/sys)" $RPM_BUILD_ROOT/ueventd.$DEVICE.rc | sed "s|/dev/||g" | awk '{ print "KERNEL==\"" $1 "\", MODE=\"" $2 "\", GROUP=\"" $4 "\", OWNER=\"" $3 "\"" }' >> $RPM_BUILD_ROOT/lib/udev/rules.d/999-android-system.rules
grep -E "(^/dev/block/[^\w]*)" $RPM_BUILD_ROOT/ueventd.rc | sed "s|/dev/block/||g" | awk '{ print "KERNEL==\"" $1 "\", MODE=\"" $2 "\", GROUP=\"" $4 "\", OWNER=\"" $3 "\"" }' >> $RPM_BUILD_ROOT/lib/udev/rules.d/999-android-system.rules
grep -E "(^/dev/block/[^\w]*)" $RPM_BUILD_ROOT/ueventd.$DEVICE.rc | sed "s|/dev/block/||g" | awk '{ print "KERNEL==\"" $1 "\", MODE=\"" $2 "\", GROUP=\"" $4 "\", OWNER=\"" $3 "\"" }' >> $RPM_BUILD_ROOT/lib/udev/rules.d/999-android-system.rules

mkdir -p $RPM_BUILD_ROOT/usr/libexec/droid/
echo "#!/bin/sh" > $RPM_BUILD_ROOT/usr/libexec/droid/android-permission-fixup.sh

# grep -v /dev/input/ is here because otherwise directories in /dev/input/ get 660 permissions 
# and groups do not have proper permissions to access those.
grep -E "(^/dev/[^\w]*/[^\w]*)" $RPM_BUILD_ROOT/ueventd.rc | grep -v /dev/input/ | grep -v /dev/block/ | sed "s|/dev/log/|/dev/alog/|g" | awk '{ print "chmod " $2 " " $1 "; chown " $3 ":" $4 " " $1 }' >> $RPM_BUILD_ROOT/usr/libexec/droid/android-permission-fixup.sh
grep -E "(^/dev/[^\w]*/[^\w]*)" $RPM_BUILD_ROOT/ueventd.$DEVICE.rc | grep -v /dev/input/ | grep -v /dev/block/ | sed "s|/dev/log/|/dev/alog/|g" | awk '{ print "chmod " $2 " " $1 "; chown " $3 ":" $4 " " $1 }' >> $RPM_BUILD_ROOT/usr/libexec/droid/android-permission-fixup.sh

grep -E "(^/sys/)" $RPM_BUILD_ROOT/ueventd.rc | awk '{ print "chmod " $3 " " $1 "/" $2 "; chown " $4 ":" $5 " " $1 "/" $2 }' >> $RPM_BUILD_ROOT/usr/libexec/droid/android-permission-fixup.sh
grep -E "(^/sys/)" $RPM_BUILD_ROOT/ueventd.$DEVICE.rc | awk '{ print "chmod " $3 " " $1 "/" $2 "; chown " $4 ":" $5 " " $1 "/" $2 }' >> $RPM_BUILD_ROOT/usr/libexec/droid/android-permission-fixup.sh

echo "Cleaning up the $RPM_BUILD_ROOT for file listing.."
# Remove dirs that are owned by other parts of system
rm -rf $RPM_BUILD_ROOT/dev
rm -rf $RPM_BUILD_ROOT/sys

# Save some space by dropping apps and media
rm -rf $RPM_BUILD_ROOT/system/app
rm -rf $RPM_BUILD_ROOT/system/media

# Move droid init to place where it doesn't conflict withsystemd.
mv $RPM_BUILD_ROOT/init $RPM_BUILD_ROOT/sbin/droid-hal-init
chmod 755 $RPM_BUILD_ROOT/sbin/droid-hal-init

# Why do we remove this?
rm $RPM_BUILD_ROOT/sbin/ueventd

FILELIST=myfiles.list

echo "Creating $FILELIST.."
# Create a filelist that can be included by rpm.

# List dirs, excluding some common paths to packaging
find $RPM_BUILD_ROOT -not -path "$RPM_BUILD_ROOT" -and -not -path "$RPM_BUILD_ROOT/sbin" -and -not -path "$RPM_BUILD_ROOT/lib/firmware" \
        -and -not -path "$RPM_BUILD_ROOT/lib" -and -not -path "$RPM_BUILD_ROOT/lib/udev" -and -not -path "$RPM_BUILD_ROOT/lib/udev/rules.d" \
        -and -not -path "$RPM_BUILD_ROOT/proc" -and -not -path "$RPM_BUILD_ROOT/bin" \
        -and -not -path "$RPM_BUILD_ROOT/usr/" -and -not -path "$RPM_BUILD_ROOT/usr/include" \
        -and -not -path "$RPM_BUILD_ROOT/usr/libexec/droid" -and -type d -printf "${DROID_BIN_PATH}/filesgen %P d\n" | sh > $FILELIST

# List files
find $RPM_BUILD_ROOT -path $RPM_BUILD_ROOT/usr/include -prune -o -type f -printf "${DROID_BIN_PATH}/filesgen %P f\n" | sh >> $FILELIST
find $RPM_BUILD_ROOT -path $RPM_BUILD_ROOT/usr/include -prune -o -type l -printf "${DROID_BIN_PATH}/filesgen %P f\n" | sh >> $FILELIST

# This file needs to be in separate package because, groups and users needs to be created
# before the actual files with this script.
echo "Creating user group script.."
${DROID_BIN_PATH}/usergroupgen > $RPM_BUILD_ROOT/usr/libexec/droid/user-group-create.sh
chmod 755 $RPM_BUILD_ROOT/usr/libexec/droid/user-group-create.sh

echo "Done."

exit 0
