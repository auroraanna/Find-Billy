#!/usr/bin/env just --justfile
name:='find-billy'
build_dir:='./build'
build_icons_dir:=build_dir+'/icons'
version:='1.1.0'
godot_exe:='godot4'
zip_exe:='7z a'

# By default, recipes are only listed.
default:
	@just --list

# Generate several icon sizes and formats from one icon.
build-icons:
	#!/bin/sh
	set -euxo pipefail
	# Clear {{build_icons_dir}}
	mkdir -p {{build_icons_dir}}
	rm -rf {{build_icons_dir}}
	# Icons
	for icon_width in 32 64 128 160 256 320 512; do
		mkdir -p {{build_icons_dir}}/usr/share/icons/hicolor/$icon_width"x"$icon_width/apps
		inkscape -o {{build_icons_dir}}/usr/share/icons/hicolor/$icon_width"x"$icon_width/apps/{{name}}.png -C -w $icon_width -h $icon_width --export-png-color-mode=RGBA_8 brand/icon.svg
	done
	magick {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.png {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.ico
	magick {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.png {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.icns

archive-icons: build-icons
	tar czf icons.tar.gz --directory=build icons

appdata-releases-update:
	#!/bin/sh
	set -euxo pipefail
	# Update appdata <releases>
	head -1 eu.annaaurora.find_billy.Find_Billy.appdata.xml > eu.annaaurora.find_billy.Find_Billy.appdata.xml.tmp
	xmlstarlet edit --omit-decl -s '//releases' -t elem -n "release" -s '//releases/release[last()]' -t elem -n "url" -v "https://codeberg.org/annaaurora/Find-Billy/releases/tag/v{{version}}" -s '//releases/release[last()]' -t attr -n "version" -v "v{{version}}" -s '//releases/release[last()]' -t attr -n "date" -v "$(date -u +'%Y-%m-%d')" eu.annaaurora.find_billy.Find_Billy.appdata.xml >> eu.annaaurora.find_billy.Find_Billy.appdata.xml.tmp
	mv eu.annaaurora.find_billy.Find_Billy.appdata.xml.tmp eu.annaaurora.find_billy.Find_Billy.appdata.xml
	# Git add
	git add eu.annaaurora.find_billy.Find_Billy.appdata.xml

release: appdata-releases-update
	#!/bin/sh
	set -euxo pipefail
	git commit -m "release: v{{version}}"
	git tag -a -m "version {{version}}" "v{{version}}"

godot-build: godot-build_linux_x86-64 godot-build_windows_x86-64 godot-build_windows_arm64 godot-build_mac_arm64 godot-build_web_wasm godot-build_linux-pack
	
godot-build_linux_x86-64:
	#!/bin/sh
	set -euxo pipefail
	mkdir -v -p godot-build
	{{godot_exe}} -v --export-release "linux_x86-64" godot-build/Find-Billy_{{version}}_linux_x86-64 --headless

godot-build_windows_x86-64:
	#!/bin/sh
	set -euxo pipefail
	mkdir -v -p godot-build
	{{godot_exe}} -v --export-release "windows_x86-64" godot-build/Find-Billy_{{version}}_windows_x86-64.exe --headless

godot-build_windows_arm64:
	#!/bin/sh
	set -euxo pipefail
	mkdir -v -p godot-build
	{{godot_exe}} -v --export-release "windows_arm64" godot-build/Find-Billy_{{version}}_windows_arm64.exe --headless

godot-build_mac_arm64:
	#!/bin/sh
	set -euxo pipefail
	mkdir -v -p godot-build
	{{godot_exe}} -v --export-release "macos_arm64" godot-build/Find-Billy_{{version}}_macos_arm64.zip --headless

godot-build_web_wasm:
	#!/bin/sh
	set -euxo pipefail
	mkdir -v -p godot-build/Find-Billy_{{version}}_web_wasm
	{{godot_exe}} -v --export-release "web_wasm" godot-build/Find-Billy_{{version}}_web_wasm/index.html --headless
	{{zip_exe}} a godot-build/Find-Billy_{{version}}_web_wasm.zip godot-build/Find-Billy_{{version}}_web_wasm/*
	rm -rf godot-build/Find-Billy_{{version}}_web_wasm

godot-build_linux-pack:
	#!/bin/sh
	set -euxo pipefail
	mkdir -v -p godot-build
	{{godot_exe}} -v --export-pack "linux_x86-64" godot-build/godot-runner.pck --headless
