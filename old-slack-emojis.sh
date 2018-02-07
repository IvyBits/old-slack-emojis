#!/usr/bin/env bash

## Functions

error() {
	echo "$(tput setaf 124)$(tput bold)✘ $1$(tput sgr0)"
	exit 1
}


## User input

for p in "$@"; do
	if [ "$p" = "-u" ]; then
		UNINSTALL="$p"
	else
		SLACK_DIR="$p"
	fi
done


## Platform settings

if [ "$(uname)" == "Darwin" ]; then
	# macOS
	COMMON_SLACK_LOCATIONS=(
		"/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static"
	)
else
	# Linux
	COMMON_SLACK_LOCATIONS=(
		"/usr/lib/slack/resources/app.asar.unpacked/src/static"
		"/usr/local/lib/slack/resources/app.asar.unpacked/src/static"
		"/opt/slack/resources/app.asar.unpacked/src/static"
	)
fi


## Try to find slack if not provided by user

if [ -z "$SLACK_DIR" ]; then
	for loc in "${COMMON_SLACK_LOCATIONS[@]}"; do
		if [ -e "$loc" ]; then
			SLACK_DIR="$loc"
			break
		fi
	done
fi


## Check so installation exists and is writable

if [ -z "$SLACK_DIR" ]; then
	error "Cannot find Slack installation."
elif [ ! -e "$SLACK_DIR" ]; then
	error "Cannot find Slack installation at: $SLACK_DIR"
elif [ ! -e "$SLACK_DIR/ssb-interop.js" ]; then
	error "Cannot find Slack file: $SLACK_DIR/ssb-interop.js"
elif [ ! -w "$SLACK_DIR/ssb-interop.js" ]; then
	error "Cannot write to Slack file: $SLACK_DIR/ssb-interop.js"
fi

echo "Using Slack installation at: $SLACK_DIR"


## Remove previous version

if [ -e "$SLACK_DIR/old-slack-emojis.js" ]; then
	rm $SLACK_DIR/old-slack-emojis.js
fi


## Restore previous injections

restore_file() {
	# Test so file been injected. If not, assume it's more recent than backup
	if grep -q "old-slack-emojis" $1; then
		if [ -e "$1.osebak" ]; then
			mv -f $1.osebak $1
		else
			error "Cannot restore from backup. Missing file: $1.osebak"
		fi
	elif [ -e "$1.osebak" ]; then
		rm $1.osebak
	fi
}

restore_file $SLACK_DIR/ssb-interop.js


## Are we uninstalling?

if [ -n "$UNINSTALL" ]; then
	echo "$(tput setaf 64)Old Slack emojis have been uninstalled. Please restart the Slack client.$(tput sgr0)"
	exit 0
fi


## Write main script

cat <<EOF > $SLACK_DIR/old-slack-emojis.js
var emojiStyle = document.createElement('style');
emojiStyle.innerText = ".emoji-sizer[style*='sheet_google_64_indexed_256.png'], .emoji[style*='sheet_google_64_indexed_256.png'] { background-image: url('https://github.com/IvyBits/old-slack-emojis/raw/master/slack_2016_apple_sprite_64.png') !important; }";
document.head.appendChild(emojiStyle);
EOF


## Inject code loader

inject_loader() {
	# Check so not already injected
	if grep -q "old-slack-emojis" $1; then
		error "File already injected: $1"
	fi

	# Make backup
	if [ ! -e "$1.osebak" ]; then
		cp $1 $1.osebak
	else
		error "Backup already exists: $1.osebak"
	fi

	# Inject loader code
	echo "" >> $1
	echo "// ** old-slack-emojis ** https://github.com/IvyBits/old-slack-emojis" >> $1
	echo "var scriptPath = path.join(__dirname, 'old-slack-emojis.js').replace('app.asar', 'app.asar.unpacked');" >> $1
	echo "require('fs').readFile(scriptPath, 'utf8', (e, r) => { if (e) { throw e; } else { eval(r); } });" >> $1
}

inject_loader $SLACK_DIR/ssb-interop.js


## We're done

echo "$(tput setaf 64)Old Slack emojis have been installed. Please restart the Slack client.$(tput sgr0)"

