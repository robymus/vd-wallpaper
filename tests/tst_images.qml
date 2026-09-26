import QtQuick
import QtTest

import "../package/contents/code/images.js" as Images

TestCase {
    name: "Images"

    readonly property string d1: "c6754955-3d44-4009-b43f-7028c3ec9e4e"
    readonly property string d2: "7b5223a5-3291-4125-99d0-a3fda5654d7a"

    function test_parse_empty() {
        compare(Images.parse([]), {});
        compare(Images.parse(undefined), {});
    }

    function test_parse_entries() {
        compare(Images.parse([d1 + "=file:///a.jpg", d2 + "=file:///b.png"]),
                { [d1]: "file:///a.jpg", [d2]: "file:///b.png" });
    }

    function test_parse_splits_on_first_equals() {
        compare(Images.parse([d1 + "=file:///x=y.jpg"]), { [d1]: "file:///x=y.jpg" });
    }

    function test_parse_ignores_malformed() {
        compare(Images.parse(["no-separator", "=file:///no-id.jpg", d1 + "="]), {});
    }

    function test_parse_last_entry_wins() {
        compare(Images.parse([d1 + "=file:///old.jpg", d1 + "=file:///new.jpg"]), { [d1]: "file:///new.jpg" });
    }

    function test_withImage_adds() {
        compare(Images.withImage([], d1, "file:///a.jpg"), [d1 + "=file:///a.jpg"]);
        compare(Images.withImage(undefined, d1, "file:///a.jpg"), [d1 + "=file:///a.jpg"]);
    }

    function test_withImage_replaces_and_keeps_others() {
        const entries = [d1 + "=file:///a.jpg", d2 + "=file:///b.jpg"];
        compare(Images.withImage(entries, d1, "file:///c.jpg"), [d2 + "=file:///b.jpg", d1 + "=file:///c.jpg"]);
    }

    function test_withImage_empty_url_removes() {
        compare(Images.withImage([d1 + "=file:///a.jpg", d2 + "=file:///b.jpg"], d1, ""), [d2 + "=file:///b.jpg"]);
    }

    function test_withImage_does_not_mutate_input() {
        const entries = [d1 + "=file:///a.jpg"];
        Images.withImage(entries, d1, "");
        compare(entries, [d1 + "=file:///a.jpg"]);
    }
}
