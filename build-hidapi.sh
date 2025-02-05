#!/usr/bin/env bash

# Convenience script to build hidapi locally
# Directory structure is
# ~/Workspaces
#  + Cpp
#    + hidapi (https://github.com/libusb/hidapi)
#  + Docker
#    + dockcross (https://github.com/dockcross/dockcross)
#  + Java
#    + Personal
#      + hid4java (https://github.com/gary-rowe/hid4java)
#
# Dependencies:
# - git
# - Docker Desktop
# - XCode v12.5.1 or higher for darwin-x86-64-aarch64 cross compiler support
#
# Place a symlink to this script in the root of ~/Workspaces
#   cd ~/Workspaces
#   ln -s Java/Personal/hid4java/build-hidapi.sh ./build-hidapi.sh
#
# Supported command line arguments are:
#
# all - build all variants
# windows - build all Windows variants
# linux - build all Linux variants
# osx - build all macOS variants (not recommended)
# darwin-x86-64 - OS X 64-bit
# darwin-aarch64 - OS X ARM64
# linux-aarch64 - Linux ARMv8 64-bit
# linux-amd64 - Linux AMD 64-bit
# linux-arm - Linux ARMv6 hard float 32-bit (RPi)
# linux-x86-64 - Linux x86 64-bit (same as AMD64)
# linux-x86 - Linux x86 32-bit
# win32-x86 - Windows 32-bit
# win32-x86-64 - Windows 64-bit
# win32-aarch64 - Windows 64-bit ARM64
#

# Console colours
red="\033[31m"
yellow="\033[33m"
green="\033[32m"
plain="\033[0m"

echo -e "${green}------------------------------------------------------------------------${plain}"
echo -e "${yellow}Target build for HIDAPI is $1${plain}"

echo -e "${green}------------------------------------------------------------------------${plain}"

# Always use Dockcross latest release

echo -e "${green}Configuring Dockcross${plain}"
cd ~/Workspaces/Docker/dockcross/ || exit
git checkout master
git pull

# Windows cross compilers

# 64-bit (Intel)
echo -e "${green}Configuring Windows 64-bit${plain}"
docker run --rm dockcross/windows-shared-x64 > ./dockcross-windows-shared-x64
chmod +x ./dockcross-windows-shared-x64
mv ./dockcross-windows-shared-x64 ~/bin

# 32-bit (Intel)
echo -e "${green}Configuring Windows 32-bit${plain}"
docker run --rm dockcross/windows-shared-x86 > ./dockcross-windows-shared-x86
chmod +x ./dockcross-windows-shared-x86
mv ./dockcross-windows-shared-x86 ~/bin

# 64-bit (ARM64)
echo -e "${green}Configuring Windows 64-bit ARM64 (aarch64)${plain}"
docker run --rm dockcross/windows-arm64 > ./dockcross-windows-arm64
chmod +x ./dockcross-windows-arm64
mv ./dockcross-windows-arm64 ~/bin

echo -e "${green}Configuring Linux environments${plain}"

# Linux cross compilers

# 64 bit (Intel)
echo -e "${green}Configuring Linux 64-bit${plain}"
docker run --rm dockcross/linux-x64 > ./dockcross-linux-x64
chmod +x ./dockcross-linux-x64
mv ./dockcross-linux-x64 ~/bin

# 32 bit (Intel)
echo -e "${green}Configuring Linux 32-bit${plain}"
docker run --rm dockcross/linux-x86 > ./dockcross-linux-x86
chmod +x ./dockcross-linux-x86
mv ./dockcross-linux-x86 ~/bin

# ARM cross compilers

# 32-bit ARMv6 EABI
echo -e "${green}Configuring ARMv6 EABI 32-bit${plain}"
docker run --rm dockcross/linux-armv6 > ./dockcross-linux-armv6
chmod +x ./dockcross-linux-armv6
mv ./dockcross-linux-armv6 ~/bin

# 32-bit ARMv7 hard float
echo -e "${green}Configuring ARMv7 32-bit${plain}"
docker run --rm dockcross/linux-armv7 > ./dockcross-linux-armv7
chmod +x ./dockcross-linux-armv7
mv ./dockcross-linux-armv7 ~/bin

