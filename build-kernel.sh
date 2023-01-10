#!/bin/bash

#
# Enviromental Variables
#

# Set host name
export KBUILD_BUILD_HOST="Voayger-server"
export KBUILD_BUILD_USER="TheVoyager"

# Set the last commit sha
COMMIT=$(git rev-parse --short HEAD)

# Set current date
DATE=$(date +"%d.%m.%y")

# Set our directory
OUT_DIR=out/

# Set defconfig folder (Root is arch/arm64/configs)
DEFCONFIG_DIR=arch/arm64/configs/vendor/output

# Set script config dir
ARGS_DIR=build_config

#Set csum
CSUM=$(cksum <<<"${COMMIT}" | cut -f 1 -d ' ')

# How much kebabs we need? Kanged from @raphielscape :)
if [[ -z "${KEBABS}" ]]; then
	COUNT="$(grep -c '^processor' /proc/cpuinfo)"
	export KEBABS="$((COUNT * 2))"
fi

function checkbuild() {
	if [[ ! -f ${OUT_DIR}/arch/arm64/boot/Image ]] && [[ ! -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
		echo "Error in ${OS} build!!"
        	git checkout arch/arm64/boot/dts/vendor &>/dev/null
		exit 1
	fi
}

function out_product() {
	dts_source=arch/arm64/boot/dts
	find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + >${OUT_DIR}/arch/arm64/boot/dtb

	if [ ! -d "anykernel" ]; then
		git clone https://github.com/TheVoyager0777/AnyKernel3.git -b kona --depth=1 anykernel
	fi

	mkdir -p anykernel/kernels/"$OS"
	# Import Anykernel3 folder
	if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
		cp ${OUT_DIR}/arch/arm64/boot/Image.gz anykernel/kernels/"$OS"
	else
		if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
			cp ${OUT_DIR}/arch/arm64/boot/Image anykernel/kernels/"$OS"
		fi
	fi
	cp ${OUT_DIR}/arch/arm64/boot/dtb anykernel/kernels/"$OS"
	cp ${OUT_DIR}/arch/arm64/boot/dtbo.img anykernel/kernels/"$OS"

	rm -r ${OUT_DIR}/arch/arm64/boot/

	# If we use a patch script..
	if [[ $PATCH_OUT_PRODUCT_HOOK == 1 ]]; then
		patch_out_product_hook
	fi
}

function clean_up_outfolder() {
	echo "------------ Clean up dts folder ------------"
	git checkout arch/arm64/boot/dts/vendor &>/dev/null
	echo "----------- Cleanup up old output -----------"
	if [[ -d ${OUT_DIR}/arch/arm64/boot/ ]]; then
		rm -r ${OUT_DIR}/arch/arm64/boot/
	fi
	echo "------- Cleanup up previous kernelzip -------"
	if [[ ! MULTI_BUILD -eq 1 ]]; then
		if [[ -d anykernel/out/ ]]; then
			rm -r anykernel/out/
			mkdir anykernel/out
		fi
	fi

	# Cleanup temp
	if [[ -d anykernel/kernels/"${OS}" ]]; then
		rm -r anykernel/kernels/"${OS}"
	fi

	echo "-------------------- Done! ------------------"
}

function ak3_compress()
{
		cd anykernel || exit
		zip -r9 "${ZIPNAME}" ./* -x .git .gitignore out/ ./*.zip
		mv ./*.zip out/
		cd ../
}

function start_build() {
	trap "echo aborting.." 2 || exit 1;

	if [[ MULTI_BUILD -eq 1 ]] && [[ -d ${OUT_DIR}/arch/arm64/boot/ ]]; then
		rm -r ${OUT_DIR}/arch/arm64/boot/
	fi

	#Set build count
	if [[ -f out/Version ]]; then
		BUILD=$(cat out/Version)
	fi

	if [ ! -f "${OUT_DIR}Version" ] || [ ! -d "${OUT_DIR}" ]; then
		echo "init Version"
		mkdir -p $OUT_DIR
		echo 1 >${OUT_DIR}Version
	fi

	# Start Build
	echo "------ Starting ${OS^} Build, Device ${DEVICE^^} ------"

	# shellcheck source=/dev/null
	source ${ARGS_DIR}/build.args."${OS^^}"

	# shellcheck source=/dev/null
	source build_config/"${PACTH_NAME}"

	# Set compiler path
	PATH=${CLANG_PATH}/bin:$PATH
	export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH
	
	# Make defconfig
	DEFCONFIG=$(echo ${DEFCONFIG_DIR} | awk -F "arch/arm64/configs/" '{print $2}')
	make -j"${KEBABS}" "${ARGS[@]}" "${DEFCONFIG}"/"${DEVICE}"_defconfig

	overwrite_config

	# Make olddefconfig
	cd ${OUT_DIR} || exit
	make -j"${KEBABS}" "${ARGS[@]}" CC="ccache clang" HOSTCC="ccache gcc" HOSTCXX="ccache g++" olddefconfig
	cd ../ || exit

	make -j"${KEBABS}" "${ARGS[@]}" CC="ccache clang" HOSTCC="ccache gcc" HOSTCXX="ccache g++" 2>&1 | tee build.log

	ZIPNAME="Voyager-${DEVICE^^}-build${BUILD}-${OS}-${CSUM}-${DATE}.zip"
	sed -i "N;1a{$ZIPNAME}" ${OUT_DIR}Version
	export ZIPNAME	

	echo "------ Filename: ${ZIPNAME} ------"

	checkbuild

	out_product

	ak3_compress

	echo "------ Finishing ${OS^} Build, Device ${DEVICE^^} ------"
}

# Complie with a list of specialized devices
function new_build_by_list() {
	clean_up_outfolder
	export MULTI_BUILD=1
	export LIST=$device_list
	j=$(wc -l "${LIST}" | awk -F " " '{print $1}')

	for ((i=1; i<=j; i++))
	do
		DEVICE=$(awk 'NR=='$i' {print $1}'  "$LIST")
		OS=$(awk 'NR=='$i' {print $2}'  "$LIST")

		git checkout arch/arm64/boot/dts/vendor &>/dev/null
		trap "echo aborting.." 2 || exit 1;
		start_build
	done
}

#
# Do complie 
#

if [[ "$1" ]]; then
	device_list=$(find ${ARGS_DIR} -name "$1")
	supported_device=$(find ${DEFCONFIG_DIR} -name "$1"_defconfig | awk -F "/" '{print $NF}')

	if [[ $device_list ]]; then
		list_name=$(echo "$device_list" | awk -F "/" '{print $2}')
	elif [[ $supported_device ]]; then
		device_name=$(echo "$supported_device" | awk -F "_" '{print $1}')
	fi

	case $1 in
		"$list_name")
			echo "---- Detect build list for bulk complie! ----"
			new_build_by_list
		;;

		"help")
			printf "Usage: 			bash build-kernel.sh [device_code] [system_type] \n
		        bash build-kernel.sh [listfile] \n
		        bash build-kernel.sh clean clean up work folders include dts, complie output and kernelzip"
		;;

		"clean")
			case $2 in
				"outdir")
					if [[ -d ${OUT_DIR} ]]; then
						rm -r ${OUT_DIR}
					fi
				;;

				"kzip")
					clean_up_outfolder
				;;
			esac	
		;;

		"$device_name")
			OS=$2
			TARGET_SYS=$(find ${ARGS_DIR} -name build.args."${OS^^}" | awk -F "/" '{print $2}' | awk -F "." '{print $3}')
			if [[ ! ${TARGET_SYS,,} ]]; then
				echo "There is no args configuration for this system"
			else
				echo "Found args configuration for selected system"
			fi

			case $2 in 
				"${TARGET_SYS,,}")
					trap "echo Abort.." 2
					DEVICE=$1
					clean_up_outfolder
					export MULTI_BUILD=0
					start_build
				;;
			esac
		;;
	esac
else
	echo "Argument is needed"
fi

