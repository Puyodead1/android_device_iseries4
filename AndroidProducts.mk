#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/lineage_iseries4.mk \
    $(LOCAL_DIR)/twrp_iseries4.mk

COMMON_LUNCH_CHOICES := \
    lineage_iseries4-user \
    lineage_iseries4-userdebug \
    lineage_iseries4-eng \
    twrp_iseries4-eng \
    twrp_iseries4-userdebug
