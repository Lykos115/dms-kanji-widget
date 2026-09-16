import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

// Bar pill: shows the current kanji (optionally with a reading or the meaning).
// Left click (or hover, if the bar has "open popouts on hover" enabled) opens a
// card with kanji / readings / meaning and Play / Next / Jisho buttons.
// Right click skips to the next kanji.
PluginComponent {
    id: root

    layerNamespacePlugin: "kanji-widget"

    readonly property string barStyle: pluginData.barStyle ?? "kanji+reading"
    readonly property string fontFamily: (pluginData.fontFamily ?? "") !== "" ? pluginData.fontFamily : Theme.fontFamily
    readonly property real popoutMainSize: pluginData.popoutMainSize ?? 96
    readonly property int barMaxChars: pluginData.barMaxChars ?? 28

    function shorten(t, n) {
        return t.length > n ? t.slice(0, n - 1).trimEnd() + "…" : t;
    }

    KanjiDeck {
        id: deck
        settings: root.pluginData
    }

    pillRightClickAction: () => deck.next(true)

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            StyledText {
                text: deck.main
                font.family: root.fontFamily
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: text.length > 0
                text: root.barStyle === "kanji+reading" ? root.shorten(deck.reading, root.barMaxChars)
                    : root.barStyle === "kanji+meaning" ? root.shorten(deck.meaning, root.barMaxChars) : ""
                font.family: root.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 0

            StyledText {
                text: deck.main
                font.family: root.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: card
            headerText: deck.tag !== "" ? deck.tag + " KANJI" : "KANJI"
            detailsText: deck.strokes > 0 ? deck.strokes + " strokes" : ""
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingS
                leftPadding: Theme.spacingS
                rightPadding: Theme.spacingS
                bottomPadding: Theme.spacingS

                StyledText {
                    width: parent.width - parent.leftPadding - parent.rightPadding
                    text: deck.main
                    font.family: root.fontFamily
                    font.pixelSize: root.popoutMainSize
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    visible: deck.on !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingS

                    StyledText {
                        text: "音"
                        font.family: root.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    StyledText {
                        text: deck.on
                        font.family: root.fontFamily
                        font.pixelSize: Theme.fontSizeXLarge
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    visible: deck.kun !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingS

                    StyledText {
                        text: "訓"
                        font.family: root.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    StyledText {
                        text: deck.kun
                        font.family: root.fontFamily
                        font.pixelSize: Theme.fontSizeXLarge
                        color: Theme.secondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                StyledText {
                    visible: deck.meaning !== ""
                    width: parent.width - parent.leftPadding - parent.rightPadding
                    text: deck.meaning
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingS
                    topPadding: Theme.spacingXS

                    Rectangle {
                        visible: deck.hasAudio
                        width: playLabel.implicitWidth + Theme.spacingL * 2 + Theme.iconSize
                        height: 34
                        radius: 17
                        color: playArea.containsMouse ? Qt.lighter(Theme.primary, 1.15) : Theme.primary

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            DankIcon {
                                name: "volume_up"
                                size: Theme.iconSize
                                color: Theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                id: playLabel
                                text: "Play"
                                color: Theme.primaryText
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: playArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: deck.play()
                        }
                    }

                    Rectangle {
                        width: nextLabel.implicitWidth + Theme.spacingL * 2
                        height: 34
                        radius: 17
                        color: nextArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                        StyledText {
                            id: nextLabel
                            anchors.centerIn: parent
                            text: "Next"
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: nextArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: deck.next(true)
                        }
                    }

                    Rectangle {
                        width: jishoLabel.implicitWidth + Theme.spacingL * 2
                        height: 34
                        radius: 17
                        color: jishoArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                        StyledText {
                            id: jishoLabel
                            anchors.centerIn: parent
                            text: "Jisho"
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        MouseArea {
                            id: jishoArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["xdg-open", "https://jisho.org/search/" + encodeURIComponent(deck.main) + "%20%23kanji"])
                        }
                    }
                }
            }
        }
    }

    popoutWidth: pluginData.popoutWidth ?? 340
}
