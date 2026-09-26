/*
    SPDX-License-Identifier: Unlicense

    Shows a different image for each virtual desktop. Every desktop's image is loaded
    up front and only the current one is visible, so switching is instant: no fade,
    no blank frame while an image decodes.
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.taskmanager as TaskManager

import "../code/images.js" as Images

Rectangle {
    id: view

    /** "desktop-id=image-url" entries, see images.js. */
    property list<string> desktopImages
    property int fillMode: Image.PreserveAspectCrop

    readonly property var images: Images.parse(desktopImages)

    // Decode at screen resolution when the image gets scaled to the screen anyway, so
    // keeping every desktop's image in memory stays cheap even for huge source files.
    readonly property size decodeSize: fillMode === Image.PreserveAspectCrop || fillMode === Image.PreserveAspectFit
        ? Qt.size(Math.round(width * Screen.devicePixelRatio), Math.round(height * Screen.devicePixelRatio))
        : Qt.size(-1, -1)

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }

    Repeater {
        model: desktopInfo.desktopIds

        Image {
            required property var modelData

            anchors.fill: parent
            source: view.images[modelData] ?? ""
            visible: modelData === desktopInfo.currentDesktop
            fillMode: view.fillMode
            sourceSize: view.decodeSize
            asynchronous: true
            cache: false
            smooth: true
        }
    }
}
