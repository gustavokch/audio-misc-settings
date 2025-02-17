#!/system/bin/sh

. "$MODPATH/customize-functions.sh"

REPLACE=""

# making patched ALSA utility and Tensor's offload libraries for "ro.audio.usb.period_us"
makeLibraries
# removing post-A13 (especially Tensor's) spatial audio flags in an audio configuration file for avoiding errors
deSpatializeAudioPolicyConfig "/vendor/etc/bluetooth_audio_policy_configuration_7_0.xml"
# disabling pre-installed Moto Dolby faetures for reducing very large jitter caused by them
disableMotoDolby

if "$IS64BIT"; then
    board="`getprop ro.board.platform`"
    case "$board" in
        "kona" | "kalama" | "shima" | "yupik" )
            replaceSystemProps_Kona
            ;;
        "sdm845" | gs* )
            replaceSystemProps_SDM845
            ;;
        "sdm660" | "bengal" | "holi" )
            replaceSystemProps_SDM
            ;;
        mt68* )
            replaceSystemProps_MTK_Dimensity
            ;;
        mt67[56]? )
            replaceSystemProps_Others
            ;;
        * )
            replaceSystemProps_Others
            ;;
    esac

else
    if [ "`getprop ro.build.product`" = "jfltexx" ]; then
        replaceSystemProps_S4
    else
        replaceSystemProps_Old
    fi

fi

# AudioFlinger's resampler has a bug on an Android OS of which version is less than 12.
# This bug makes the resampler to distort audible audio output by wrong aliasing processing
#   when specifying a transition band around or higher than the Nyquist frequency

if [ "`getprop ro.system.build.version.release`" -lt "12"  -a  "`getprop ro.system.build.date.utc`" -lt "1648632000" ]; then
    mv -f "$MODPATH/system.prop-workaround" "$MODPATH/system.prop"
else
    rm -f "$MODPATH/system.prop-workaround"
fi

rm -f "$MODPATH/customize-functions.sh"
