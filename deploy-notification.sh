#!/usr/bin/env bash

# Usage ./slack-deploy-image <image> <environment>

function die() {
  echo "$1" 1>&2
  echo "" 1>&2
  echo "Usage: $0 <image> <environment>" 1>&2
  exit 1
}

[[ "$SLACK_DEV_WEBHOOK_URL" == "" ]] && die "SLACK_DEV_WEBHOOK_URL is not set"

image=$1
env=$2

[[ "${image}" == "" ]] && die "missing <image> argument"
[[ "${env}" == "" ]] && die "missing <environment> argument"

# without registry domain prefix
image_short="${image#*/}"
user=${CIRCLE_USERNAME:-$USER}

links=""
if [[ ! "$CIRCLE_BUILD_URL" == "" ]]; then
  links="(<${CIRCLE_BUILD_URL}|build>, <${CIRCLE_COMPARE_URL}|compare>)"
fi

emojis=""
if [[ $env == "prod" ]]; then
  emojis="🚀🚀🚀"
fi

text="${user} deployed ${image_short} to ${env} ${links} ${emojis}"

curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"${text}\", \"unfurl_links\": true }" \
  "${SLACK_DEV_WEBHOOK_URL}"
