import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols

Kirigami.FormLayout {
    id: page

    // Passphrase settings
    property alias cfg_wordCount: wordCount.value
    property alias cfg_includeCapitals: capitals.checked
    property alias cfg_includeNumbers: numbers.checked
    property string cfg_separator: "-"

    // Password settings
    property alias cfg_passwordLength: passwordLength.value
    property alias cfg_includeUppercase: uppercase.checked
    property alias cfg_includeLowercase: lowercase.checked
    property alias cfg_includeDigits: digits.checked
    property alias cfg_includeSpecialCharacters: specialCharacters.checked

    property int cfg_minimumNumbers: 1
    property int cfg_minimumSpecialCharacters: 1

    // Password strength indicator
    property color cfg_veryWeakColor: "#e53935"
    property color cfg_weakColor: "#fb8c00"
    property color cfg_moderateColor: "#fdd835"
    property color cfg_strongColor: "#43a047"

    // --------------------------------------------------
    // Password generator
    // --------------------------------------------------

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Password generator")
    }

    QQC2.SpinBox {
        id: passwordLength
        Kirigami.FormData.label: i18n("Password length:")
        from: 5
        to: 128
    }

    QQC2.CheckBox {
        id: uppercase
        Kirigami.FormData.label: i18n("Uppercase letters:")
        text: "A-Z"
    }

    QQC2.CheckBox {
        id: lowercase
        Kirigami.FormData.label: i18n("Lowercase letters:")
        text: "a-z"
    }

    QQC2.CheckBox {
        id: digits
        Kirigami.FormData.label: i18n("Numbers:")
        text: "0-9"
    }

    QQC2.ComboBox {
        id: minimumNumbers
        Kirigami.FormData.label: i18n("Minimum numbers:")
        enabled: digits.checked
        model: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        Component.onCompleted: currentIndex = page.cfg_minimumNumbers - 1
        onActivated: page.cfg_minimumNumbers = currentIndex + 1
    }

    QQC2.CheckBox {
        id: specialCharacters
        Kirigami.FormData.label: i18n("Special characters:")
        text: "!@#$%^&*"
    }

    QQC2.ComboBox {
        id: minimumSpecialCharacters
        Kirigami.FormData.label: i18n("Minimum special characters:")
        enabled: specialCharacters.checked
        model: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        Component.onCompleted: currentIndex = page.cfg_minimumSpecialCharacters - 1
        onActivated: page.cfg_minimumSpecialCharacters = currentIndex + 1
    }

    // --------------------------------------------------
    // Passphrase generator
    // --------------------------------------------------

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Passphrase generator")
    }

    QQC2.SpinBox {
        id: wordCount
        Kirigami.FormData.label: i18n("Number of words:")
        from: 2
        to: 12
    }

    QQC2.CheckBox {
        id: capitals
        Kirigami.FormData.label: i18n("Capital letters:")
        text: i18n("Capitalise words")
    }

    QQC2.CheckBox {
        id: numbers
        Kirigami.FormData.label: i18n("Numbers:")
        text: i18n("Append random digits")
    }

    QQC2.ComboBox {
        id: separator
        Kirigami.FormData.label: i18n("Separator:")
        textRole: "label"
        valueRole: "value"
        model: [
            { label: i18n("Hyphen (-)"), value: "-" },
            { label: i18n("Underscore (_)"), value: "_" },
            { label: i18n("Period (.)"), value: "." },
            { label: i18n("Space"), value: " " },
            { label: i18n("No separator"), value: "" }
        ]

        Component.onCompleted: currentIndex = indexOfValue(page.cfg_separator)
        onActivated: page.cfg_separator = currentValue
    }

    // --------------------------------------------------
    // Password strength indicator
    // --------------------------------------------------

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Password strength indicator")
    }

    ColorButton {
        Kirigami.FormData.label: i18n("Very weak:")
        color: page.cfg_veryWeakColor
        onColorChanged: page.cfg_veryWeakColor = color
    }

    ColorButton {
        Kirigami.FormData.label: i18n("Weak:")
        color: page.cfg_weakColor
        onColorChanged: page.cfg_weakColor = color
    }

    ColorButton {
        Kirigami.FormData.label: i18n("Moderate:")
        color: page.cfg_moderateColor
        onColorChanged: page.cfg_moderateColor = color
    }

    ColorButton {
        Kirigami.FormData.label: i18n("Strong:")
        color: page.cfg_strongColor
        onColorChanged: page.cfg_strongColor = color
    }
}