# 64-bit (arm64, aarch64)
echo -e "${green}Configuring ARM 64-bit${plain}"
docker run --rm dockcross/linux-arm64 > ./dockcross-linux-arm64
chmod +x ./dockcross-linux-arm64
mv ./dockcross-linux-arm64 ~/bin

echo -e "${green}------------------------------------------------------------------------${plain}"

# HIDAPI latest release
echo -e "${green}Configuring HIDAPI${plain}"
cd ~/Workspaces/Cpp/hidapi/ || exit
git checkout master
git pull

echo -e "${green}------------------------------------------------------------------------${plain}"

# @Tresf: Function to do "make clean" without incurring issues during build
function git-clean {
  echo -e "Resetting Cpp/hidapi"
  git clean -fd > /dev/null 2>&1 || exit     # remove all untracked files
  git reset --hard > /dev/null 2>&1 || exit  # reset all tracked files
}

# Windows environments

# 64-bit x86-64
if [[ "$1" == "all" ]] || [[ "$1" == "windows" ]] || [[ "$1" == "win32-x86-64" ]]
  then
    echo -e "${green}Building Windows 64-bit${plain}" && git-clean
    if ! dockcross-windows-shared-x64 bash -c 'sudo apt-get update && sudo apt-get --yes install libudev-dev libusb-1.0-0-dev && sudo ./bootstrap && sudo ./configure --host=x86_64-w64-mingw32 && sudo make';
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/win32-x86-64/hidapi.dll
        exit
      else
        echo -e "${green}OK${plain}"
        cp windows/.libs/libhidapi-0.dll ../../Java/Personal/hid4java/src/main/resources/win32-x86-64/hidapi.dll
    fi
  else
    echo -e "${yellow}Skipping win32-x86-64${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# 64-bit ARM win32-aarch64
if [[ "$1" == "all" ]] || [[ "$1" == "windows" ]] || [[ "$1" == "win32-aarch64" ]]
  then
    echo -e "${green}Building Windows 64-bit ARM64 (aarch64)${plain}" && git-clean
    if ! dockcross-windows-arm64 bash -c 'sudo apt-get update && sudo apt-get --yes install libudev-dev libusb-1.0-0-dev && sudo ./bootstrap && sudo ./configure --host=aarch64-w64-mingw32 && sudo make';
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/win32-aarch64/hidapi.dll
        exit
      else
        echo -e "${green}OK${plain}"
        cp windows/.libs/libhidapi-0.dll ../../Java/Personal/hid4java/src/main/resources/win32-aarch64/hidapi.dll
    fi
  else
    echo -e "${yellow}Skipping win32-aarch64${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# 32-bit x86
if [[ "$1" == "all" ]] || [[ "$1" == "windows" ]] || [[ "$1" == "win32-x86" ]]
  then
    echo -e "${green}Building Windows 32-bit${plain}" && git-clean
    if ! dockcross-windows-shared-x86 bash -c 'sudo ./bootstrap && sudo ./configure --host=i686-w64-mingw32 && sudo make';
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/win32-x86/hidapi.dll
      else
        echo -e "${green}OK${plain}"
        cp windows/.libs/libhidapi-0.dll ../../Java/Personal/hid4java/src/main/resources/win32-x86/hidapi.dll
    fi
  else
    echo -e "${yellow}Skipping win32-x86${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# Linux environments

# 64-bit (x86-64/amd64)
if [[ "$1" == "all" ]] || [[ "$1" == "linux" ]] || [[ "$1" == "linux-x86-64" ]]
  then
    echo -e "${green}Building Linux 64-bit${plain}" && git-clean
    # Note the use of a double sudo apt-get update here
    if ! dockcross-linux-x64 bash -c 'sudo apt-get update || sudo apt-get update && sudo apt-get --yes install libudev-dev libusb-1.0-0-dev && sudo ./bootstrap && sudo ./configure && sudo make';
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/linux-x86-64/libhidapi.so
        rm ../../Java/Personal/hid4java/src/main/resources/linux-amd64/libhidapi.so
        rm ../../Java/Personal/hid4java/src/main/resources/linux-x86-64/libhidapi-libusb.so
        rm ../../Java/Personal/hid4java/src/main/resources/linux-amd64/libhidapi-libusb.so
      else
        echo -e "${green}OK${plain}"
        cp linux/.libs/libhidapi-hidraw.so ../../Java/Personal/hid4java/src/main/resources/linux-x86-64/libhidapi.so
        cp linux/.libs/libhidapi-hidraw.so ../../Java/Personal/hid4java/src/main/resources/linux-amd64/libhidapi.so
        cp libusb/.libs/libhidapi-libusb.so ../../Java/Personal/hid4java/src/main/resources/linux-x86-64/libhidapi-libusb.so
        cp libusb/.libs/libhidapi-libusb.so ../../Java/Personal/hid4java/src/main/resources/linux-amd64/libhidapi-libusb.so
    fi
  else
    echo -e "${yellow}Skipping linux-x86-64${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# 32-bit
