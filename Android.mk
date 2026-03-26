#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),15in-I-Series-4)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
