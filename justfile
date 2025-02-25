#!/usr/bin/env just --justfile
name:='find-billy'
build_dir:='./build'
build_icons_dir:=build_dir+'/icons'
alpine_deps:='git xmlstarlet imagemagick inkscape'
nixpkgs_deps:='git xmlstarlet imagemagick inkscape'
version:='0.1.0'

# By default, recipes are only listed.
default:
	@just --list

alpine-install-deps:
	@apk add {{alpine_deps}}

alpine-uninstall-deps:
	@apk del {{alpine_deps}}

non-nixos-install-deps:
	#!/bin/sh
	set -euxo pipefail
	for package_name in {{nixpkgs_deps}}; do
		nix-env -iA nixpkgs.$package_name
	done

nixos-install-deps:
	#!/bin/sh
	set -euxo pipefail
	for package_name in {{nixpkgs_deps}}; do
		nix-env -iA nixos.$package_name
	done

nix-uninstall-deps:
	#!/bin/sh
	set -euxo pipefail
	for package_name in {{nixpkgs_deps}}; do
		nix-env -e $package_name
	done

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
	convert {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.png {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.ico
	convert {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.png {{build_icons_dir}}/usr/share/icons/hicolor/128x128/apps/{{name}}.icns

changelog:
	#!/bin/sh
	set -euxo pipefail
	# Generate changelog
	git-chglog > CHANGELOG.md
	# Git add
	git add CHANGELOG.md

appdata-releases-update:
	#!/bin/sh
	set -euxo pipefail
	# Update appdata <releases>
	head -1 eu.annaaurora.find_billy.Find_Billy.appdata.xml > eu.annaaurora.find_billy.Find_Billy.appdata.xml.tmp
	xmlstarlet edit --omit-decl -s '//releases' -t elem -n "release" -s '//releases/release[last()]' -t elem -n "url" -v "https://codeberg.org/annaaurora/Find-Billy/releases/tag/v{{version}}" -s '//releases/release[last()]' -t attr -n "version" -v "v{{version}}" -s '//releases/release[last()]' -t attr -n "date" -v "$(date -u +'%Y-%m-%d')" eu.annaaurora.find_billy.Find_Billy.appdata.xml >> eu.annaaurora.find_billy.Find_Billy.appdata.xml.tmp
	mv eu.annaaurora.find_billy.Find_Billy.appdata.xml.tmp eu.annaaurora.find_billy.Find_Billy.appdata.xml
	# Git add
	git add eu.annaaurora.find_billy.Find_Billy.appdata.xml

release: changelog appdata-releases-update
	#!/bin/sh
	set -euxo pipefail
	git commit -m "release: v{{version}}"
	git tag -a -m "version {{version}}" "v{{version}}"