if [[ "$1" == "all" ]] || [[ "$1" == "linux" ]] || [[ "$1" == "linux-x86" ]]
  then
    echo -e "${green}Building Linux 32-bit${plain}" && git-clean
    # TODO Incorrect argument, i686 version fails with no libudev
    if ! dockcross-linux-x86 bash -c 'sudo dpkg --add-architecture i386 && sudo apt-get update && sudo apt-get --yes install libudev-dev libusb-1.0-0-dev libudev-dev:i386 libusb-1.0-0-dev:i386 && sudo ./bootstrap && sudo ./configure && sudo make';
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/linux-x86/libhidapi.so
        rm ../../Java/Personal/hid4java/src/main/resources/linux-x86/libhidapi-libusb.so
      else
        echo -e "${green}OK${plain}"
        cp linux/.libs/libhidapi-hidraw.so ../../Java/Personal/hid4java/src/main/resources/linux-x86/libhidapi.so
        cp libusb/.libs/libhidapi-libusb.so ../../Java/Personal/hid4java/src/main/resources/linux-x86/libhidapi-libusb.so
    fi
  else
    echo -e "${yellow}Skipping linux-x86${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# ARM environments

# 64-bit (arm64/aarch64)
if [[ "$1" == "all" ]] || [[ "$1" == "linux" ]] || [[ "$1" == "linux-aarch64" ]]
  then
    echo -e "${green}Building ARM64/aarch64 ARMv8${plain}" && git-clean
    # TODO Package error during "apt" phase
    if ! dockcross-linux-arm64 bash -c 'sudo dpkg --add-architecture arm64 && sudo apt-get update && sudo apt-get --yes install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu libudev-dev:arm64 libusb-1.0-0-dev:arm64 && sudo ./bootstrap && sudo ./configure --host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc && sudo make';
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/linux-aarch64/libhidapi.so
        rm ../../Java/Personal/hid4java/src/main/resources/linux-aarch64/libhidapi-libusb.so
      else
        echo -e "${green}OK${plain}"
        cp linux/.libs/libhidapi-hidraw.so ../../Java/Personal/hid4java/src/main/resources/linux-aarch64/libhidapi.so
        cp libusb/.libs/libhidapi-libusb.so ../../Java/Personal/hid4java/src/main/resources/linux-aarch64/libhidapi-libusb.so
    fi
  else
    echo -e "${yellow}Skipping linux-aarch64${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# 32-bit ARMv6 hard float (linux-arm)
if [[ "$1" == "all" ]] || [[ "$1" == "linux" ]] || [[ "$1" == "linux-arm" ]]
  then
    echo -e "${yellow}Skipping linux-arm (use RPi direct instead)${plain}" && git-clean
#    echo -e "${green}Building ARMv7 hard float  (RPi)${plain}"
#    if ! dockcross-linux-armv7 bash -c 'sudo dpkg --add-architecture armhf && sudo rm -Rf /var/lib/apt/lists && sudo apt-get update && sudo apt-get --yes install libudev-dev:armhf libusb-1.0-0-dev:armhf gcc-arm-linux-gnueabihf && sudo ./bootstrap && sudo ./configure --host=arm-linux-gnueabihf CC=arm-linux-gnueabihf-gcc && sudo make';
#      then
#        echo -e "${red}Failed${plain} - Removing damaged targets"
#        rm ../../Java/Personal/hid4java/src/main/resources/linux-arm/libhidapi.so
#      else
#        echo -e "${green}OK${plain}"
#        cp linux/.libs/libhidapi-hidraw.so ../../Java/Personal/hid4java/src/main/resources/linux-arm/libhidapi.so
#        cp libusb/.libs/libhidapi-libusb.so ../../Java/Personal/hid4java/src/main/resources/linux-arm/libhidapi-libusb.so
#    fi
  else
    echo -e "${yellow}Skipping linux-arm${plain}"
