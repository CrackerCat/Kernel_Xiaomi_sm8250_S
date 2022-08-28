# auto-detect subdirs
ifeq ($(CONFIG_ARCH_SDXPOORWILLS), y)
include $(srctree)/techpack/audio_psy/config/sdxpoorwillsauto.conf
export $(shell sed 's/=.*//' $(srctree)/techpack/audio_psy/config/sdxpoorwillsauto.conf)
endif
ifeq ($(CONFIG_ARCH_SM8150), y)
include $(srctree)/techpack/audio_psy/config/sm8150auto.conf
export $(shell sed 's/=.*//' $(srctree)/techpack/audio_psy/config/sm8150auto.conf)
endif
ifeq ($(CONFIG_ARCH_SDMSHRIKE), y)
include $(srctree)/techpack/audio_psy/config/sm8150auto.conf
export $(shell sed 's/=.*//' $(srctree)/techpack/audio_psy/config/sm8150auto.conf)
endif
ifeq ($(CONFIG_ARCH_KONA), y)
include $(srctree)/techpack/audio_psy/config/konaauto.conf
export $(shell sed 's/=.*//' $(srctree)/techpack/audio_psy/config/konaauto.conf)
endif
ifeq ($(CONFIG_ARCH_LITO), y)
include $(srctree)/techpack/audio_psy/config/litoauto.conf
export $(shell sed 's/=.*//' $(srctree)/techpack/audio_psy/config/litoauto.conf)
endif
ifeq ($(CONFIG_ARCH_SDM660), y)
include $(srctree)/techpack/audio_psy/config/sdm660auto.conf
export $(shell sed 's/=.*//' $(srctree)/techpack/audio_psy/config/sdm660auto.conf)
endif

# Use USERINCLUDE when you must reference the UAPI directories only.
USERINCLUDE     += \
                -I$(srctree)/techpack/audio_psy/include/uapi \
                -I$(srctree)/techpack/audio_psy/include

# Use LINUXINCLUDE when you must reference the include/ directory.
# Needed to be compatible with the O= option
LINUXINCLUDE    += \
                -I$(srctree)/techpack/audio_psy/include/uapi \
                -I$(srctree)/techpack/audio_psy/include/elliptic \
                -I$(srctree)/techpack/audio_psy/include

#for mius start
ifeq ($(CONFIG_US_PROXIMITY), y)
LINUXINCLUDE    += \
                -I$(srctree)/techpack/audio_psy/include/mius
endif
#for mius end

ifeq ($(CONFIG_ARCH_SDXPOORWILLS), y)
LINUXINCLUDE    += \
                -include $(srctree)/techpack/audio_psy/config/sdxpoorwillsautoconf.h
endif
ifeq ($(CONFIG_ARCH_SM8150), y)
LINUXINCLUDE    += \
                -include $(srctree)/techpack/audio_psy/config/sm8150autoconf.h
endif
ifeq ($(CONFIG_ARCH_SDMSHRIKE), y)
LINUXINCLUDE    += \
                -include $(srctree)/techpack/audio_psy/config/sm8150autoconf.h
endif
ifeq ($(CONFIG_ARCH_KONA), y)
LINUXINCLUDE    += \
                -include $(srctree)/techpack/audio_psy/config/konaautoconf.h
endif
ifeq ($(CONFIG_ARCH_LITO), y)
LINUXINCLUDE    += \
                -include $(srctree)/techpack/audio_psy/config/litoautoconf.h
endif
ifeq ($(CONFIG_ARCH_SDM660), y)
LINUXINCLUDE    += \
                -include $(srctree)/techpack/audio_psy/config/sdm660autoconf.h
endif
obj-y += soc/
obj-y += dsp/
obj-y += ipc/
obj-y += asoc/
