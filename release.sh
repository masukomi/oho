#!/bin/sh
STASHED=0
VERSION="dev_version"

read -p "build compressed source dir? [y/n]: " SOURCE_DIR
if [ "$SOURCE_DIR" == "y" ]; then
  if [ "$1" != "" ]; then
    VERSION=$1
    perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/oho.cr
  fi
  echo "Building with version $VERSION"
  # echo "compiling..."
  # crystal build --release src/oho.cr

  echo "creating compressed release file..."
  version_dir="oho_$VERSION-src"
  rm -rf $version_dir
  mkdir $version_dir
  cp -r src $version_dir/
  cp -r spec $version_dir/
  cp -r README.md $version_dir/

  tar -czf $version_dir.tgz $version_dir
  rm -rf $version_dir

  if [ "$1" != "" ]; then
    perl -pi -e "s/$1/VERSION_NUMBER_HERE/" src/oho.cr
  fi

  echo "here's your SHA for homebrew"
  shasum -a 256 $version_dir.tgz
else
  echo "not building source dir"
fi

read -p "check for dylib requirements? [y/n]: " CHECK_DYLIBS

if [ "$CHECK_DYLIBS" == "y" ]; then
  echo "building binary"
  crystal build --release src/oho.cr
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
else
  echo "not checking for dylibs"
fi

echo "Done."
