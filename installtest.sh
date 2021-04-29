#!/bin/bash
curl -o /usr/local/bin/howzit.test 'https://raw.githubusercontent.com/ttscoff/howzit/main/howzit'
chmod a+x /usr/local/bin/howzit.test
echo 'Installation complete, run `howzit` to test.'
