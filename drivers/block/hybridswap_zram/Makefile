# SPDX-License-Identifier: GPL-2.0-only
zram-y	:=	zcomp.o zram_drv.o
zram-$(CONFIG_HYBRIDSWAP_ZRAM_DEDUP)	+=	zram_dedup.o

obj-$(CONFIG_HYBRIDSWAP_ZRAM)	+=	zram.o

zram-$(CONFIG_HYBRIDSWAP) += hybridswap/hybridswap_main.o
zram-$(CONFIG_HYBRIDSWAP_SWAPD) += hybridswap/hybridswap_swapd.o
zram-$(CONFIG_HYBRIDSWAP_ASYNC_COMPRESS) += hybridswap/hybridswap_akcompress.o
zram-$(CONFIG_HYBRIDSWAP_CORE) += hybridswap/hybridswap_eswap.o
