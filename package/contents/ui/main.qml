/*
    SPDX-License-Identifier: Unlicense

    Plasma entry point: passes the configuration to WallpaperView, which does the work.
*/

// org.kde.plasma.plasmoid (WallpaperItem) is registered by plasmashell at runtime and
// has no qmltypes on disk, so qmllint cannot resolve it or its members. That is why
// this file is kept to a thin wrapper and all logic lives in the fully linted
// WallpaperView.qml.
// qmllint disable import unresolved-type missing-property
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root

    WallpaperView {
        anchors.fill: parent
        desktopImages: root.configuration.DesktopImages
        fillMode: root.configuration.FillMode
        color: root.configuration.Color
    }
}
