pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.kirigami as Kirigami
import "PassphraseGenerator.js" as PassphraseGenerator
import "words.js" as WordList
import "OpenSquares/PassForge"

PlasmoidItem {
    id: root

    Plasmoid.icon: "password-generate-symbolic"

    property string generatedPassphrase: ""
    property bool copied: false
    property int animationTrigger: 0
    readonly property color strengthColor:
        entropy < 40 ? "#e53935"
        : entropy < 60 ? "#fb8c00"
        : entropy < 80 ? "#fdd835"
        : "#43a047"

    Timer {
        id: copyResetTimer
        interval: 1500
        repeat: false
    
        onTriggered: root.copied = false
    }
    readonly property real entropy:
    PassphraseGenerator.estimateEntropy(
        plasmoid.configuration.wordCount,
        WordList.words,
        plasmoid.configuration.includeNumbers
    )

    KQuickControlsAddons.Clipboard {
        id: clipboard
    }

    SecureRandom {
        id: secureRandom
    }

    readonly property string strength:
        entropy < 40 ? i18n("Weak")
        : entropy < 60 ? i18n("Fair")
        : entropy < 80 ? i18n("Strong")
        : i18n("Very strong")

    readonly property real strengthValue: Math.min(1, entropy / 100)

    Connections {
        target: root.plasmoid.configuration
    
        function onWordCountChanged() {
            root.generate()
        }
    
        function onIncludeCapitalsChanged() {
            root.generate()
        }
    
        function onIncludeNumbersChanged() {
            root.generate()
        }
    
        function onSeparatorChanged() {
            root.generate()
        }
    }

    function generate() {
        generatedPassphrase = PassphraseGenerator.generate(
            WordList.words,
            plasmoid.configuration.wordCount,
            plasmoid.configuration.includeCapitals,
            plasmoid.configuration.includeNumbers,
            plasmoid.configuration.separator,
            secureRandom
        )

        copied = false
        animationTrigger++
        copyResetTimer.stop()
    }

    Component.onCompleted: generate()

    // ------------------------------------------------------------
    // Compact representation: panel icon
    // ------------------------------------------------------------

    compactRepresentation: PlasmaComponents.ToolButton {
        icon.name: "password-generate-symbolic"
        display: QQC2.AbstractButton.IconOnly
        onClicked: root.expanded = !root.expanded
    }

    // ------------------------------------------------------------
    // Full representation: passphrase generator popup
    // ------------------------------------------------------------

    fullRepresentation: Item {
        id: fullRepresentationItem

        function animatePassphrase() {
            passphraseAnimation.restart()
        }
        Layout.minimumWidth: 360
        Layout.preferredWidth: 400
        Layout.minimumHeight: 550
        Layout.preferredHeight: 600

        SequentialAnimation {
            id: passphraseAnimation
        
            NumberAnimation {
                target: passphraseLabel
                property: "opacity"
                to: 0
                duration: 180
                easing.type: Easing.OutCubic
            }
        
            NumberAnimation {
                target: passphraseLabel
                property: "opacity"
                to: 1
                duration: 350
                easing.type: Easing.OutCubic
            }
        }
        
        Connections {
            target: root
        
            function onAnimationTriggerChanged() {
                if (root.animationTrigger > 0) {
                    passphraseAnimation.restart()
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent

            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            anchors.bottomMargin: 5
        
            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 2
                    text: i18n("PassForge")
                }

                PlasmaComponents.ToolButton {
                    icon.name: "configure"
                    text: i18n("Settings")
                    display: QQC2.AbstractButton.IconOnly
                
                    onClicked: Plasmoid.internalAction("configure").trigger()
                }
            }

            // Generated passphrase and Copy button
            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 60
                spacing: 12
            
                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 80
                
                    radius: 8
                    color: Kirigami.Theme.alternateBackgroundColor
                    clip: true
                
                    PlasmaComponents.Label {
                        id: passphraseLabel
                
                        anchors.fill: parent
                        anchors.margins: 8
                
                        text: root.generatedPassphrase
                        wrapMode: Text.WrapAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.family: "monospace"
                        font.pointSize: 13
                        font.bold: true
                        color: Kirigami.Theme.textColor
                
                        opacity: 1
                    }
                }
            
                PlasmaComponents.ToolButton {
                    Layout.alignment: Qt.AlignVCenter
                
                    icon.name: root.copied ? "dialog-ok-apply" : "edit-copy"
                    text: root.copied ? i18n("Copied") : i18n("Copy")
                    enabled: root.generatedPassphrase.length > 0
                
                    onClicked: {
                        clipboard.content = root.generatedPassphrase
                        root.copied = true
                        copyResetTimer.restart()
                    }
                }
            }
            
            // Generate button
            PlasmaComponents.Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
            
                leftPadding: 50
                rightPadding: 50
                topPadding: 10
                bottomPadding: 10
            
                icon.name: "view-refresh"
                text: i18n("Generate")
                display: QQC2.AbstractButton.TextBesideIcon
            
                onClicked: root.generate()
            }
            

            // Word count
            PlasmaComponents.Label {
                text: i18n("Words: %1", root.plasmoid.configuration.wordCount)
                font.bold: true
            }

            QQC2.Slider {
                Layout.fillWidth: true

                from: 2
                to: 12
                stepSize: 1
                snapMode: QQC2.Slider.SnapAlways

                value: root.plasmoid.configuration.wordCount

                onMoved: root.plasmoid.configuration.wordCount = Math.round(value)
            }

            // Options
            QQC2.CheckBox {
                text: i18n("Include capital letters")

                checked: root.plasmoid.configuration.includeCapitals
                onToggled: root.plasmoid.configuration.includeCapitals = checked
            }

            QQC2.CheckBox {
                text: i18n("Include numbers")

                checked: root.plasmoid.configuration.includeNumbers
                onToggled: root.plasmoid.configuration.includeNumbers = checked
            }

            // Separator
            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: i18n("Separator")
                }

                Item {
                    Layout.fillWidth: true
                }

                QQC2.ComboBox {
                    textRole: "label"
                    valueRole: "value"

                    model: [
                        { label: i18n("Hyphen (-)"), value: "-" },
                        { label: i18n("Underscore (_)"), value: "_" },
                        { label: i18n("Period (.)"), value: "." },
                        { label: i18n("Space"), value: " " },
                        { label: i18n("None"), value: "" }
                    ]

                    Component.onCompleted: {
                        currentIndex = indexOfValue(root.plasmoid.configuration.separator)
                    }

                    onActivated: {
                        root.plasmoid.configuration.separator = currentValue
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            // Strength
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
            
                Rectangle {
                    Layout.preferredWidth: 10
                    Layout.preferredHeight: 10
            
                    radius: width / 2
                    color: root.strengthColor
                }
            
                PlasmaComponents.Label {
                    text: root.strength
                    font.bold: true
                }
            
                Item {
                    Layout.fillWidth: true
                }
            
                PlasmaComponents.Label {
                    text: i18n("%1 words", root.plasmoid.configuration.wordCount)
                    color: Kirigami.Theme.disabledTextColor
                }
            
                PlasmaComponents.Label {
                    text: i18n("~%1 bits", Math.round(root.entropy))
                    font.bold: true
                }
            }

            QQC2.ProgressBar {
                Layout.fillWidth: true

                from: 0
                to: 1
                value: root.strengthValue
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true

                text: i18n("Entropy is estimated from the word-list size and randomly generated numeric suffix. Capitalization does not increase entropy. Use more words for stronger passphrases.")
                wrapMode: Text.WordWrap

                // font: Kirigami.Theme.smallestFont
                // font.pointSize: Kirigami.Theme.smallestFont.pointSize
                font.pointSize: 8
                color: Kirigami.Theme.disabledTextColor
            }
        }
    }
}