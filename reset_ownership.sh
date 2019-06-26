#!/usr/bin/env bash

## Fetch all the source code for the boshrelease
#
fetch_source_codes() {
  pushd src > /dev/null
  echo -n "# fetching source code for snort and dependencies."
  echo -n "."
  wget -q "https://www.snort.org/downloads/archive/snort/snort-2.9.9.0.tar.gz"
  echo -n "."
  wget -q "https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz"
  echo -n "."
  wget -q "http://archive.ubuntu.com/ubuntu/pool/main/libd/libdumbnet/libdumbnet_1.12.orig.tar.gz" -O libdnet-1.12.tar.gz
  echo -n "."
  wget -q "http://archive.ubuntu.com/ubuntu/pool/main/libp/libpcap/libpcap_1.7.4.orig.tar.gz" -O libpcap-1.7.4.tar.gz
  echo -n "."
  wget -q "http://archive.ubuntu.com/ubuntu/pool/main/p/pcre3/pcre3_8.38.orig.tar.gz" -O pcre-8.38.tar.gz
  echo -n "."
  mkdir golang1.6
  wget -q "https://dl.google.com/go/go1.6.linux-amd64.tar.gz" -O golang1.6/go1.6.linux-amd64.tar.gz
  echo -n "."
  tar czf snort-conf.tar.gz -C ../ci/config snort-conf
  echo "."
  popd > /dev/null
}

# check the md5sums of the source files
#
check_source_codes_md5sums() {
pushd src > /dev/null
cat > /tmp/snort$$.md5sum <<-EOF
6a33d46fa4646b2ccfa7612b939677fa golang1.6/go1.6.linux-amd64.tar.gz
fd3012bf36710481d66b40ad046b231d snort-2.9.9.0.tar.gz
67b915f10c0cb2f7554686cdc9476946 daq-2.0.6.tar.gz
9253ef6de1b5e28e9c9a62b882e44cc9 libdnet-1.12.tar.gz
b2e13142bbaba857ab1c6894aedaf547 libpcap-1.7.4.tar.gz
8a353fe1450216b6655dfcf3561716d9 pcre-8.38.tar.gz
EOF

echo "# checking md5sums of each download against known, published md5sums."
echo ""
md5sum --strict -c /tmp/snort$$.md5sum
#rm -f /tmp/snort$$.md5sum
echo ""
popd > /dev/null
}

# add blobstore write credentials
#
add_blobstore_creds() {
cat > config/private.yml <<-EOF
---
blobstore:
  provider: s3
  options:
    access_key_id: xxxxxxxxxxxxxxxxx
    secret_access_key: xxxxxxxxxxxxxxxxxxxxx
EOF
}

## Finalise boshrelease instructions
#
final_instructions() {
  echo "*** TODO ***"
  echo ""
  echo "# tune config/private.yml"
  echo "# add source code as bosh blobs"
  echo ""
  echo "bosh add-blob src/pcre-8.38.tar.gz pcre-8.38.tar.gz"
  echo "bosh add-blob src/libpcap-1.7.4.tar.gz libpcap-1.7.4.tar.gz"
  echo "bosh add-blob src/libdnet-1.12.tar.gz libdnet-1.12.tar.gz"
  echo "bosh add-blob src/golang1.6/go1.6.linux-amd64.tar.gz golang1.6/go1.6.linux-amd64.tar.gz"
  echo "bosh add-blob src/daq-2.0.6.tar.gz daq-2.0.6.tar.gz"
  echo "bosh add-blob src/snort-2.9.9.0.tar.gz snort-2.9.9.0.tar.gz"
  echo "bosh add-blob src/snort-conf.tar.gz snort-conf.tar.gz"
  echo ""
  echo "# upload bosh blobs to blob store"
  echo ""
  echo "bosh upload-blobs"
  echo ""
  echo "# commit changes and push to GitHub"
  echo ""
  echo "git commit -m 'added in src code blobs' config/blobs.yml"
  echo "git push"
  echo
  echo "# setup Concourse pipelines"
  echo ""
}

## Script entry point
#
main() {
  fetch_source_codes
  check_source_codes_md5sums
  add_blobstore_creds
  final_instructions
}


main $@
