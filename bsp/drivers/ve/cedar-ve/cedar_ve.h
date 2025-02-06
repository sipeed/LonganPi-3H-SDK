/* SPDX-License-Identifier: GPL-2.0-or-later */
/* Copyright(c) 2020 - 2023 Allwinner Technology Co.,Ltd. All rights reserved. */
/*
 *    Filename: cedarv_ve.h
 *     Version: 0.01alpha
 * Description: Video engine driver API, Don't modify it in user space.
 *     License: GPLv2
 *
 *		Author  : xyliu <xyliu@allwinnertech.com>
 *		Date    : 2016/04/13
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */
 /* Notice: It's video engine driver API, Don't modify it in user space. */
#ifndef _CEDAR_VE_H_
#define _CEDAR_VE_H_
#include <linux/types.h>

enum IOCTL_CMD {
	IOCTL_UNKOWN = 0x100,
	IOCTL_GET_ENV_INFO,
	IOCTL_WAIT_VE_DE,
	IOCTL_WAIT_VE_EN,
	IOCTL_RESET_VE,
	IOCTL_ENABLE_VE,
	IOCTL_DISABLE_VE,
	IOCTL_SET_VE_FREQ,

	IOCTL_CONFIG_AVS2 = 0x200,
	IOCTL_GETVALUE_AVS2,
	IOCTL_PAUSE_AVS2,
	IOCTL_START_AVS2,
	IOCTL_RESET_AVS2,
	IOCTL_ADJUST_AVS2,
	IOCTL_ENGINE_REQ,
	IOCTL_ENGINE_REL,
	IOCTL_ENGINE_CHECK_DELAY,
	IOCTL_GET_IC_VER,
	IOCTL_ADJUST_AVS2_ABS,
	IOCTL_FLUSH_CACHE,
	IOCTL_SET_REFCOUNT,
	IOCTL_FLUSH_CACHE_ALL,
	IOCTL_TEST_VERSION,

	IOCTL_GET_LOCK = 0x310,
	IOCTL_RELEASE_LOCK,

	IOCTL_SET_VOL = 0x400,

	IOCTL_WAIT_JPEG_DEC = 0x500,
	/* for get the ve ref_count for ipc to delete the semphore */
	IOCTL_GET_REFCOUNT,

	/* for iommu */
	IOCTL_GET_IOMMU_ADDR,
	IOCTL_FREE_IOMMU_ADDR,

	/* map/unmap dma buffer to get/free phyaddr by dma fd */
	/* get/free iommu addr will not use since kernel 5.4  */
	IOCTL_MAP_DMA_BUF,
	IOCTL_UNMAP_DMA_BUF,

	/* for fush cache range since kernel 5.4 */
	IOCTL_FLUSH_CACHE_RANGE,

	/* for debug */
	IOCTL_SET_PROC_INFO,
	IOCTL_STOP_PROC_INFO,
	IOCTL_COPY_PROC_INFO,

	IOCTL_SET_DRAM_HIGH_CHANNAL = 0x600,

	/* debug for decoder and encoder */
	IOCTL_PROC_INFO_COPY = 0x610,
	IOCTL_PROC_INFO_STOP,

	IOCTL_POWER_SETUP = 0x700,
	IOCTL_POWER_SHUTDOWN,

	IOCTL_GET_VE_DEFAULT_FREQ = 0x710, /* MHz */
	IOCTL_UPDATE_CASE_LOAD_PARAM = 0x711,
};

#define VE_LOCK_VDEC        0x01
#define VE_LOCK_VENC        0x02
#define VE_LOCK_JDEC        0x04
#define VE_LOCK_00_REG      0x08
#define VE_LOCK_04_REG      0x10
#define VE_LOCK_ERR         0x80

#define VE_LOCK_PROC_INFO   0x1000

struct cedarv_env_infomation {
	unsigned int phymem_start;
	int  phymem_total_size;
	uint64_t  address_macc;
};

struct dma_buf_param {
	int				fd;       /* [in] */
	unsigned int	phy_addr; /* [out] */
};

struct cache_range {
	uint64_t	start;
	uint64_t	end;
};

struct ve_dvfs_info {
	unsigned int	dvfs_index;
	unsigned int	voltage; /* mv */
	unsigned int    ve_freq; /* MHz */
};

#define SUN55IW3_CHIP_ID_A523M (0x5200)

#define SUN55IW3_DVFS_VE_VF0   (0x00)
#define SUN55IW3_DVFS_VE_VF1   (0x01)
#define SUN55IW3_DVFS_VE_VF2   (0x02)
#define SUN55IW3_DVFS_VE_VF2_1 (0x12)
#define SUN55IW3_DVFS_VE_VF3   (0x04)
#define SUN55IW3_DVFS_VE_VF3_1 (0x14)
#define SUN55IW3_DVFS_VE_VF4   (0x05)
#define SUN55IW3_DVFS_VE_VF5   (0x06)

struct ve_dvfs_info ve_dvfs_sun55iw3[] = {
	/*      dvfs-index      vol-mv  freq-MHz */
	{0x00,                      0,   498}, /* default */
	{SUN55IW3_DVFS_VE_VF0,    900,   498}, /* VF0 */
	{SUN55IW3_DVFS_VE_VF1,    920,   520}, /* VF1 */
	{SUN55IW3_DVFS_VE_VF2,    920,   520}, /* VF2 */
	{SUN55IW3_DVFS_VE_VF2_1,  920,   520}, /* VF2_1 */
	{SUN55IW3_DVFS_VE_VF3,	  920,   520}, /* VF3 */
	{SUN55IW3_DVFS_VE_VF3_1,  920,   520}, /* VF3_1 */
	{SUN55IW3_DVFS_VE_VF4,	  920,   576}, /* VF4 */
	{SUN55IW3_DVFS_VE_VF5,	  920,   432}, /* VF5 */
};

enum VE_CODEC_FORMAT {

	VE_FORMAT_UNKNOW         = 0,
	VE_DECODER_FORMAT_MIN    = 1,
	VE_DECODER_FORMAT_H264,
	VE_DECODER_FORMAT_H265,
	VE_DECODER_FORMAT_VP9,
	VE_DECODER_FORMAT_OTHER,
	VE_DECODER_FORMAT_MAX = 0x100,

	VE_ENCODER_FORMAT_MIN  = 0x101,
	VE_ENCODER_FORMAT_H264,
	VE_ENCODER_FORMAT_H265,
	VE_ENCODER_FORMAT_JPEG,
};

struct ve_case_load_param {
	int width;
	int height;
	int frame_rate;
	int codec_format;
	int is_remove_cur_param;
	int thread_channel_id;
};

#endif
