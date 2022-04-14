
# Display CutOut
mount -o bind /mnt/phh/empty_dir /vendor/overlay/DisplayCutoutEmulationTall || true
mount -o bind /mnt/phh/empty_dir /vendor/overlay/DisplayCutoutEmulationDouble || true
mount -o bind /mnt/phh/empty_dir /vendor/overlay/DisplayCutoutEmulationCorner || true

# Drop btconfigstore and weaver from manifest
for f in \
    /vendor/etc/vintf/manifest.xml \
    /vendor/manifest.xml; do # For O if i ever wanted to try
    [ ! -f "$f" ] && continue
    if grep -q -E "vendor.qti.hardware.btconfigstore|android.hardware.weaver" "$f"; then
        # shellcheck disable=SC2010
        ctxt="$(ls -lZ "$f" | grep -oE 'u:object_r:[^:]*:s0')"
        b="$(echo "$f" | tr / _)"
        cp -a "$f" "/mnt/phh/$b"
        sed -i "s|vendor.qti.hardware.btconfigstore|vendor.qti.hardware.btconfigstore_disable|g" "/mnt/phh/$b"
        sed -i "s|android.hardware.weaver|android.hardware.weaver_disable|g" "/mnt/phh/$b"
        chcon "$ctxt" "/mnt/phh/$b"
        mount -o bind "/mnt/phh/$b" "$f"
    fi
done

# lib binds
mount -o bind /system/lib/vndk-"$vndk"/libgui.so /vendor/lib/libgui_vendor.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libgui.so /vendor/lib64/libgui_vendor.so || true
mount -o bind /system/lib/vndk-"$vndk"/libbinder.so /vendor/lib/libbinder.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libbinder.so /vendor/lib64/libbinder.so || true
mount -o bind /system/lib/vndk-"$vndk"/libbinder.so /vendor/lib/vndk/libbinder.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libbinder.so /vendor/lib64/vndk/libbinder.so || true
mount -o bind /system/lib/vndk-sp-"$vndk"/libcutils.so /vendor/lib/libcutils.so || true
mount -o bind /system/lib64/vndk-sp-"$vndk"/libcutils.so /vendor/lib64/libcutils.so || true
mount -o bind /system/lib/vndk-sp-"$vndk"/libcutils.so /vendor/lib/vndk-sp/libcutils.so || true
mount -o bind /system/lib64/vndk-sp-"$vndk"/libcutils.so /vendor/lib64/vndk-sp/libcutils.so || true
mount -o bind /system/lib/libpdx_default_transport.so /vendor/lib/libpdx_default_transport.so || true
mount -o bind /system/lib64/libpdx_default_transport.so /vendor/lib64/libpdx_default_transport.so || true
mount -o bind /system/lib/libpdx_default_transport.so /vendor/lib/vndk/libpdx_default_transport.so || true
mount -o bind /system/lib64/libpdx_default_transport.so /vendor/lib64/vndk/libpdx_default_transport.so || true

# Drop qcom stuffs for non qcom devices
if ! getprop ro.hardware | grep -qiE -e qcom -e mata;then
    mount -o bind /mnt/phh/empty_dir /system/app/imssettings || true
    mount -o bind /mnt/phh/empty_dir /system/priv-app/ims || true
    mount -o bind /mnt/phh/empty_dir /system/app/ims || true
    mount -o bind /mnt/phh/empty_dir /system/app/QtiTelephonyService || true
    mount -o bind /mnt/phh/empty_dir /system/app/datastatusnotification || true
fi

# Fix no Earpiece in audio_policy
for f in \
    /odm/etc/audio_policy_configuration.xml \
    /vendor/etc/audio_policy_configuration.xml; do
    [ ! -f "$f" ] && continue
    if ! grep -q "<item>Earpiece</item>" "$f"; then
        # shellcheck disable=SC2010
        ctxt="$(ls -lZ "$f" | grep -oE 'u:object_r:[^:]*:s0')"
        b="$(echo "$f" | tr / _)"
        cp -a "$f" "/mnt/phh/$b"
        sed -i "s|<attachedDevices>|<attachedDevices><item>Earpiece</item>|g" "/mnt/phh/$b"
        chcon "$ctxt" "/mnt/phh/$b"
        mount -o bind "/mnt/phh/$b" "$f"
    fi
done

frp_node="$(getprop ro.frp.pst)"
chown -h system.system $frp_node
chmod 0660 $frp_node

# Fix miui device model
manufacturer=$(getprop ro.product.system.manufacturer)
[ -z "$manufacturer" ] && manufacturer=$(getprop ro.product.odm.manufacturer)
 model=$(getprop ro.product.system.model)
[ -z "$model" ] && model=$(getprop ro.product.odm.model)
brand=$(getprop ro.product.system.brand)
[ -z "$brand" ] && model=$(getprop ro.product.odm.brand)
device=$(getprop ro.product.system.device)
[ -z "$device" ] && model=$(getprop ro.product.odm.device)
name=$(getprop ro.product.system.name)
[ -z "$name" ] && model=$(getprop ro.product.odm.name)
marketname=$(getprop ro.product.system.marketname)
[ -z "$marketname" ] && model=$(getprop ro.product.odm.marketname)
resetprop ro.product.odm.manufacturer "$manufacturer"
resetprop ro.product.odm.brand "$brand"
resetprop ro.product.odm.model "$model"
resetprop ro.product.odm.name "$name"
resetprop ro.product.odm.device "$device"
resetprop ro.product.system.manufacturer "$manufacturer"
resetprop ro.product.system.brand "$brand"
resetprop ro.product.system.model "$model"
resetprop ro.product.system.name "$name"
resetprop ro.product.system.device "$device"
resetprop ro.product.system.marketname "$marketname"
