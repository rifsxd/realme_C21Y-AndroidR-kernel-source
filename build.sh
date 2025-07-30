#!/bin/bash

function usage() {
    echo "Usage: $0 <action> [defconfig]"
    echo
    echo "Actions:"
    echo "  config <defconfig>   Configure the kernel build with the given defconfig."
    echo "  compile              Compile the kernel, modules, and dtbs."
    echo "  dtc                  Compile device tree blobs (DTBs)."
    echo "  clean                Remove build artifacts."
    echo
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

if [ -f "export.env" ]; then
    source "export.env"
else
    echo "Error: export.env not found in the current directory."
    exit 1
fi

OUT_DIR="out"
BUILD_DIR="build"
MODULES_OUT="modules_out"

base_make="make O=$OUT_DIR ARCH=$ARCH LLVM=$LLVM LLVM_IAS=$LLVM_IAS CC=\"$CC\" LD=\"$LD\" AR=\"$AR\" NM=\"$NM\" OBJCOPY=\"$OBJCOPY\" OBJDUMP=\"$OBJDUMP\" STRIP=\"$STRIP\" READELF=\"$READELF\" OBJSIZE=\"$OBJSIZE\" CROSS_COMPILE=\"$CROSS_COMPILE\" CROSS_COMPILE_ARM32=\"$CROSS_COMPILE_ARM32\" CLANG_TRIPLE=\"$CLANG_TRIPLE\" LDGOLD=\"$LDGOLD\" LLVM_AR=\"$LLVM_AR\" LLVM_DIS=\"$LLVM_DIS\" BSP_BUILD_ANDROID_OS=\"$BSP_BUILD_ANDROID_OS\" BSP_BUILD_FAMILY=\"$BSP_BUILD_FAMILY\" BSP_BUILD_DT_OVERLAY=\"$BSP_BUILD_DT_OVERLAY\" BSP_BOARD_CAMERA_MODULE_CPP_VERSION=\"$BSP_BOARD_CAMERA_MODULE_CPP_VERSION\" BSP_BOARD_CAMERA_MODULE_FD_VERSION=\"$BSP_BOARD_CAMERA_MODULE_FD_VERSION\" BSP_KERNEL_VERSION=\"$BSP_KERNEL_VERSION\" BSP_BOARD_CAMERA_MODULE_VDSP_DEVICE=\"$BSP_BOARD_CAMERA_MODULE_VDSP_DEVICE\" BSP_BOARD_UNISOC_WCN_SOCKET=\"$BSP_BOARD_UNISOC_WCN_SOCKET\" BSP_BOARD_WLAN_DEVICE=\"$BSP_BOARD_WLAN_DEVICE\" BSP_BOARD_CAMERA_MODULE_DVFS=\"$BSP_BOARD_CAMERA_MODULE_DVFS\" MALI_PLATFORM_NAME=\"$MALI_PLATFORM_NAME\" TARGET_BOARD_PLATFORM=\"$TARGET_BOARD_PLATFORM\" TARGET_BOARD=\"$TARGET_BOARD\""

case "$1" in
    clean)
        rm -rf $OUT_DIR $BUILD_DIR $MODULES_OUT kernel_log.log
        ;;
    config)
        if [ -z "$2" ]; then
            echo "Error: Please specify a defconfig (e.g., rmx3263_defconfig)"
            exit 1
        fi
        eval "$base_make $2"
        ;;
    compile)
        eval "$base_make -j$(nproc) Image modules dtbs 2>&1 | tee $OUT_DIR/kernel_log.log"
        ;;
    dtc)
        eval "$base_make -j$(nproc) dtbs"
        ;;
    *)
        usage
        ;;
esac