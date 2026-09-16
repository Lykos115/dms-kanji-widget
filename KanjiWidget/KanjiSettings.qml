import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "kanjiWidget"

    StyledText {
        width: parent.width
        text: "Content"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    SelectionSetting {
        settingKey: "levels"
        label: "JLPT levels"
        options: [
            { label: "N5 (80 kanji)", value: "5" },
            { label: "N5 + N4", value: "5,4" },
            { label: "N5 – N3", value: "5,4,3" },
            { label: "N5 – N2", value: "5,4,3,2" },
            { label: "All (N5 – N1)", value: "5,4,3,2,1" },
            { label: "N4 only", value: "4" },
            { label: "N3 only", value: "3" },
            { label: "N2 only", value: "2" },
            { label: "N1 only", value: "1" }
        ]
        defaultValue: "5"
    }

    SliderSetting {
        settingKey: "interval"
        label: "Seconds per kanji"
        defaultValue: 30
        minimum: 5
        maximum: 600
        unit: "s"
    }

    ToggleSetting {
        settingKey: "shuffle"
        label: "Random order"
        description: "Off = go through the level from the simplest kanji (fewest strokes) to the most complex"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "syncInstances"
        label: "Same kanji everywhere"
        description: "Keep the bar pills on every monitor and the desktop widgets in step"
        defaultValue: true
    }

    StringSetting {
        settingKey: "fontFamily"
        label: "Japanese font"
        description: "Leave empty to use the DMS font (fontconfig falls back to Noto Sans CJK for Japanese)"
        placeholder: "Noto Sans CJK JP"
        defaultValue: ""
    }

    StyledText {
        width: parent.width
        text: "Audio"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "autoPlay"
        label: "Read the readings automatically"
        description: "Speak every new kanji as it appears (only the instance that picked it speaks)"
        defaultValue: false
    }

    SelectionSetting {
        settingKey: "audioSource"
        label: "Audio source"
        options: [
            { label: "Local text-to-speech (all on/kun readings)", value: "tts" },
            { label: "JapanesePod101 online clip (first reading only)", value: "online" }
        ]
        defaultValue: "tts"
    }

    StringSetting {
        settingKey: "ttsCommand"
        label: "Text-to-speech command"
        description: "{text} is replaced by the readings. espeak-ng: pacman -S espeak-ng. Natural voice: say-ja {text} with Piper, see README"
        placeholder: "espeak-ng -v ja -s 130 {text}"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "playerCommand"
        label: "Player command (online clips)"
        description: "{file} is replaced by the URL. Needs mpv (or ffplay -nodisp -autoexit {file})"
        placeholder: "mpv --no-video --really-quiet {file}"
        defaultValue: ""
    }

    StyledText {
        width: parent.width
        text: "Bar pill & popout"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    SelectionSetting {
        settingKey: "barStyle"
        label: "Pill text"
        options: [
            { label: "Kanji only", value: "kanji" },
            { label: "Kanji + readings", value: "kanji+reading" },
            { label: "Kanji + meaning", value: "kanji+meaning" }
        ]
        defaultValue: "kanji+reading"
    }

    SliderSetting {
        settingKey: "barMaxChars"
        label: "Max text length in pill"
        defaultValue: 28
        minimum: 10
        maximum: 80
        unit: "chars"
    }

    SliderSetting {
        settingKey: "popoutWidth"
        label: "Popout width"
        defaultValue: 340
        minimum: 240
        maximum: 600
        unit: "px"
    }

    SliderSetting {
        settingKey: "popoutMainSize"
        label: "Popout kanji size"
        defaultValue: 96
        minimum: 32
        maximum: 200
        unit: "px"
    }

    StyledText {
        width: parent.width
        text: "Desktop widget"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    SliderSetting {
        settingKey: "desktopMainSize"
        label: "Kanji size"
        defaultValue: 64
        minimum: 16
        maximum: 200
        unit: "px"
    }

    ToggleSetting { settingKey: "showReading"; label: "Show readings"; defaultValue: true }
    ToggleSetting { settingKey: "showMeaning"; label: "Show meaning"; defaultValue: true }
    ToggleSetting { settingKey: "showLevel"; label: "Show level and stroke count"; defaultValue: true }
    ToggleSetting {
        settingKey: "desktopTextShadow"
        label: "Text outline"
        description: "Keeps text readable on light wallpapers"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "desktopBackgroundOpacity"
        label: "Background opacity"
        description: "0 = fully transparent, text straight on the wallpaper"
        defaultValue: 0
        minimum: 0
        maximum: 100
        unit: "%"
    }
}
