import QtQuick
import qs.Common
import qs.Modules.Plugins

// Desktop widget: DMS draws it on the bottom layer (above the wallpaper,
// below windows) and remembers position and size. Move/resize it from
// Settings → Desktop Widgets (right-click drag). Left click = next kanji,
// middle click = speak the readings.
DesktopPluginComponent {
    id: root

    minWidth: 120
    minHeight: 100

    readonly property real mainSize: pluginData.desktopMainSize ?? 64
    readonly property real backgroundOpacity: (pluginData.desktopBackgroundOpacity ?? 0) / 100
    readonly property bool showReading: pluginData.showReading ?? true
    readonly property bool showMeaning: pluginData.showMeaning ?? true
    readonly property bool showLevel: pluginData.showLevel ?? true
    readonly property string fontFamily: (pluginData.fontFamily ?? "") !== "" ? pluginData.fontFamily : Theme.fontFamily
    readonly property bool textShadow: pluginData.desktopTextShadow ?? true

    KanjiDeck {
        id: deck
        settings: root.pluginData
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        opacity: root.backgroundOpacity
    }

    Column {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: 2

        Text {
            width: parent.width
            text: deck.main
            font.family: root.fontFamily
            font.pixelSize: root.mainSize
            font.weight: Font.Bold
            color: Theme.surfaceText
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showReading && deck.on !== ""
            width: parent.width
            text: deck.on
            font.family: root.fontFamily
            font.pixelSize: Math.max(Theme.fontSizeSmall, root.mainSize * 0.3)
            color: Theme.primary
            wrapMode: Text.WordWrap
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showReading && deck.kun !== ""
            width: parent.width
            text: deck.kun
            font.family: root.fontFamily
            font.pixelSize: Math.max(Theme.fontSizeSmall, root.mainSize * 0.3)
            color: Theme.secondary
            wrapMode: Text.WordWrap
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showMeaning && deck.meaning !== ""
            width: parent.width
            text: deck.meaning
            font.pixelSize: Math.max(Theme.fontSizeSmall, root.mainSize * 0.25)
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showLevel && deck.tag !== ""
            width: parent.width
            text: deck.tag + (deck.strokes > 0 ? " · " + deck.strokes + " strokes" : "")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            opacity: 0.8
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton   // right button stays with the DMS drag/resize handler
        onClicked: mouse => mouse.button === Qt.MiddleButton ? deck.play() : deck.next(true)
    }
}
