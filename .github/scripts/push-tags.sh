#!/bin/bash
set -euo pipefail

git_sha1=$(git rev-parse HEAD)

check_for_tag() {
  curl \
    -s -o /dev/null \
    -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/BlazerodJS/v8-prebuilt/git/ref/tags/$1"
}

create_tag() {
  curl -s -X POST https://api.github.com/repos/BlazerodJS/v8-prebuilt/git/refs \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d @- <<EOF
{
  "ref": "refs/tags/$1",
  "sha": "$commit"
}
EOF
}

while read line; do
  if [[ "$line" == "" ]] || [[ "${line:0:1}" == "#" ]]; then
    continue
  fi

  tag="v$line"

  resp="$(check_for_tag "$tag")"

  if [[ "$resp" == "404" ]]; then
    echo "Creating new tag $tag"
    create_tag "$tag"
  else
    echo "Tag $tag already exists"
  fi
done < v8-versions
