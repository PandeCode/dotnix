#!/usr/bin/env bash

url=$1

browserVersion=$(echo ':p (lib.versions.major pkgs.ungoogled-chromium.version)' | nix repl --expr 'import <nixpkgs>{}' 2>/dev/null | tr -d '\n')

id=$(echo "$url" | grep -Po '/\K\w+$')
name=$(echo "$url" | grep -Po 'detail/\K[^/]+')
version=$(curl -s "$url" |
	grep -Po 'Version</div><div class="\w*?">\K[^<]+')

sha256=$(nix-prefetch-url --name "$id.crx" "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc")

echo "
$name = {
	id = \"$id\";
	sha256 = \"sha256:$sha256\";
	version = \"$version\";
};
"
