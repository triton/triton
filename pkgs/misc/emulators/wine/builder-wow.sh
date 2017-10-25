#!/bin/sh

## build described at http://wiki.winehq.org/Wine64

source $stdenv/setup

unpackPhase
cd $TMP/$srcRoot
patchPhase

configureScript=$TMP/$srcRoot/configure
mkdir -p $TMP/wine-wow $TMP/wine64

cd $TMP/wine64
srcRoot=`pwd`
configureFlags="--enable-win64"
configurePhase
buildPhase
# checkPhase

cd $TMP/wine-wow
srcRoot=`pwd`
configureFlags="--with-wine64=../wine64"
configurePhase
buildPhase
# checkPhase

eval "$preInstall"
cd $TMP/wine64 && make install
cd $TMP/wine-wow && make install
eval "$postInstall"
fixupPhase
