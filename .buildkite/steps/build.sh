#!/bin/bash
set -x
set -euo pipefail

echo "--- build recipe"
.buildkite/steps/recipe.sh
echo "--- create image"
.buildkite/steps/image.sh
echo "--- deliver :docker: and :singularity:"
.buildkite/steps/push.sh
