#!/usr/bin/env bash

set -eu

cd "$(dirname "${0}")"

cd ../..

gem build nested_array
