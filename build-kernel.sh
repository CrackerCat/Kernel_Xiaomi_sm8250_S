#!/bin/bash

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'

#
# Enviromental Variables
#

# Set host name
export KBUILD_BUILD_HOST="Voayger-sever"
export KBUILD_BUILD_USER="TheVoyager"

# Set compiler path
PATH=/usr/bin/:${PATH}

# Set the current branch name
BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

# Set the last commit sha
COMMIT=$(git rev-parse --short HEAD)

# Set current date
DATE=$(date +"%d.%m.%y")

# Set our directory
OUT_DIR=out/

# Set script config dir
CONFIG=build_config

#Set csum
CSUM=$(cksum <<<${COMMIT} | cut -f 1 -d ' ')

if [ ! -f "${OUT_DIR}Version" ] || [ ! -d "${OUT_DIR}" ]; then
	echo "init Version"
	mkdir -p $OUT_DIR
	echo 1 >${OUT_DIR}Version
fi

#Set build count
BUILD=$(cat out/Version)

# How much kebabs we need? Kanged from @raphielscape :)
if [[ -z "${KEBABS}" ]]; then
	COUNT="$(grep -c '^processor' /proc/cpuinfo)"
	export KEBABS="$((COUNT * 2))"
fi

function enable_lto() {
	scripts/config --file ${OUT_DIR}/.config \
	-e LTO_CLANG

    	# Make olddefconfig
	cd ${OUT_DIR} || exit
	make -j${KEBABS} ${ARGS} olddefconfig
	cd ../ || exit
}

function disable_lto() {
	scripts/config --file ${OUT_DIR}/.config \
	-d LTO_CLANG
}

