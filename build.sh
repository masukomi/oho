#!/bin/sh
STASHED=0
VERSION="dev_version"
if [ "$1" != "" ]; then 
  VERSION=$1
  git stash save "snapshot: $(date)" 
  STASHED=$?
  if [ "$STASHED" == "0" ]; then 
    git stash apply "stash@{0}" > /dev/null 2>&1
  fi
  perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/oho.cr
fi
crystal build --release src/oho.cr
git checkout HEAD src/oho.cr
if [ $STASHED -eq 0 ]; then 
  git stash pop > /dev/null 2>&1
fi

version_dir="oho_$VERSION"
rm -rf $version_dir
mkdir $version_dir
cp oho $version_dir/
tar -czf $version_dir.tgz $version_dir
rm -rf $version_dir


# copy all the optional ones
# rm -rf dylibs/*
DYLIBS=`otool -L oho | grep "/opt" | awk -F' ' '{ print $1 }'`
for dylib in $DYLIBS
do 
  echo " - dylib $dylib"
  # base=$(basename $dylib)
  # cp $dylib dylibs/
  # install_name_tool -change $dylib "~/lib/$(basename $dylib)" oho
done

