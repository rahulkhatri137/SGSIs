LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
systemdir=$1

rm -rf $1/../res/images/*
rm -rf $1/*/*app/*Recorder*
rm -rf $1/*app/*Recorder*
rm -rf $1/*app/Compass
rm -rf $1/*app/*Warranty*
rm -rf $1/*/*app/*Map*
rm -rf $1/*app/*Map*
rm -rf $1/*/*app/*acebook*
rm -rf $1/*app/*acebook*
rm -rf $1/*/preset_apps/*
rm -rf $1/*/data-app/*
rm -rf $1/preload/*
rm -rf $1/*/preload/*
rm -rf $1/preset_apps/*
rm -rf $1/data-app/*
rm -rf $1/*/*app/*FM*
rm -rf $1/*app/*FM*
rm -rf $1/*/*app/*Browser*
rm -rf $1/*app/*Browser*
rm -rf $1/*app/*UserCent*
rm -rf $1/fonts/D*
rm -rf $1/fonts/Source*
rm -rf $1/fonts/NotoSans*
rm -rf $1/fonts/NotoSerif*
rm -rf $1/*app/*account*
rm -rf $1/*/*app/*OTA*
rm -rf $1/*app/*OTA*
rm -rf $1/*app/*ppstore*
rm -rf $1/*/*app/*ppstore*
rm -rf $1/*app/*Game*

rm -rf $1/app/HarassIntercept*
rm -rf $1/app/Jobdispatcer*
rm -rf $1/app/LeagueShare*
rm -rf $1/app/NB*
rm -rf $1/app/NubiaAfterSale*
rm -rf $1/app/NubiaFan
rm -rf $1/app/NubiaPush*
rm -rf $1/app/NubiaG*
rm -rf $1/app/NubiaShare*
rm -rf $1/app/*_nubia*
rm -rf $1/app/Woodpecker*
rm -rf $1/*app/*LiveWallpaper*
rm -rf $1/*app/*eibo*
rm -rf $1/app/ZDoubleApp*
rm -rf $1/app/*DynamicWallpaper*
rm -rf $1/app/*Game*
rm -rf $1/app/*NBSecurity*
rm -rf $1/app/nubia_NeoQuick*
rm -rf $1/*app/*account*
rm -rf $1/app/redtea*
rm -rf $1/fonts/NotoSans*
rm -rf $1/fonts/NotoSerif*
rm -rf $1/media/*/*nubia*
rm -rf $1/media/wallpaper/1920*
rm -rf $1/media/wallpaper/middle*
rm -rf $1/*app/*Game*
rm -rf $1/*app/*Emergency*
rm -rf $1/*app/*Tencent*
rm -rf $1/*/*app/*Tencent*
rm -rf $1/priv-app/ZNubia*
rm -rf $1/priv-app/*Theme*
rm -rf $1/*/*app/*Appstore*
rm -rf $1/*/*app/*Usercenter*
rm -rf $1/*/media/*theme*/*/*colorful*
rm -rf $1/*/media/*theme*/*/*tech*
rm -rf $1/*/media/*theme*/*/*pubg*
rm -rf $1/*/media/*theme*/*/*machao*
rm -rf $1/*/media/*theme*/*/*wzry*
rm -rf $1/product/media/audio/alarms/*
rm -rf $1/product/media/audio/notifications/*
rm -rf $1/product/media/audio/ringtones/*



# Drop useless apks
rm -rf $1/app/AutoAgingTest
rm -rf $1/app/DTSXULTRA
rm -rf $1/app/FactoryTestAdvanced
rm -rf $1/app/GoodixTest
rm -rf $1/app/NBVirtualGameHandle
rm -rf $1/app/NubiaFastPair
rm -rf $1/app/Stk
rm -rf $1/app/SystemUpdate_v1.1
rm -rf $1/app/TP_YulorePage_v1.0.0
rm -rf $1/app/ZNubiaEdge
rm -rf $1/app/nubia_Browser
rm -rf $1/app/nubia_Calendar_v1.0
rm -rf $1/app/nubia_DeskClock_NX*
rm -rf $1/app/nubia_DynamicWallpaper_651
rm -rf $1/app/nubia_GameHelperModule
rm -rf $1/app/nubia_GameHighlights
rm -rf $1/app/nubia_GameLauncher
rm -rf $1/app/nubia_NeoHybrid
rm -rf $1/app/nubia_PhoneManualIntegrate
rm -rf $1/app/nubia_neoPay
rm -rf $1/priv-app/AOD_v*.*_*-release
rm -rf $1/priv-app/Camera
rm -rf $1/priv-app/NBGalleryLockScreen
rm -rf $1/priv-app/NubiaGallery
rm -rf $1/priv-app/NubiaVideo
rm -rf $1/priv-app/PhotoEditor
rm -rf $1/priv-app/ZQuickSearchBox
rm -rf $1/priv-app/nubia_HaloVoice
rm -rf $1/priv-app/nubia_touping
rm -rf $1/product/data-app/*
rm -rf $1/product/app/TrichromeLibrary
rm -rf $1/product/media/audio/alarms/*
rm -rf $1/product/media/audio/notifications/*
rm -rf $1/product/media/audio/ringtones/*
# Since we've dropped AOD, time to drop AOD themes
rm -rf $1/system_ext/media/Settings/aod

# Drop some themes to save space
rm -rf $1/system_ext/media/theme/thememanager/default_king_of_glory
rm -rf $1/system_ext/media/theme/thememanager/default_white_mech
rm -rf $1/product/priv-app/ConfigUpdater
rm -rf $1/product/priv-app/GooglePlayServicesUpdater

# Drop QCC (Always crashing)
rm -rf $1/system_ext/app/QCC/
