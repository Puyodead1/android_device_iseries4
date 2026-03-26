#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from 15in-I-Series-4 device
$(call inherit-product, device/elo/15in-I-Series-4/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_DEVICE := 15in-I-Series-4
PRODUCT_NAME := lineage_15in-I-Series-4
PRODUCT_BRAND := Elo
PRODUCT_MODEL := 15in-I-Series-4
PRODUCT_MANUFACTURER := elo

PRODUCT_GMS_CLIENTID_BASE := android-elotouch

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="15in-I-Series-4_E8MP-user 14 UKQ1.241008.001 7.000.005.0020+p release-keys" \
    BuildFingerprint=Elo/15in-I-Series-4_E8MP/15in-I-Series-4:14/UKQ1.241008.001/7.000.005.0020+p:user/release-keys
