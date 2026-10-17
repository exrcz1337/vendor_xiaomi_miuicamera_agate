# MiuiCamera for Xiaomi 11T (agate / MT6893)

Highly modified port of [c0smic-Lab/vendor_xiaomi_miuicamera](https://github.com/c0smic-Lab/vendor_xiaomi_miuicamera)
originally made for Miatoll. This tree carries the **Xiaomi 11T (agate)** camera
stack extracted from stock **HyperOS OS1.0.17.0.UKWMIXM** (Android 14) so every
stock camera feature works (108MP, OIS/EIS, 1080p60, 4K30, portrait, night, etc.).

## Important

agate's `MiuiCamera.apk` and `ExtraPhotoGlobal.apk` ship **most of their native
libraries inside the APK** (`lib/arm64-v8a/`). Unlike the Miatoll tree, this port
therefore only needs a small set of external blobs:

| Blob | Partition |
|------|-----------|
| `MiuiCamera.apk` | `/product/priv-app` |
| `ExtraPhotoGlobal.apk` | `/product/priv-app` |
| `libcamera_algoup_jni.xiaomi.so` | `/system_ext/lib64` |
| `libcamera_mianode_jni.xiaomi.so` | `/system_ext/lib64` |
| `libcamera_ispinterface_jni.xiaomi.so` | `/system_ext/lib64` |
| `libopencl-camera.so` | `/system_ext/lib64` |
| `libmisys_jni.xiaomi.so` + `vendor.xiaomi.hardware.misys@*.so` | `/system/lib64` |
| `vendor.xiaomi.hardware.misys@[1-4].0` HAL (services/impls/rc/vintf) | `/vendor` |

The three camera JNI libraries are patched to link against
`libgui_shim_miuicamera.so`, which provides
`android::BnProducerListener::onBufferDetached(int)` — a symbol that AOSP's
`libgui` no longer exports (same reason the Miatoll tree needed it).

APKs are stored split (`*.apk.partNN`) because GitHub rejects files >100 MB.
`vendorsetup.sh` merges them back during `envsetup.sh`.

## Integration

Clone to `vendor/xiaomi/miuicamera`:

- In `device.mk`:
```
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera/MiuiCamera.mk)
```
- In `BoardConfig.mk`:
```
-include vendor/xiaomi/miuicamera/BoardConfigMiuiCamera.mk
```
- In the device FCM (`device/manifest.xml`):
```
<hal format="hidl" optional="true">
    <name>vendor.xiaomi.hardware.misys</name>
    <version>1.0</version>
    <version>2.0</version>
    <version>3.0</version>
    <version>4.0</version>
    <interface>
        <name>IMiSys</name>
        <instance>default</instance>
    </interface>
</hal>
```

## Notes / requirements

- The APK is **re-signed with the platform certificate** at build time
  (`certificate: "platform"`). If your ROM ships a mismatched
  `com.android.camera` (e.g. another MiuiCamera), remove it.
- `ro.miui.build.region` is set to `global` in `system.prop`. Change it to
  `cn`/`in` if you prefer a different MIUI feature set.
- `ExtraPhotoGlobal` is optional. Delete its `android_app_import` from
  `common/Android.bp`, the `PRODUCT_PACKAGES` entry and the APK folder if you
  don't want the gallery photo editor.
- The MTK camera HAL (`camera.mt6893`, `libmtkcam*`), camera tuning data
  (`vendor/etc/camera/*`) and the APU/arcsoft algorithm libraries must come
  from your `vendor/xiaomi/agate` tree — they are **not** part of this repo.
- If you need the MiSys HIDL *Java* frontend for other MIUI apps, add
  `vendor.xiaomi.hardware.misys-V{1,2,4}.0-java.jar`, `vendor.xiaomi.hardware.misys.V3_0.jar`
  and `vendor.xiaomi.hardware.misys.common-V1-java.jar` (from `/system/framework`,
  `/system_ext/framework`) plus their permission XMLs. `MiuiCamera` itself does
  not need them — it talks to MiSys through `libmisys_jni.xiaomi.so`.
