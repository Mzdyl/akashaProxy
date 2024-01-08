#!/system/bin/sh
SKIPUNZIP=1

if [ ! $KSU ];then
    ui_print "- Magisk ver: $MAGISK_VER"
    
    ui_print "- Magisk version: $MAGISK_VER_CODE"
    if [ "$MAGISK_VER_CODE" -lt 26301 ]; then
        ui_print "*********************************************************"
        ui_print "! Please use Magisk alpha 26301+"
        abort "*********************************************************"
    fi
elif [ $KSU ];then
    ui_print "- KernelSU version: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
    if ! [ "$KSU_KERNEL_VER_CODE" ] || [ "$KSU_KERNEL_VER_CODE" -lt 11413 ]; then
        ui_print "*********************************************************"
        ui_print "! KernelSU version is too old!"
        ui_print "! Please update KernelSU to latest version"
        abort "*********************************************************"
    fi
else
    ui_print "unknown root manager"
    ui_print "$(set)"
    abort
fi
status=""
architecture=""
system_gid="1000"
system_uid="1000"
clash_data_dir="/data/clash"
modules_dir="/data/adb/modules"
config="true" #更新是否替换clash.config
ABI=$(getprop ro.product.cpu.abi)
mkdir -p ${clash_data_dir}/run
mkdir -p ${clash_data_dir}/clashkernel

if [ ! -f ${clash_data_dir}/clashkernel/clashMeta ];then
    if [ -f "${MODPATH}/bin/clashMeta-android-${ABI}.tar.bz2" ];then
        tar -xjf ${MODPATH}/bin/clashMeta-android-${ABI}.tar.bz2 -C ${clash_data_dir}/clashkernel/
        mv -f ${clash_data_dir}/clashkernel/clashMeta-android-${ABI} ${clash_data_dir}/clashkernel/clashMeta
    else
        if [ -f "${MODPATH}/bin/clashMeta-android-default.tar.bz2" ];then
            tar -xjf ${MODPATH}/bin/clashMeta-android-${ABI}.tar.bz2 -C ${clash_data_dir}/clashkernel/
            mv -f ${clash_data_dir}/clashkernel/clashMeta-android-${ABI} ${clash_data_dir}/clashkernel/clashMeta
        else
            ui_print "Your architecture was not found: ${ABI}\nPlease use 'make default' to compile clashMeta for ${ABI} architecture"
            abort 1
        fi
    fi
fi

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d ${MODPATH} >&2

if [ -f "${clash_data_dir}/config.yaml" ];then
    ui_print "-config.yaml The file already exists. Do not add the default file."
    rm -rf ${MODPATH}/config.yaml
else
    ui_print "-config.yaml The file not exists. Do add the default file."
fi

if [ -f "${clash_data_dir}/clash.yaml" ];then
    ui_print "-clash.yaml The file already exists. Do not add the default file."
    rm -rf ${MODPATH}/clash.yaml
else
    ui_print "-clash.yaml The file not exists. Do add the default file."
fi

if [ -f "${clash_data_dir}/packages.list" ];then
    if [ "${config}" == "false" ];then
        ui_print "-packages.list The file already exists. Do not add the default file."
        rm -rf ${MODPATH}/packages.list
    fi
else
    ui_print "-packages.list The file not exists. Do add the default file."
fi

mv -f ${MODPATH}/clash/* ${clash_data_dir}/
rm -rf ${MODPATH}/clashkernel

ui_print "- Start setting permissions."
set_perm_recursive ${MODPATH} 0 0 0755 0755
set_perm_recursive ${clash_data_dir} ${system_uid} ${system_gid} 0755 0644
set_perm_recursive ${clash_data_dir}/scripts ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/clashkernel ${system_uid} ${system_gid} 6755 6755
set_perm  ${clash_data_dir}/clashkernel/clash  ${system_uid}  ${system_gid}  6755
set_perm  ${clash_data_dir}/clash.config ${system_uid} ${system_gid} 0755
set_perm  ${clash_data_dir}/packages.list ${system_uid} ${system_gid} 0644


ui_print ""
ui_print ""
ui_print "************************************************"
ui_print "## Module path:
**Work path: /data/clash/
```
├── adguard
│   ├── // AdGuardHome module
├── clash.config (clash start config)
├── clash.yaml (clash config#1)
├── clashkernel
│   ├── clashMeta //clash
├── config.yaml (clash config#2)
├── packages.list (black/white list packages list)
├── mosdns
│   ├── // mosdns module
├── scripts // clash start script
│   ├── clash.inotify
│   ├── clash.iptables
│   ├── clash.service
│   └── clash.tool 
├── yacd
│   ├── //yacd-Meta
└── DeleteCache.sh
```"
ui_print "telegram channel: @wtdnwbzda"
