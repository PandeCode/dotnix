# turns the unicode character database into rofi-emoji rows: character,
# block, category, name, old name. run as
#   awk -f unicode-rows.awk Blocks.txt all_emojis.txt UnicodeData.txt
# with LC_ALL=C so %c writes bytes. the row format is in rofi-emoji's
# README, "Custom database". field layouts:
# https://www.unicode.org/reports/tr44/#UnicodeData.txt
# https://www.unicode.org/reports/tr44/#General_Category_Values

BEGIN {
	split("Lu:letter Ll:letter Lt:letter Lm:letter Lo:letter " \
		"Mn:mark Mc:mark Me:mark Nd:digit Nl:number No:number " \
		"Pc:punctuation Pd:punctuation Ps:punctuation Pe:punctuation " \
		"Pi:punctuation Pf:punctuation Po:punctuation " \
		"Sm:math Sc:currency Sk:modifier So:symbol Zs:space Cf:format", pairs, " ")
	for (i in pairs) {
		split(pairs[i], kv, ":")
		category[kv[1]] = kv[2]
	}
}

# Blocks.txt: 0000..007F; Basic Latin
FILENAME ~ /Blocks/ && /^[0-9A-F]/ {
	split($0, f, /\.\.|; /)
	nblocks++
	bfirst[nblocks] = strtonum("0x" f[1])
	blast[nblocks] = strtonum("0x" f[2])
	bname[nblocks] = f[3]
	next
}

# characters that already have an emoji row keep only that one
FILENAME ~ /emoji/ {
	split($0, f, "\t")
	emoji[f[1]] = 1
	next
}

function utf8(cp) {
	if (cp < 0x80)
		return sprintf("%c", cp)
	if (cp < 0x800)
		return sprintf("%c%c", 0xC0 + int(cp / 64), 0x80 + cp % 64)
	if (cp < 0x10000)
		return sprintf("%c%c%c", 0xE0 + int(cp / 4096), 0x80 + int(cp / 64) % 64, 0x80 + cp % 64)
	return sprintf("%c%c%c%c", 0xF0 + int(cp / 262144), 0x80 + int(cp / 4096) % 64,
		0x80 + int(cp / 64) % 64, 0x80 + cp % 64)
}

# UnicodeData.txt is sorted, so the block only ever moves forward. names in
# <> are controls or the first and last of a range like the cjk ideographs
FILENAME ~ /UnicodeData/ {
	split($0, f, ";")
	if (!(f[3] in category) || f[2] ~ /^</)
		next
	cp = strtonum("0x" f[1])
	while (b < nblocks && cp > blast[b])
		b++
	ch = utf8(cp)
	if (ch in emoji)
		next
	old = f[11] == "" || f[11] == f[2] ? "" : tolower(f[11])
	row = sprintf("%s\t%s\t%s\t%s\t%s", ch, bname[b], category[f[3]], tolower(f[2]), old)
	# rofi lists matches in file order, and a search for "rightwards arrow"
	# should not open on a combining mark
	if (category[f[3]] == "mark")
		marks[++nmarks] = row
	else
		print row
}

END {
	for (i = 1; i <= nmarks; i++)
		print marks[i]
}
