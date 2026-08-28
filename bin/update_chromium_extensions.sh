#!/usr/bin/env bash

urls=(
	"privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
	"bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb"
	"dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh"
	"vimium/dbepggeogbaibhgnhhndojpepiihcmeb"
	"enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle"
	"mal-sync/kekjfbackdeiabghhcdklcdoekaanoel"
	"consumer-rights-wiki/bppajinomefndbbmopljhbdfefnefdha"
	"sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone"
	"spectorjs/denbgaamihkadbghdceggmchnflmhpmk"
	"desmodder-for-desmos/eclmfdfimjhkmjglgdldedokjaemjfjp"
	"cc++-devtools-support-dwa/pdcpmagijalfljmkmjngeonclgbbannb"
	"lighthouse/blipmdconlkpinefehnmjammfjpmpbjk"
)

echo '{'

for i in "${urls[@]}"; do
	prefetch_webstore.sh "https://chromewebstore.google.com/detail/$i"
done

echo '}'
