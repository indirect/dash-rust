#!/bin/bash
set -ex

export DOCS_PATH="rust-nightly-x86_64-unknown-linux-gnu/doc"
export DOCSET_ID="rust"
export DOCSET_NAME="Rust Nightly"
export DOCSET_GROUP="rust"
export DOCSET_GUIDES=1

rm -f rust-nightly-x86_64-unknown-linux-gnu.tar.gz
rm -rf rust-nightly-x86_64-unknown-linux-gnu

curl -O http://static.rust-lang.org/dist/rust-nightly-x86_64-unknown-linux-gnu.tar.gz
tar -xzf rust-nightly-x86_64-unknown-linux-gnu.tar.gz

echo "Building nightly docset to \"$DOCSET_NAME\".docset"

bundle exec rake clean docset

set +ex
