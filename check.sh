#!/usr/bin/env bash
# Lint the plugin and run its unit tests. Exits non-zero on any lint warning or test failure.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

# Qt warns on stderr under a non-UTF-8 locale (e.g. "C" in CI containers), which the
# .js lint below would count as a failure.
export LC_ALL=C.UTF-8

QT_BIN=/usr/lib/qt6/bin
QML_IMPORTS=/usr/lib/x86_64-linux-gnu/qt6/qml

for tool in "$QT_BIN/qmllint" "$QT_BIN/qmltestrunner"; do
    if [[ ! -x $tool ]]; then
        echo "missing $tool: sudo apt install qt6-declarative-dev-tools qml6-module-qttest" >&2
        exit 1
    fi
done

echo "== qmllint"
"$QT_BIN/qmllint" --max-warnings 0 -I "$QML_IMPORTS" package/contents/ui/*.qml tests/*.qml
# qmllint 6.8 segfaults on .js files when --max-warnings is given, and without it warnings
# don't affect the exit code, so treat any output as a failure.
for f in package/contents/code/*.js; do
    out=$("$QT_BIN/qmllint" "$f" 2>&1)
    if [[ -n $out ]]; then
        echo "$out" >&2
        exit 1
    fi
done
echo "ok"

echo "== tests"
QT_QPA_PLATFORM=offscreen "$QT_BIN/qmltestrunner" -input tests
