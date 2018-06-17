#!/bin/sh
STASHED=0
VERSION="dev_version"
if [ "$1" != "" ]; then 
  VERSION=$1
  perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/oho.cr
fi
echo "compiling..."
crystal build --release src/oho.cr
if [ "$1" != "" ]; then 
  perl -pi -e "s/$1/VERSION_NUMBER_HERE/" src/oho.cr
fi
echo "creating compressed release file..."
version_dir="oho_$VERSION"
rm -rf $version_dir
mkdir $version_dir
cp oho $version_dir/
tar -czf $version_dir.tgz $version_dir
rm -rf $version_dir

echo "here's your SHA for homebrew"
shasum -a 256 $version_dir.tgz

echo "examining binary for dylib requirements..."
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

echo "Done."
