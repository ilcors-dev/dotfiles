#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title python dict to json
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }

# Documentation:
# @raycast.author ilcors-dev
# @raycast.authorURL https://raycast.com/ilcors-dev

python3 -c "import sys, json, ast; print(json.dumps(ast.literal_eval(\"$1\"), indent=2))"
