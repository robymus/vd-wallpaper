/*
    SPDX-License-Identifier: Unlicense

    The DesktopImages config entry is a string list of "desktop-id=image-url" entries.
    Desktop ids (KWin UUIDs) never contain "=", so the first "=" separates the two.
*/

.pragma library

/** Returns an object mapping desktop id -> image url. Malformed entries are ignored. */
function parse(entries) {
    const map = {};
    for (const entry of entries ?? []) {
        const sep = entry.indexOf("=");
        if (sep > 0 && sep < entry.length - 1) {
            map[entry.slice(0, sep)] = entry.slice(sep + 1);
        }
    }
    return map;
}

/** Returns a new entry list with desktopId's image set to url, or removed if url is empty. */
function withImage(entries, desktopId, url) {
    const prefix = desktopId + "=";
    const result = (entries ?? []).filter(e => !e.startsWith(prefix));
    if (url) {
        result.push(prefix + url);
    }
    return result;
}
