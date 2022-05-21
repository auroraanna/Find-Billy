#!/usr/bin/env just --justfile
alpine_deps:='git xmlstarlet'
nixpkgs_deps:='git xmlstarlet'
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
	head -1 page.codeberg.papojari.Find_Billy.appdata.xml > page.codeberg.papojari.Find_Billy.appdata.xml.tmp
	xmlstarlet edit --omit-decl -s '//releases' -t elem -n "release" -s '//releases/release[last()]' -t elem -n "url" -v "https://codeberg.org/papojari/Find-Billy/releases/tag/v{{version}}" -s '//releases/release[last()]' -t attr -n "version" -v "v{{version}}" -s '//releases/release[last()]' -t attr -n "date" -v "$(date -u +'%Y-%m-%d')" page.codeberg.papojari.Find_Billy.appdata.xml >> page.codeberg.papojari.Find_Billy.appdata.xml.tmp
	mv page.codeberg.papojari.Find_Billy.appdata.xml.tmp page.codeberg.papojari.Find_Billy.appdata.xml
	# Git add
	git add page.codeberg.papojari.Find_Billy.appdata.xml

release: changelog appdata-releases-update
	#!/bin/sh
	set -euxo pipefail
	git commit -m "release: v{{version}}"
	git tag -a -m "version {{version}}" "v{{version}}"

