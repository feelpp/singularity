#!/bin/bash
set -x
set -euo pipefail

.buildkite/steps/recipe.sh
.buildkite/steps/image.sh
