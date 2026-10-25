pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import "PasswordGenerator.js" as PasswordGenerator

Item {
    id: root

    property var configuration
    property var secureRandom
    property var clipboard

    property string generatedPassword: ""
    property bool copied: false

    readonly property string uppercaseCharacters: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    readonly property string lowercaseCharacters: "abcdefghijklmnopqrstuvwxyz"
    readonly property string digitCharacters: "0123456789"
    readonly property string specialCharacters: "!@#$%^&*"

    readonly property string availableCharacters:
        (configuration && configuration.includeUppercase ? uppercaseCharacters : "")
        + (configuration && configuration.includeLowercase ? lowercaseCharacters : "")
        + (configuration && configuration.includeDigits ? digitCharacters : "")
        + (configuration && configuration.includeSpecialCharacters ? specialCharacters : "")

    readonly property real entropy:
        PasswordGenerator.estimateEntropy(
            configuration ? configuration.passwordLength : 16,
            availableCharacters.length,
            configuration ? configuration.minimumNumbers : 0,
            configuration ? configuration.minimumSpecialCharacters : 0
        )

    readonly property color strengthColor:
        entropy < 40 ? "#e53935"
        : entropy < 60 ? "#fb8c00"
        : entropy < 80 ? "#fdd835"
        : "#43a047"

    readonly property string strength:
        entropy < 40 ? i18n("Weak")
        : entropy < 60 ? i18n("Fair")
        : entropy < 80 ? i18n("Strong")
        : i18n("Very strong")

    readonly property real strengthValue: Math.min(1, entropy / 100)

    Timer {
        id: copyResetTimer
        interval: 1500
        repeat: false
        onTriggered: root.copied = false
    }

    Connections {
        target: root.configuration

        function onPasswordLengthChanged() { root.generate() }
        function onMinimumNumbersChanged() { root.generate() }
        function onMinimumSpecialCharactersChanged() { root.generate() }
    }

    function generate() {
        if (!root.configuration || !root.secureRandom)
            return

        if (root.availableCharacters.length === 0) {
            root.generatedPassword = ""
            root.copied = false
            return
        }

        root.generatedPassword = PasswordGenerator.generate(
            root.configuration.passwordLength,
            root.configuration.includeUppercase,
            root.configuration.includeLowercase,
            root.configuration.includeDigits,
            root.configuration.includeSpecialCharacters,
            root.configuration.includeDigits ? root.configuration.minimumNumbers : 0,
            root.configuration.includeSpecialCharacters ? root.configuration.minimumSpecialCharacters : 0,
            root.secureRandom
        )
        
        root.copied = false
        copyResetTimer.stop()
    }

    function copyPassword() {
        if (!root.generatedPassword || !root.clipboard)
            return

        root.clipboard.content = root.generatedPassword
        root.copied = true
        copyResetTimer.restart()
    }

    Component.onCompleted: generate()

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: passwordContent.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
    
        ColumnLayout {
            id: passwordContent
    
            width: parent.width
            spacing: 14
    
            // Generated password and Copy button
            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 80
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                
                    radius: 8
                    color: Kirigami.Theme.alternateBackgroundColor
                    clip: true
                
                    Flickable {
                        id: passwordFlickable
                
                        anchors.fill: parent
                        anchors.margins: 8
                
                        contentWidth: width
                        contentHeight: passwordLabel.implicitHeight
                
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                
                        PlasmaComponents.Label {
                            id: passwordLabel
                
                            width: passwordFlickable.width
                
                            text: root.generatedPassword
                            wrapMode: Text.WrapAnywhere
                            verticalAlignment: Text.AlignVCenter
                
                            font.family: "monospace"
                            font.pointSize: 13
                            font.bold: true
                            color: Kirigami.Theme.textColor
                        }
                    }
                }
            
                PlasmaComponents.ToolButton {
                    Layout.alignment: Qt.AlignVCenter
            
                    icon.name: root.copied ? "dialog-ok-apply" : "edit-copy"
                    text: root.copied ? i18n("Copied") : i18n("Copy")
                    enabled: root.generatedPassword.length > 0
            
                    onClicked: root.copyPassword()
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
            
                enabled: root.availableCharacters.length > 0
            
                onClicked: root.generate()
            }
    
            Kirigami.Separator {
                Layout.fillWidth: true
            }
    
            // Password length
            RowLayout {
                Layout.fillWidth: true
    
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: i18n("Password length")
                }
    
                PlasmaComponents.Label {
                    text: root.configuration ? root.configuration.passwordLength : 16
                    font.bold: true
                }
            }
    
            QQC2.Slider {
                id: lengthSlider
                Layout.fillWidth: true
                from: 5
                to: 128
                stepSize: 1
                value: root.configuration ? root.configuration.passwordLength : 16
                onMoved: {
                    if (root.configuration)
                        root.configuration.passwordLength = Math.round(value)
                }
            }
    
            Kirigami.Separator {
                Layout.fillWidth: true
            }
    
            // Character sets
            PlasmaComponents.Label {
                text: i18n("Character sets")
                font.bold: true
            }
    
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 4
            
                QQC2.CheckBox {
                    text: i18n("Uppercase (A-Z)")
                    checked: root.configuration ? root.configuration.includeUppercase: true
            
                    onToggled: {
                        root.configuration.includeUppercase = checked
                        root.generate()
                    }
                }
            
                QQC2.CheckBox {
                    text: i18n("Lowercase (a-z)")
                    checked: root.configuration ? root.configuration.includeLowercase : true
            
                    onToggled: {
                        root.configuration.includeLowercase = checked
                        root.generate()
                    }
                }
            
                QQC2.CheckBox {
                    text: i18n("Numbers (0-9)")
                    checked: root.configuration ? root.configuration.includeDigits : true
            
                    onToggled: {
                        root.configuration.includeDigits = checked
                        root.generate()
                    }
                }
            
                QQC2.CheckBox {
                    text: i18n("Special characters (!@#$%^&*)")
                    checked: root.configuration ? root.configuration.includeSpecialCharacters : true
            
                    onToggled: {
                        root.configuration.includeSpecialCharacters = checked
                        root.generate()
                    }
                }
            }
    
            Kirigami.Separator {
                Layout.fillWidth: true
            }
    
            // Minimum character requirements
            PlasmaComponents.Label {
                text: i18n("Minimum requirements")
                font.bold: true
            }
    
            RowLayout {
                Layout.fillWidth: true
    
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: i18n("Numbers")
                    opacity: root.configuration && root.configuration.includeDigits ? 1 : 0.5
                }
    
                QQC2.SpinBox {
                    from: 1
                    to: 9
                    editable: true
                    enabled: root.configuration ? root.configuration.includeDigits : false
                    value: root.configuration ? root.configuration.minimumNumbers : 1
                    onValueModified: {
                        if (root.configuration)
                            root.configuration.minimumNumbers = value
                    }
                }
            }
    
            RowLayout {
                Layout.fillWidth: true
    
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: i18n("Special characters")
                    opacity: root.configuration && root.configuration.includeSpecialCharacters ? 1 : 0.5
                }
    
                QQC2.SpinBox {
                    from: 1
                    to: 9
                    editable: true
                    enabled: root.configuration ? root.configuration.includeSpecialCharacters : false
                    value: root.configuration ? root.configuration.minimumSpecialCharacters : 1
                    onValueModified: {
                        if (root.configuration)
                            root.configuration.minimumSpecialCharacters = value
                    }
                }
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
                    text: i18n("%1 characters", root.configuration.passwordLength)
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
            
                text: i18n("Entropy is estimated from the enabled character sets and minimum character requirements. Use longer passwords and a wider variety of character sets for stronger passwords.")
                wrapMode: Text.WordWrap
            
                font.pointSize: 8
                color: Kirigami.Theme.disabledTextColor
            }
        }
    }
}