# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the kernel multimedia device drivers.
#

ccflags-y += -I $(srctree)/drivers/media/cedar-ve
ccflags-$(CONFIG_AW_VIDEO_DYNAMIC_DEBUG) += -DDYNAMIC_DEBUG_MODULE

obj-$(CONFIG_AW_VIDEO_ENCODER_DECODER) += sunxi-ve.o
sunxi-ve-objs := cedar_ve.o flush_cache.o
