#!/bin/bash

set -e
set -x

VERSION=$(cat version/number)
RELEASE_ROOT="$PWD/github-release-info"
RELEASE_NAME=${bosh_release_name}

cp -r ./git-snort-boshrelease/. boshrelease-output

pushd boshrelease-output

# BOSH release details
rm -rf .dev_builds dev_releases
cat > config/private.yml <<EOF
---
blobstore:
  provider: s3
  options:
    access_key_id: $S3_ACCESS_KEY_ID
    secret_access_key: $S3_SECRET_ACCESS_KEY
EOF

# work-around Go BOSH CLI trying to rename blobs downloaded into ~/.root/tmp
# into release dir, which is invalid cross-device link
export HOME=$PWD
bosh sync-blobs
bosh -n create-release --final --force --tarball=${RELEASE_ROOT}/${RELEASE_NAME}-$VERSION.tgz --name $RELEASE_NAME --version $VERSION

# GIT!
if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "ci@example.com"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "CI Bot"
fi

git add releases .final_builds
git commit -m"New release of $RELEASE_NAME"

RELEASE_SHA1=$(sha1sum ${RELEASE_ROOT}/${RELEASE_NAME}-$VERSION.tgz |awk '{print $1}')

# prep details for github release
echo "v${VERSION}"                 > ${RELEASE_ROOT}/tag
echo "${RELEASE_NAME} v${VERSION}" > ${RELEASE_ROOT}/name
cat > ${RELEASE_ROOT}/body         << EOF
## Manifest
\`\`\`
releases:
- name: $RELEASE_NAME
  version: $VERSION
  sha1: $RELEASE_SHA1
  url: https://github.com/${github_username}/${RELEASE_NAME}-boshrelease/releases/download/v${VERSION}/${RELEASE_NAME}-${VERSION}.tgz
\`\`\`

EOF

  echo ""
popd