import QtQuick
import qs.Common
import qs.Services
import qs.Modules.Plugins

// Desktop widget: DMS draws it on the bottom layer (above the wallpaper,
// below windows) and remembers position and size. Move/resize it from
// Settings → Desktop Widgets (right-click drag). Left click = next sentence,
// middle click = play it.
DesktopPluginComponent {
    id: root

    minWidth: 160
    minHeight: 80

    // DMS gives a desktop widget *instance* only its own per-instance config as
    // pluginData (what you set under Settings → Desktop Widgets → this widget).
    // The plugin-wide settings (Settings → Plugins → Jlab sentences) never reach
    // it, so merge them in: instance keys win, the plugin-wide ones fill the rest.
    property var globalData: ({})
    readonly property var cfg: Object.assign({}, globalData, pluginData ?? {})

    function reloadGlobal() {
        const id = pluginId !== "" ? pluginId : "jlabWidget";
        globalData = SettingsData.getPluginSettingsForPlugin ? SettingsData.getPluginSettingsForPlugin(id) : {};
    }

    Component.onCompleted: reloadGlobal()
    onPluginIdChanged: reloadGlobal()

    Connections {
        target: PluginService
        function onPluginDataChanged(changedId) {
            if (changedId === (root.pluginId !== "" ? root.pluginId : "jlabWidget"))
                root.reloadGlobal();
        }
    }

    readonly property real mainSize: cfg.desktopMainSize ?? 28
    readonly property real backgroundOpacity: (cfg.desktopBackgroundOpacity ?? 0) / 100
    readonly property bool showReading: cfg.showReading ?? true
    readonly property bool showRomaji: cfg.showRomaji ?? false
    readonly property bool showMeaning: cfg.showMeaning ?? true
    readonly property bool showSource: cfg.showSource ?? false
    readonly property string fontFamily: (cfg.fontFamily ?? "") !== "" ? cfg.fontFamily : Theme.fontFamily
    readonly property bool textShadow: cfg.desktopTextShadow ?? true

    JlabDeck {
        id: deck
        settings: root.cfg
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
            wrapMode: Text.Wrap
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showReading && deck.reading !== "" && deck.reading.replace(/ /g, "") !== deck.main
            width: parent.width
            text: deck.reading
            font.family: root.fontFamily
            font.pixelSize: Math.max(Theme.fontSizeSmall, root.mainSize * 0.6)
            color: Theme.primary
            wrapMode: Text.Wrap
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showRomaji && deck.romaji !== ""
            width: parent.width
            text: deck.romaji
            font.pixelSize: Math.max(Theme.fontSizeSmall, root.mainSize * 0.45)
            color: Theme.surfaceVariantText
            wrapMode: Text.Wrap
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showMeaning && deck.meaning !== ""
            width: parent.width
            text: deck.meaning
            font.pixelSize: Math.max(Theme.fontSizeSmall, root.mainSize * 0.5)
            color: Theme.surfaceText
            wrapMode: Text.Wrap
            style: root.textShadow ? Text.Outline : Text.Normal
            styleColor: Theme.withAlpha(Theme.surface, 0.7)
        }

        Text {
            visible: root.showSource && deck.source !== ""
            width: parent.width
            text: deck.source
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            opacity: 0.8
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton   // right button stays with the DMS drag/resize handler
        onClicked: mouse => mouse.button === Qt.MiddleButton ? deck.play() : deck.next(true)
    }
}
