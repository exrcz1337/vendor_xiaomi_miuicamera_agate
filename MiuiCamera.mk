#
# Copyright (C) 2024-2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from the proprietary version
MIUICAMERA_PATH := vendor/xiaomi/miuicamera

$(call inherit-product, vendor/xiaomi/miuicamera/common/common-vendor.mk)

# Dex
PRODUCT_DEXPREOPT_SPEED_APPS += \
    MiuiCamera

# Priv-app permission
PRODUCT_COPY_FILES += \
    $(MIUICAMERA_PATH)/configs/privapp-permissions-miui.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-miui.xml

# Shims
PRODUCT_PACKAGES += \
    libgui_shim_miuicamera \
    libutilscallstack_vendor

# Sysconfig
PRODUCT_COPY_FILES += \
    $(MIUICAMERA_PATH)/configs/miuicamera-hiddenapi-package-allowlist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/miuicamera-hiddenapi-package-allowlist.xml

PRODUCT_COPY_FILES += \
    $(MIUICAMERA_PATH)/configs/camera/superlowlightsnapshot.json:$(TARGET_COPY_OUT_VENDOR)/etc/camera/xiaomi/superlowlightsnapshot.json \
    $(MIUICAMERA_PATH)/configs/camera/satsnapshot.json:$(TARGET_COPY_OUT_VENDOR)/etc/camera/xiaomi/satsnapshot.json
