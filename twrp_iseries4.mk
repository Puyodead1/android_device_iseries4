#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_RELEASE_NAME := iseries4

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from iseries4 device
$(call inherit-product, device/elo/iseries4/device.mk)

PRODUCT_DEVICE := iseries4
PRODUCT_NAME := twrp_iseries4
PRODUCT_BRAND := Elo
PRODUCT_MODEL := 15in-I-Series-4
PRODUCT_MANUFACTURER := Elo Touch Solutions

PRODUCT_GMS_CLIENTID_BASE := android-elotouch

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="15in-I-Series-4_E8MP-user 14 UKQ1.241008.001 7.000.005.0020+p release-keys" \
    BuildFingerprint=Elo/15in-I-Series-4_E8MP/15in-I-Series-4:14/UKQ1.241008.001/7.000.005.0020+p:user/release-keys
