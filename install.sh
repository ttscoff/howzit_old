#!/bin/bash
HOWZIT='/usr/local/bin/howzit'
curl -SsL -o $HOWZIT 'https://raw.githubusercontent.com/ttscoff/howzit/main/howzit'
chmod a+x $HOWZIT
echo "Installation complete, run $(basename $HOWZIT) to test."
