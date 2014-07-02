#!/bin/bash
set -e

##
# Example script for generating a Dash docset from your project's rustdocs

# Required: path to rustdocs for your crates.
export DOCS_PATH="/path/to/your/project/doc"

# Required: the name of your docset. For example, "Piston". Used for CFBundleName and
# the .docset directory name.
export DOCSET_NAME="My Cool Crates"

# Required: a hopefully unique value used for CFBundleIdentifier.
export DOCSET_ID="mycrates"

# Optional: defaults to 'rustlibs'. Used for DocSetPlatformFamily. Seems to also be the
# default search keyword. If your docset includes many crates (like Piston's might),
# probably a good idea to set this.
# export DOCSET_GROUP="mycrates"

bundle exec rake clean docset