fi
echo -e "${green}------------------------------------------------------------------------${plain}"

# OS X environments

# Darwin Intel (local)
if [[ "$1" == "all" ]] || [[ "$1" == "osx" ]] || [[ "$1" == "darwin-x86-64" ]]
  then
    echo -e "${green}Building OS X Darwin Intel (x86-64)${plain}" && git-clean
    make clean
    ./bootstrap
    ./configure
    if ! make;
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/darwin-x86-64/libhidapi.dylib
      else
        echo -e "${green}OK${plain}"
        cp mac/.libs/libhidapi.0.dylib ../../Java/Personal/hid4java/src/main/resources/darwin-x86-64/libhidapi.dylib
    fi
  else
    echo -e "${yellow}Skipping darwin-x86-64${plain}"
fi

if [[ "$1" == "all" ]] || [[ "$1" == "osx" ]] || [[ "$1" == "darwin-aarch64" ]]
  then
    echo -e "${green}Building OS X Darwin AMD64 (aarch64)${plain}" && git-clean
    ./bootstrap
    ./configure
    if ! make;
      then
        echo -e "${red}Failed${plain} - Removing damaged targets"
        rm ../../Java/Personal/hid4java/src/main/resources/darwin-aarch64/libhidapi.dylib
      else
        echo -e "${green}OK${plain}"
        cp mac/.libs/libhidapi.0.dylib ../../Java/Personal/hid4java/src/main/resources/darwin-aarch64/libhidapi.dylib
    fi
  else
    echo -e "${yellow}Skipping darwin-aarch64${plain}"
fi

echo -e "${green}------------------------------------------------------------------------${plain}"

# List all file info
echo -e "${green}Resulting build files placed in hid4java:${plain}"

# Windows environments
echo -e "${green}Windows${plain}"

echo -e "${green}win32-x86-64${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/win32-x86-64/hidapi.dll

echo -e "${green}win32-x86${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/win32-x86/hidapi.dll

echo -e "${green}win32-aarch64${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/win32-aarch64/hidapi.dll

echo -e "${green}------------------------------------------------------------------------${plain}"

# Linux environments
echo -e "${green}Linux${plain}"

echo -e "${green}linux-x86-64${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/linux-x86-64/libhidapi.so
file -b ../../Java/Personal/hid4java/src/main/resources/linux-x86-64/libhidapi-libusb.so

echo -e "${green}linux-amd64${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/linux-amd64/libhidapi.so
file -b ../../Java/Personal/hid4java/src/main/resources/linux-amd64/libhidapi-libusb.so

echo -e "${green}linux-x86${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/linux-x86/libhidapi.so
file -b ../../Java/Personal/hid4java/src/main/resources/linux-x86/libhidapi-libusb.so

echo -e "${green}------------------------------------------------------------------------${plain}"

# ARM
echo -e "${green}ARM${plain}"

echo -e "${green}linux-arm${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/linux-arm/libhidapi.so
file -b ../../Java/Personal/hid4java/src/main/resources/linux-arm/libhidapi-libusb.so

echo -e "${green}linux-armel${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/linux-armel/libhidapi.so
file -b ../../Java/Personal/hid4java/src/main/resources/linux-armel/libhidapi-libusb.so

echo -e "${green}linux-aarch64${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/linux-aarch64/libhidapi.so
file -b ../../Java/Personal/hid4java/src/main/resources/linux-aarch64/libhidapi-libusb.so

echo -e "${green}------------------------------------------------------------------------${plain}"

# OS X
echo -e "${green}OS X${plain}"

echo -e "${green}darwin${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/darwin-x86-64/libhidapi.dylib

echo -e "${green}darwin-aarch64${plain}"
file -b ../../Java/Personal/hid4java/src/main/resources/darwin-aarch64/libhidapi.dylib

echo -e "${green}------------------------------------------------------------------------${plain}"

echo -e "${green}Done - Check all OK in summary above.${plain}"
