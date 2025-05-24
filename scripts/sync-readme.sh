#! /usr/bin/bash
# shellcheck source=/dev/null
source .env
node -e "const fs = require('fs'); console.log(fs.readFileSync('README.md').toString().replace(/<!--BEGIN CREDITS-->((.|\\n)*)<\!--END CREDITS-->/m, '<details><summary>Credits</summary>\\n\\n' + fs.readFileSync('CREDITS.md') + '</details>\\n'))" |
    jo body=@/dev/stdin |
    curl -A "xtex-mp-pack scripts (HsMwyVxf)" \
        -H "Authorization: $MODRINTH_TOKEN" \
        -H "Content-Type: application/json" \
        -X PATCH -d "$(cat /dev/stdin)" https://api.modrinth.com/v2/project/HsMwyVxf && echo "Modrinth README updated"
