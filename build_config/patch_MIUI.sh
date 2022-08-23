#!/bin/bash

dts_source=arch/arm64/boot/dts/vendor/qcom
# Correct panel dimensions on MIUI builds
function miui_fix_dimens() {
	sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
	sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
	sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-k11a-38-08-0a-dsc-cmd.dtsi
	sed -i 's/<71>/<710>/g' $dts_source/dsi-panel-j1s*
	sed -i 's/<71>/<710>/g' $dts_source/dsi-panel-j2*
	sed -i 's/<155>/<1544>/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
	sed -i 's/<155>/<1545>/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
	sed -i 's/<155>/<1546>/g' $dts_source/dsi-panel-k11a-38-08-0a-dsc-cmd.dtsi
	sed -i 's/<154>/<1537>/g' $dts_source/dsi-panel-j1s*
	sed -i 's/<154>/<1537>/g' $dts_source/dsi-panel-j2*
}

# Enable back mi smartfps while disabling qsync min refresh-rate
function miui_fix_fps() {
	sed -i 's/qcom,mdss-dsi-qsync-min-refresh-rate/\/\/qcom,mdss-dsi-qsync-min-refresh-rate/g' $dts_source/dsi-panel*
	sed -i 's/\/\/ mi,mdss-dsi-smart-fps-max_framerate/mi,mdss-dsi-smart-fps-max_framerate/g' $dts_source/dsi-panel*
	sed -i 's/\/\/ mi,mdss-dsi-pan-enable-smart-fps/mi,mdss-dsi-pan-enable-smart-fps/g' $dts_source/dsi-panel*
	sed -i 's/\/\/ qcom,mdss-dsi-pan-enable-smart-fps/qcom,mdss-dsi-pan-enable-smart-fps/g' $dts_source/dsi-panel*
}

# Enable back refresh rates supported on MIUI
function miui_fix_dfps() {
	sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-37-02-0a-dsc-video.dtsi
	sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-37-02-0b-dsc-video.dtsi
	sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-36-02-0c-dsc-video.dtsi
	sed -i 's/144 120 90 60/144 120 90 60 50 48 30/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
}

# Enable back brightness control from dtsi
function miui_fix_fod() {
	sed -i 's/\/\/39 01 00 00 01 00 03 51 03 FF/39 01 00 00 01 00 03 51 03 FF/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 03 FF/39 01 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
	sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-mp-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-mp-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j1u-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j1u-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 00 00/39 01 00 00 00 00 03 51 00 00/g' $dts_source/dsi-panel-j2-38-0c-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 00 00/39 01 00 00 00 00 03 51 00 00/g' $dts_source/dsi-panel-j2-38-0c-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j2-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j2-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2-mp-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2-mp-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j2-p1-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j2-p1-42-02-0b-dsc-cmd.dtsi
  	sed -i 's/\/\/39 00 00 00 00 00 03 51 0D FF/39 00 00 00 00 00 03 51 0D FF/g' $dts_source/dsi-panel-j2-p2-1-38-0c-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 11 00 03 51 03 FF/39 01 00 00 11 00 03 51 03 FF/g' $dts_source/dsi-panel-j2-p2-1-38-0c-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2-p2-1-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2-p2-1-42-02-0b-dsc-cmd.dtsi
	sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2s-mp-42-02-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2s-mp-42-02-0a-dsc-cmd.dtsi
	sed -i 's/\/\/39 00 00 00 00 00 03 51 03 FF/39 00 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j9-38-0a-0a-fhd-video.dtsi
	sed -i 's/\/\/39 01 00 00 00 00 03 51 03 FF/39 01 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j9-38-0a-0a-fhd-video.dtsi
}

function use_prebuilt_dtbo() {
	if [[ $DEVICE == lmi ]]; then
		echo "------------ PREBUILT DTBO USED! ------------"
		export PREBUILT_DTBO=1
	fi
}

# Edit it by yourself
function patch_out_product_hook() {
	if [[ $PREBUILT_DTBO == 1 ]]; then
		echo "--------- APPLYING PREBUILT DTBO... ---------"
		cp build_config/prebuilts/dtbo.img anykernel/kernels/$OS
		echo "--------------- DTBO APPLYED! ---------------"
	fi
}

use_prebuilt_dtbo
miui_fix_dimens
miui_fix_fps
miui_fix_dfps
miui_fix_fod
echo "-------------- Patch Applied! ---------------"
