// SPDX-License-Identifier: GPL-2.0
/*
 * sunxi_drm.h
 *
 * Copyright (c) 2007-2024 Allwinnertech Co., Ltd.
 *
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */
#ifndef _SUNXI_DRM_H
#define _SUNXI_DRM_H
#include <uapi/drm/drm.h>

#define DCI_REG_COUNT 66
#define DEBAND_REG_COUNT 22
#define SHARP_DE35x_COUNT 26
#define HDR_REG_COUNT 6
#define SNR_REG_COUNT 11
#define ASU_REG_COUNT 9

/* -- dci api -- */
/* dci pqd ioctl para */
typedef struct _dci_module_param_t {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int value[DCI_REG_COUNT];
} dci_module_param_t;

/* dci commit para */
struct de_dci_commit_para {
	u32 enable;
	u32 demo_en;
};

/* dci blob data */
struct de_dci_para {
	struct de_dci_commit_para commit;
	dci_module_param_t pqd;
	/* enum pq_dirty_type_mask */
	u32 dirty;
};

/* -- dci api end -- */

/* -- deband api -- */
/* deband pqd ioctl para */
typedef struct _deband_module_param_t {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int value[DEBAND_REG_COUNT];
} deband_module_param_t;

/* deband commit para */
struct de_deband_commit_para {
	u32 enable;
	u32 demo_en;
};

/* deband blob data */
struct de_deband_para {
	struct de_deband_commit_para commit;
	deband_module_param_t pqd;
	/* enum pq_dirty_type_mask */
	u32 dirty;
};

/* -- deband api end -- */

/* -- sharp api -- */
/* sharp pqd ioctl para */
typedef struct _sharp_de35x_t{
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int value[SHARP_DE35x_COUNT];
} sharp_de35x_t;

/* sharp commit para */
struct de_sharp_commit_para {
	u32 enable;
	u32 demo_en;
	u32 lti_level;
	u32 peak_level;
};

/* sharp blob data */
struct de_sharp_para {
	struct de_sharp_commit_para commit;
	sharp_de35x_t pqd;
	/* enum pq_dirty_type_mask */
	u32 dirty;
};

/* -- sharp api end -- */

/* -- hdr/gtm api -- */
/* hdr pqd ioctl para */
typedef struct _hdr_module_param_t {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int value[HDR_REG_COUNT];
} hdr_module_param_t;

/* hdr commit para */
struct de_hdr_commit_para {
	u32 enable;
//not support demo mode
};

/* hdr blob data */
struct de_hdr_para {
	struct de_hdr_commit_para commit;
	hdr_module_param_t pqd;
	/* enum pq_dirty_type_mask */
	u32 dirty;
};

/* -- hdr/gtm api end -- */

/* -- snr api -- */
/* snr pqd ioctl para */
typedef struct _snr_module_param_t {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int value[SNR_REG_COUNT];
} snr_module_param_t;

enum snr_buffer_flags {
	DISP_BF_NORMAL     = 0, /* non-stereo */
	DISP_BF_STEREO_TB  = 1 << 0, /* stereo top-bottom */
	DISP_BF_STEREO_FP  = 1 << 1, /* stereo frame packing */
	DISP_BF_STEREO_SSH = 1 << 2, /* stereo side by side half */
	DISP_BF_STEREO_SSF = 1 << 3, /* stereo side by side full */
	DISP_BF_STEREO_LI  = 1 << 4, /* stereo line interlace */
	/*
	 * 2d plus depth to convert into 3d,
	 * left and right image using the same frame buffer
	 */
	DISP_BF_STEREO_2D_DEPTH  = 1 << 5,
};

/* snr commit para */
struct de_snr_commit_para {
	u32 b_trd_out;
	unsigned char en;
	unsigned char demo_en;
	unsigned char y_strength;
	unsigned char u_strength;
	unsigned char v_strength;
	unsigned char th_ver_line;
	unsigned char th_hor_line;
	enum snr_buffer_flags   flags;
};

/* snr blob data */
struct de_snr_para {
	struct de_snr_commit_para commit;
	snr_module_param_t pqd;
	/* enum pq_dirty_type_mask */
	u32 dirty;
};

/* -- snr api end -- */

/* -- asu api -- */
/* asu pqd ioctl para */
typedef struct _asu_module_param_t {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int value[ASU_REG_COUNT];
} asu_module_param_t;

/* asu commit para */
struct de_asu_commit_para {
	u32 enable;
	u32 demo_en;
};

