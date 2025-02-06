/* SPDX-License-Identifier: GPL-2.0 */
/* Copyright(c) 2020 - 2023 Allwinner Technology Co.,Ltd. All rights reserved. */
/*
 * Allwinner's log functions
 *
 * Copyright (c) 2023, lvda <lvda@allwinnertech.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 */

#ifndef __SUNXI_LOG_H__
#define __SUNXI_LOG_H__

#define SUNXI_LOG_VERSION	"V0.7"
/* Allow user to define their own MODNAME with `SUNXI_MODNAME` */
#ifndef SUNXI_MODNAME
#define SUNXI_MODNAME		KBUILD_MODNAME
#endif

#ifdef pr_fmt
#undef pr_fmt
#endif

#ifdef dev_fmt
#undef dev_fmt
#endif

#define pr_fmt(fmt)		"sunxi:" SUNXI_MODNAME fmt
#define dev_fmt			pr_fmt

#include <linux/kernel.h>
#include <linux/device.h>

/*
 * Copy from dev_name(). Someone like to use "dev_name" as local variable,
 * which will case compile error.
 */
static inline const char *sunxi_log_dev_name(const struct device *dev)
{
	/* Use the init name until the kobject becomes available */
	if (dev->init_name)
		return dev->init_name;

	return kobject_name(&dev->kobj);
}

/*
 * Parameter Description:
 * 1. dev: Optional parameter. If the context cannot obtain dev, fill in NULL
 * 2. fmt: Format specifier
 * 3. err_code: Error code. Only used in sunxi_err_std()
 * 4. ...: Variable arguments
 */

#if IS_ENABLED(CONFIG_AW_LOG_VERBOSE)

/* void sunxi_err(struct device *dev, char *fmt, ...); */
#define sunxi_err(dev, fmt, ...)											\
	do { if (dev)													\
		pr_err("-%s:[ERR]:%s +%d %s(): "fmt, sunxi_log_dev_name(dev), __FILE__, __LINE__, __func__, ## __VA_ARGS__);	\
	     else													\
		pr_err(":[ERR]:%s +%d %s(): "fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__);				\
	} while (0)

/* void sunxi_err_std(struct device *dev, int err_code, char *fmt, ...); */
#define sunxi_err_std(dev, err_code, fmt, ...)											\
	do { if (dev)														\
		pr_err("-%s:[ERR%d]:%s +%d %s(): "fmt, sunxi_log_dev_name(dev), err_code, __FILE__, __LINE__, __func__, ## __VA_ARGS__);	\
	     else														\
		pr_err(":[ERR%d]:%s +%d %s(): "fmt, err_code, __FILE__, __LINE__, __func__, ## __VA_ARGS__);			\
	} while (0)

/* void sunxi_warn(struct device *dev, char *fmt, ...); */
#define sunxi_warn(dev, fmt, ...)											\
	do { if (dev)													\
		pr_warn("-%s:[WARN]:%s +%d %s(): "fmt, sunxi_log_dev_name(dev), __FILE__, __LINE__, __func__, ## __VA_ARGS__);	\
	     else													\
		pr_warn(":[WARN]:%s +%d %s(): "fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__);			\
	} while (0)

/* void sunxi_info(struct device *dev, char *fmt, ...); */
#define sunxi_info(dev, fmt, ...)											\
	do { if (dev)													\
		pr_info("-%s:[INFO]:%s +%d %s(): "fmt, sunxi_log_dev_name(dev), __FILE__, __LINE__, __func__, ## __VA_ARGS__);	\
	     else													\
		pr_info(":[INFO]:%s +%d %s(): "fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__);			\
	} while (0)

/* void sunxi_debug(struct device *dev, char *fmt, ...); */
#define sunxi_debug(dev, fmt, ...)											\
	do { if (dev)													\
		pr_debug("-%s:[DEBUG]:%s +%d %s(): "fmt, sunxi_log_dev_name(dev), __FILE__, __LINE__, __func__, ## __VA_ARGS__);	\
	     else													\
		pr_debug(":[DEBUG]:%s +%d %s(): "fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__);			\
	} while (0)

#else  /* !CONFIG_AW_LOG_VERBOSE */

/* void sunxi_err(struct device *dev, char *fmt, ...); */
#define sunxi_err(dev, fmt, ...)							\
	do { if (dev)									\
		pr_err("-%s:[ERR]: "fmt, sunxi_log_dev_name(dev), ## __VA_ARGS__);			\
	     else									\
		pr_err(":[ERR]: "fmt, ## __VA_ARGS__);					\
	} while (0)

/* void sunxi_err_std(struct device *dev, int err_code, char *fmt, ...); */
#define sunxi_err_std(dev, err_code, fmt, ...)						\
	do { if (dev)									\
		pr_err("-%s:[ERR%d]: "fmt, sunxi_log_dev_name(dev), err_code, ## __VA_ARGS__);	\
	     else									\
		pr_err(":[ERR%d]: "fmt, err_code, ## __VA_ARGS__);			\
	} while (0)

/* void sunxi_warn(struct device *dev, char *fmt, ...); */
#define sunxi_warn(dev, fmt, ...)							\
	do { if (dev)									\
		pr_warn("-%s:[WARN]: "fmt, sunxi_log_dev_name(dev), ## __VA_ARGS__);		\
	     else									\
		pr_warn(":[WARN]: "fmt, ## __VA_ARGS__);					\
	} while (0)

/* void sunxi_info(struct device *dev, char *fmt, ...); */
#define sunxi_info(dev, fmt, ...)						\
	do { if (dev)								\
		pr_info("-%s:[INFO]: "fmt, sunxi_log_dev_name(dev), ## __VA_ARGS__);	\
	     else								\
		pr_info(":[INFO]: "fmt, ## __VA_ARGS__);				\
	} while (0)

/* void sunxi_debug(struct device *dev, char *fmt, ...); */
#define sunxi_debug(dev, fmt, ...)						\
	do { if (dev)								\
		pr_debug("-%s:[DEBUG]: "fmt, sunxi_log_dev_name(dev), ## __VA_ARGS__);	\
	     else								\
		pr_debug(":[DEBUG]: "fmt, ## __VA_ARGS__);			\
	} while (0)

#endif  /* CONFIG_AW_LOG_VERBOSE */

/* void sunxi_debug_verbose(struct device *dev, char *fmt, ...); */
#define sunxi_debug_verbose(dev, fmt, ...)										\
	do { if (dev)													\
		pr_debug("-%s:[DEBUG]:%s +%d %s(): "fmt, sunxi_log_dev_name(dev), __FILE__, __LINE__, __func__, ## __VA_ARGS__);	\
	     else													\
		pr_debug(":[DEBUG]:%s +%d %s(): "fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__);			\
	} while (0)

/* void sunxi_debug_line(struct device *dev); */
#define sunxi_debug_line(dev)											\
	do { if (dev)												\
		pr_debug("-%s:[DEBUG]:%s +%d %s()\n", sunxi_log_dev_name(dev), __FILE__, __LINE__, __func__);		\
	     else												\
		pr_debug(":[DEBUG]:%s +%d %s()\n", __FILE__, __LINE__, __func__);				\
	} while (0)

/*
 * TODO:
 * print_hex_dump_debug
 * print_hex_dump_bytes
 * trace_printk
 * printk_ratelimited
*/

#include "errcode/sunxi-err.h"

#endif
