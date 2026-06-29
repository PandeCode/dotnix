#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 0 ]]; then
	qml_file="$1"
else
	qml_file="$(mktemp --suffix=.qml)"
	trap 'rm -f "$qml_file"' EXIT
	cat >"$qml_file"
fi

nix-shell -p \
	qt6Packages.qtdeclarative \
	qt6Packages.qtmultimedia \
	qt6Packages.qt5compat \
	qt6Packages.qtpositioning \
	qt6Packages.qtlocation \
	qt6Packages.qtquick3d \
	qt6Packages.qtcharts \
	qt6Packages.qtshadertools \
	qt6Packages.qtwebchannel \
	qt6Packages.qtwebsockets \
	qt6Packages.qtserialport \
	qt6Packages.qtconnectivity \
	qt6Packages.qtsvg \
	qt6Packages.qtimageformats \
	pipewire \
	--run '
QML_IMPORT_PATH=""

for p in /nix/store/*; do
    if [[ -d "$p/lib/qt-6/qml" ]]; then
        QML_IMPORT_PATH="${QML_IMPORT_PATH:+$QML_IMPORT_PATH:}$p/lib/qt-6/qml"
    fi
done

export QML_IMPORT_PATH
export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
export QT_DEBUG_PLUGINS=1

exec qml "'"$qml_file"'"
'
