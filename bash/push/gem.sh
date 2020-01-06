#!/usr/bin/env bash

set -eu

cd "$(dirname "${0}")"

cd ../..

if [[ -z ${1-} ]]
then
  echo "Не указан путь к скомпилированному гему" 1>&2;
  exit 0
fi

gem push $1