function checkbuild() {
	if [[ ! -f ${OUT_DIR}/arch/arm64/boot/Image ]] && [[ ! -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
		echo "Error in ${os} build!!"
        	git checkout arch/arm64/boot/dts/vendor &>/dev/null
		exit 1
	fi
}

function out_product() {
	find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + >${OUT_DIR}/arch/arm64/boot/dtb

	mkdir -p anykernel/kernels/$os
	# Import Anykernel3 folder
	if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
		cp ${OUT_DIR}/arch/arm64/boot/Image.gz anykernel/kernels/$os
	else
		if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
			cp ${OUT_DIR}/arch/arm64/boot/Image anykernel/kernels/$os
		fi
	fi
	cp ${OUT_DIR}/arch/arm64/boot/dtb anykernel/kernels/$os
	cp ${OUT_DIR}/arch/arm64/boot/dtbo.img anykernel/kernels/$os
}

function clean_up_outfolder() {
	echo "------------ Clean up dts folder ------------"
	git checkout arch/arm64/boot/dts/vendor &>/dev/null
	echo "----------- Cleanup up old output -----------"
	if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]] && [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
		rm -r ${OUT_DIR}/arch/arm64/boot/
	fi
	echo "------- Cleanup up previous kernelzip -------"
	if [[ -d anykernel/out/ ]]; then
			rm -r anykernel/out/
			mkdir anykernel/out/
	fi
	echo "-------------------- Done! ------------------"
}

function post_complie_compress()
{
	if [ ! -d "anykernel" ]; then
		git clone https://github.com/lateautumn233/AnyKernel3 -b kona --depth=1 anykernel && cd anykernel
	else
		cd anykernel || exit
	fi
	zip -r9 "${ZIPNAME}" ./* -x .git .gitignore out/ ./*.zip
	if [[ ! MULTI_BUILD ]]; then
		mkdir out
	fi
	mv *.zip out/
	cd ../
}

function start_build() {
	if [[ ! MULTI_BUILD -eq 1 ]]; then
		clean_up_outfolder
	fi

	# Start Build
	echo "------ Starting ${OS} Build, Device ${DEVICE} ------"

	os=${OS,,}
	source build_config/build.args.${OS}
	export ARCH
	export LLVM
	export CLANG_TRIPLE
	export CROSS_COMPILE
	export CROSS_COMPILE_COMPAT
	export CC
	export HOSTCC
	export HOSTCXX
	
	# Make defconfig
	make -j${KEBABS} O=${OUT_DIR} vendor/output/"${DEVICE}"_defconfig

	overwrite_config

	# Make olddefconfig
	cd ${OUT_DIR} || exit
	make -j${KEBABS} O=${OUT_DIR} CC="ccache clang" HOSTCC="ccache gcc" HOSTCXX="cache g++" olddefconfig
	cd ../ || exit

	if [[ MORE_SCRIPTS -eq 1 ]]; then	
		EXTRA_SCRIPT=$CONFIG/$PACTH_NAME
		echo "----- Including $EXTRA_SCRIPT -----"
		source $EXTRA_SCRIPT
	fi

	if [[ "$@" =~ "lto"* ]]; then
		# Enable LTO
		enable_lto
		make -j${KEBABS} O=${OUT_DIR} 2>&1 | tee build.log
	else
		make -j${KEBABS} O=${OUT_DIR} 2>&1 | tee build.log
	fi

	ZIPNAME="Voyager-${DEVICE^^}-build${BUILD}-${OS}-${CSUM}-${DATE}.zip"
	export ZIPNAME	

	echo "------ Filename: ${ZIPNAME} ------"

	checkbuild

	out_product

	cd anykernel || exit
	zip -r9 "${ZIPNAME}" ./* -x .git .gitignore out/ ./*.zip
	mv ${ZIPNAME} out/
	cd ../

	echo "------ Finishing ${OS} Build, Device ${DEVICE} ------"
}

# Complie with a list of specialized devices
function build_by_list() {
	clean_up_outfolder
	while read rows
	do 
   		 DEVICE=$rows
   		 echo $DEVICE
   		 start_build
	done < device_list

	git checkout arch/arm64/boot/dts/vendor &>/dev/null
}

# If you need to invoke other script
if [[ "$*" =~ "-A" ]]; then
	export MORE_SCRIPTS=1
fi

#
# Do complie 
#
START=$(date +"%s")

if [[ ! "$2" =~ ""* ]] && [[ ! "$1" =~ "list"* ]]; then
	DEVICE=$1
	OS=$2
	export OS
	export DEVICE
	export MULTI_BUILD=0
	start_build
fi

if [[ "$1" =~ "list"* ]]; then
	export MULTI_BUILD=1
	build_by_list
fi

END=$(date +"%s")
DIFF=$((END - START))

echo $(($BUILD + 1)) >${OUT_DIR}Version
#
# Finish complie 
#


#
# Functions for help
#

# If you need clean up when complication is manually terminated..
if [[ "$1" =~ "clean" ]]; then
	clean_up_outfolder
fi

# If you need to generate a device list for kernel building
if [[ "$1" =~ "-g" ]]; then
	echo "------ Generating device list ------"
	echo "$*" | awk -F "-g " '{print $2}' | xargs -n1 > device_list
	echo "------ Save to current folder ------"
	echo "-------------- Done! ---------------"
fi

#
# Functions for help
#

# Self-introduction function
SELF_INTRO1="   This is a commonized script for kernel building. \
		You can use it to complie single target device \
		or complie multi targets in one command. \
		With this script, you can choose the complie type \
		that your system compatible with to enable \
		some specific configs or flags. \
		It also can automically pack the kernel image \
		and dtb, dtbo with Anykernel to a flashable zip \
		after complie sequence finish. You can also \
		invoke a extra script (To see more information, \
		please see build_config/build.args) \
		after making old defconfig to do some special changes. \
		For more information, see the script usage."

SELF_INTRO2=$(echo "Usage1: bash build-kernel.sh [device_code] [system_type] [-A]")
SELF_INTRO3=$(echo "Usage2: bash build-kernel.sh list [-A]")
SELF_INTRO4=$(echo "Usage3: bash build-kernel.sh -g [device_codes (separated with space)]")
SELF_INTRO5=$(echo "Usage4: bash build-kernel.sh clean")
SELF_INTRO6=$(echo "-A:                          Include extra script")
SELF_INTRO7=$(echo "-g [device_codes]:           generate a list of device_code for continuous complie")
SELF_INTRO7=$(echo "-clean:                      clean up work folders include dts, complie output and kernelzip")

if [[ "$1" =~ "-h" ]]; then
		echo $SELF_INTRO1;
		echo "          ";
		echo $SELF_INTRO2;
		echo $SELF_INTRO3;
		echo $SELF_INTRO4;
		echo "          ";
		echo $SELF_INTRO5;
		echo $SELF_INTRO6;
		echo $SELF_INTRO7;
fi
