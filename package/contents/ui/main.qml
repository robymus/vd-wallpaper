/*
    SPDX-License-Identifier: Unlicense

    Shows a different image for each virtual desktop. Every desktop's image is loaded
    up front and only the current one is visible, so switching is instant: no fade,
    no blank frame while an image decodes.
*/

pragma ComponentBehavior: Bound

// org.kde.plasma.plasmoid (WallpaperItem) is registered by plasmashell at runtime and
// has no qmltypes on disk, so qmllint cannot resolve it or its default property.
// qmllint disable import unresolved-type missing-property
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

import "../code/images.js" as Images

WallpaperItem {
    id: root

    readonly property var images: Images.parse(root.configuration.DesktopImages)
    readonly property int fillMode: root.configuration.FillMode

    // Decode at screen resolution when the image gets scaled to the screen anyway, so
    // keeping every desktop's image in memory stays cheap even for huge source files.
    readonly property size decodeSize: fillMode === Image.PreserveAspectCrop || fillMode === Image.PreserveAspectFit
        ? Qt.size(Math.round(root.width * Screen.devicePixelRatio), Math.round(root.height * Screen.devicePixelRatio))
        : Qt.size(-1, -1)

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }

    Rectangle {
        anchors.fill: parent
        color: root.configuration.Color
    }

    Repeater {
        model: desktopInfo.desktopIds

        Image {
            required property var modelData

            anchors.fill: parent
            source: root.images[modelData] ?? ""
            visible: modelData === desktopInfo.currentDesktop
            fillMode: root.fillMode
            sourceSize: root.decodeSize
            asynchronous: true
            cache: false
            smooth: true
        }
    }
}
