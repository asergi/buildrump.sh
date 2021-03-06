#! /usr/bin/env sh
#
# Copyright (c) 2013 
# Jens Staal <staal1978@gmail.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

# This script will generate a tar.bz2 archive of the current git checkout
# The "version number" of the tarball is in unix time format 

DEST=buildrump

echo "Detecting buildrump.sh git revision"

_revision=$(git rev-parse HEAD)
_date=$(git show -s --format="%ci" ${_revision})
#incremental "version number" in unix time format
_date_filename=$(echo ${_date} | sed 's/-//g;s/ .*//')

if [ -z "${_revision}" ]
then
  echo "Error: git revision could not be detected"
  exit
else
  echo "buildrump.sh git revision is ${_revision}"
fi

if ! mkdir "${DEST}"; then
	echo "Error: failed to create directory \"${DEST}\""
	exit 1
fi

echo "Checking out cvs sources"

if ! ./buildrump.sh -s ${DEST}/src checkoutgit ; then
	echo "Checkout failed!"
	exit 1
fi
# don't need .git in the tarball
rm -rf ${DEST}/src/.git

echo "Checkout done"

echo "Generating temporary directory to be compressed"

#directories
cp -r {brlib,examples,tests} "${DEST}/"

#files
cp -p {.srcgitrev,checkout.sh,AUTHORS,buildrump.sh,LICENSE,tarup.sh} "${DEST}"/

echo ${_revision} > "${DEST}/gitrevision"
echo ${_date} > "${DEST}/revisiondate"

echo "Compressing sources to a snapshot release"

tar -cvzf buildrump-${_date_filename}.tar.gz "${DEST}"

echo "Removing temporary directory"
rm -rf "${DEST}"

echo "Congratulations! Your archive should be
      at buildrump-${_date_filename}.tar.gz"
