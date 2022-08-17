#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR

systemdir=$1

#oem bloatwares

rm -rf $1/reserve/*
rm -rf $1/preload/*
rm -rf $1/preset_apps/*
rm -rf $1/data-app/*
rm -rf $1/*/preload/*
rm -rf $1/*/preset_apps/*
rm -rf $1/*/data-app/*

rm -rf $1/*app/*FM*
rm -rf $1/*app/*account*

# Gapps
app_list="BasicDreams PlayAuto SpeechServices PhotoTable EmergenyInfo Google*Lens WfdService Game TouchAssistant Health MusicPlayerGO AEXPapers Superiorwalls Recorder Compass Warranty Map acebook YouTube Velvet PixelWall Micropaper Ornament DevicePersonalization Duo Pay pay Market Dreamliner Videos Gmail Browser Photos Keep Tips DevicePolicy arcore ARCORE AndroidAuto Verizon LiveWallpaper Scribe Calendar Chrome Drive GoogleOne GoogleAssist Bugle Tycho talkback Maestro UserCent OTA ppstore Diagnostics NgaResources BetaFeedback HelpRtcPrebuilt SafetyHub Sprint DCMO ConnMO GoogleCamera Wallpaper Euicc TTS"

for app in $app_list; do
rm -rf $1/*app/*$app*
rm -rf $1/*/*app/*$app*
done

# Pixel
rm -rf $1/system-ext/app/datastatusnotification
rm -rf $1/app/QAS_DVC_MSP_VZW
rm -rf $1/app/VZWAPNLib
rm -rf $1/app/vzw_msdc_api
rm -rf $1/priv-app/CNEService
rm -rf $1/priv-app/DMService
rm -rf $1/priv-app/VzwOmaTrigger
rm -rf $1/priv-app/qcrilmsgtunnel
rm -rf $1/product_services/priv-app/PrebuiltGmsCorePi/app_chimera
rm -rf $1/product/priv-app/PrebuiltGmsCoreQt/app_chimera
rm -rf $1/product/priv-app/PrebuiltGmsCore/app_chimera
rm -rf $1/etc/permissions/com.google.android.camera.experimental2017.xml

# Fix Files-DocumentsUI
rm -rf $1/product/overlay/PixelDocumentsUIOverlay

# Some Unused Google Apps
rm -rf $1/system_ext/priv-app/HbmSVManager
rm -rf $1/system_ext/priv-app/OBDM_Permissions
rm -rf $1/system_ext/priv-app/obdm_stub
