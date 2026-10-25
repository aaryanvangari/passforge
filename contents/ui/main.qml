pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.kirigami as Kirigami
import OpenSquares.PassForge

PlasmoidItem {
    id: root

    Plasmoid.icon: "password-generate-symbolic"

    // Shared resources
    property alias sharedClipboard: clipboard
    property alias sharedSecureRandom: secureRandom

    KQuickControlsAddons.Clipboard {
        id: clipboard
    }

    SecureRandom {
        id: secureRandom
    }

    // ------------------------------------------------------------
    // Compact representation: panel icon
    // ------------------------------------------------------------

    compactRepresentation: PlasmaComponents.ToolButton {
        icon.name: "password-generate-symbolic"
        display: QQC2.AbstractButton.IconOnly
        onClicked: root.expanded = !root.expanded
    }

    // ------------------------------------------------------------
    // Full representation: generator popup
    // ------------------------------------------------------------

    fullRepresentation: Item {
        id: fullRepresentationItem

        Layout.minimumWidth: 360
        Layout.preferredWidth: 400
        Layout.minimumHeight: 750
        Layout.preferredHeight: 900

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

            // Generator tabs
            PlasmaComponents.TabBar {
                id: generatorTabs
            
                Layout.fillWidth: true
            
                PlasmaComponents.TabButton {
                    text: i18n("Password")
                }
            
                PlasmaComponents.TabButton {
                    text: i18n("Passphrase")
                }
            }

            // Generator pages
            StackLayout {
                id: generatorStack

                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: generatorTabs.currentIndex

                // Password generator
                PasswordGenerator {
                    configuration: root.plasmoid.configuration
                    secureRandom: root.sharedSecureRandom
                    clipboard: root.sharedClipboard
                }

                // Passphrase generator
                PassphraseGenerator {
                    configuration: root.plasmoid.configuration
                    secureRandom: root.sharedSecureRandom
                    clipboard: root.sharedClipboard
                }
            }
        }
    }
}