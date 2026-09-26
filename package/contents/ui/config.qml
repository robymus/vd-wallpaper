/*
    SPDX-License-Identifier: Unlicense

    Settings page. Plasma reads and writes the cfg_* properties; it also twins its own
    form layout with ours through the formLayout alias, which aligns the labels.
*/

pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as QtDialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.taskmanager as TaskManager

import "../code/images.js" as Images

Kirigami.FormLayout {
    id: root

    property alias formLayout: root
    property var cfg_DesktopImages: []
    property int cfg_FillMode
    property alias cfg_Color: colorButton.color

    readonly property var images: Images.parse(cfg_DesktopImages)

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }

    Repeater {
        model: desktopInfo.desktopIds

        RowLayout {
            id: desktopRow

            required property var modelData
            required property int index
            readonly property string image: root.images[modelData] ?? ""

            Kirigami.FormData.label: (desktopInfo.desktopNames[index] ?? qsTr("Desktop %1").arg(index + 1)) + ":"
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                Layout.preferredHeight: Kirigami.Units.gridUnit * 5
                color: colorButton.color
                border.color: Kirigami.Theme.disabledTextColor

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: desktopRow.image
                    fillMode: root.cfg_FillMode
                    sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
                    asynchronous: true
                    clip: true
                }
            }

            QQC2.Button {
                icon.name: "document-open"
                text: qsTr("Choose…")
                onClicked: {
                    fileDialog.desktopId = desktopRow.modelData;
                    fileDialog.open();
                }
            }

            QQC2.Button {
                icon.name: "edit-clear"
                enabled: desktopRow.image !== ""
                display: QQC2.AbstractButton.IconOnly
                text: qsTr("Clear")
                QQC2.ToolTip.text: text
                QQC2.ToolTip.visible: hovered
                // Assign a new array so the config dialog notices the change.
                onClicked: root.cfg_DesktopImages = Images.withImage(root.cfg_DesktopImages, desktopRow.modelData, "")
            }
        }
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: qsTr("Positioning:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: qsTr("Scaled and Cropped"), value: Image.PreserveAspectCrop },
            { text: qsTr("Scaled"), value: Image.Stretch },
            { text: qsTr("Scaled, Keep Proportions"), value: Image.PreserveAspectFit },
            { text: qsTr("Centered"), value: Image.Pad },
            { text: qsTr("Tiled"), value: Image.Tile },
        ]
        Component.onCompleted: currentIndex = indexOfValue(root.cfg_FillMode)
        onActivated: root.cfg_FillMode = currentValue
    }

    KQuickControls.ColorButton {
        id: colorButton

        Kirigami.FormData.label: qsTr("Background color:")
        dialogTitle: qsTr("Select Background Color")
    }

    QtDialogs.FileDialog {
        id: fileDialog

        property string desktopId

        title: qsTr("Choose Wallpaper Image")
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: [qsTr("Images (*.png *.jpg *.jpeg *.webp *.avif *.jxl *.bmp *.gif *.svg)")]
        onAccepted: root.cfg_DesktopImages = Images.withImage(root.cfg_DesktopImages, desktopId, selectedFile.toString())
    }
}
