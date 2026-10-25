import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_wordCount: wordCount.value
    property alias cfg_includeCapitals: capitals.checked
    property alias cfg_includeNumbers: numbers.checked
    property string cfg_separator: "-"

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
}