/* asu blob data */
struct de_asu_para {
	struct de_asu_commit_para commit;
	asu_module_param_t pqd;
	/* enum pq_dirty_type_mask */
	u32 dirty;
};

/* -- asu api end -- */

/* --fcm api -- */
typedef struct fcm_hardware_data {
	char name[32];
	u32 lut_id;

	s32 hbh_hue[28];
	s32 sbh_hue[28];
	s32 ybh_hue[28];

	s32 angle_hue[28];
	s32 angle_sat[13];
	s32 angle_lum[13];

	s32 hbh_sat[364];
	s32 sbh_sat[364];
	s32 ybh_sat[364];

	s32 hbh_lum[364];
	s32 sbh_lum[364];
	s32 ybh_lum[364];
} fcm_hardware_data_t;

/* fcm pqd ioctl para */
struct fcm_info {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	fcm_hardware_data_t fcm_data;
};

/* fcm commit para */
struct de_fcm_commit_para {
	u32 enable;
	u32 demo_en;
};

/* fcm blob data */
struct de_fcm_para {
	struct de_fcm_commit_para commit;
	struct fcm_info pqd;
	u32 dirty;
};

/* --fcm api end -- */

struct de_cdc_para {
	/* cdc not support disable actually  */
	u32 enable;
};

struct de_csc_para {
	/* csc not support disable actually  */
	u32 enable;
};

/* -- gamma api -- */
/* gamma pqd ioctl para */
struct gamma_para {
	union {
		int id;
		/* enum pq_cmd */
		int cmd;
	};
	unsigned int size;
	u32 *lut;
};
/* gamma not need commit para, userspace can get/set gamma from libdrm directly */

/* -- gamma api end -- */

/* -- common PQ api -- */

enum pq_cmd {
	PQ_WRITE_AND_UPDATE = 0,
	PQ_WRITE_WITHOUT_UPDATE = 1,
	PQ_READ = 2,
};

/* ioctl args for pqd */
/* 0 enum sunxi_pq_type */
/* 1 hw_id */
/* 2 ptr: pqd_module para , beginning with int cmd */
/* 3 bytes of [2] */
struct ioctl_pq_data {
	unsigned long data[4];
};

enum sunxi_pq_type {
	PQ_SET_REG =		0x1,
	PQ_GET_REG =		0x2,
	PQ_ENABLE =		0x3,
	PQ_COLOR_MATRIX =	0x4,
	PQ_FCM =		0x5,
	PQ_CDC =		0x6,
	PQ_DCI =		0x7,
	PQ_DEBAND =		0x8,
	PQ_SHARP35X =		0x9,
	PQ_SNR =		0xa,
	PQ_GTM =		0xb,
	PQ_ASU =		0xc,
	PQ_GAMMA =		0xd,
};

enum pq_dirty_mask {
	FCM_DIRTY =	1 << PQ_FCM,
	DCI_DIRTY =	1 << PQ_DCI,
	SHARP_DIRTY =	1 << PQ_SHARP35X,
	SNR_DIRTY =	1 << PQ_SNR,
	ASU_DIRTY =	1 << PQ_ASU,
	DEBAND_DIRTY =	1 << PQ_DEBAND,
	PQ_ALL_DIRTY =	0xffffffff,
};

enum pq_dirty_type_mask {
	PQD_DIRTY_MASK =	1 << 0,
	COMMIT_DIRTY_MASK =	1 << 1,
};

struct de_frontend_data {
	struct de_snr_para snr_para;
	struct de_dci_para dci_para;
	struct de_fcm_para fcm_para;
	struct de_cdc_para cdc_para;
	struct de_csc_para csc1_para;
	struct de_csc_para csc2_para;
	struct de_sharp_para sharp_para;
	struct de_asu_para asu_para;
	/* enum pq_dirty_mask */
	u32 dirty;
};

struct de_dither_para {
	u32 enable;
	u32 dirty;
};

struct de_smbl_para {
	u32 enable;
	u32 dirty;
};

struct de_fmt_para {
	u32 enable;
	u32 dirty;
};

struct de_backend_data {
	struct de_dither_para dither_para;
	struct de_deband_para deband_para;
	struct de_smbl_para smbl_para;
	struct de_fmt_para fmt_para;
	/* enum pq_dirty_mask */
	u32 dirty;
};

/* -- common PQ api end -- */

#define DRM_SUNXI_PQ_PROC              0x00
#define DRM_IOCTL_SUNXI_PQ_PROC        DRM_IOWR(DRM_COMMAND_BASE + DRM_SUNXI_PQ_PROC, struct ioctl_pq_data)

#endif /*End of file*/
