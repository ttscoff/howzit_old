#!/bin/bash
echo 'Please enter a path to a directory in your $PATH'
read -p 'Where should howzit be installed? ' INSTALL_PATH

INSTALL_PATH=${INSTALL_PATH/#\~/$HOME}

if [[ -d "$INSTALL_PATH" ]]; then
	HOWZIT=${INSTALL_PATH%/}/howzit
else
	echo "Invalid path: ${INSTALL_PATH}"
	exit 1
fi

curl -SsL -o "$HOWZIT" 'https://raw.githubusercontent.com/ttscoff/howzit/main/howzit'
chmod a+x "$HOWZIT"
which howzit &>/dev/null
if [[ $? == 0 ]]; then
	echo "Installed to ${HOWZIT}, run $(basename "$HOWZIT") to test."
else
	echo "Installed to ${HOWZIT}, but it doesn't seem to be in your path. Ensure that \"$INSTALL_PATH\" is added to your shell's path environment."
fi
