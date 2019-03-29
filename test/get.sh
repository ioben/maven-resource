#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_get_artifact() {
  local src=$(mktemp -d $TMPDIR/check-src.XXXXXX)

  local repository=$src/remote-repository
  mkdir -p $repository

  local url=file://$repository
  local artifact=ci.concourse.maven:maven-resource:jar:standalone

  local version=$(deploy_artifact $url $artifact '1.0.0-rc.1' $src)

  get_artifact $url $artifact $version $src false | \
  jq -e \
  --arg version $version \
  '
    .version == {version: $version}
  '

  # Should have jar
  test -f $src/*$version*.jar
}

it_can_skip_download_when_getting_artifact() {
  local src=$(mktemp -d $TMPDIR/check-src.XXXXXX)

  local repository=$src/remote-repository
  mkdir -p $repository

  local url=file://$repository
  local artifact=ci.concourse.maven:maven-resource:jar:standalone

  local version=$(deploy_artifact $url $artifact '1.0.0' $src)

  get_artifact $url $artifact $version $src false

  # Shouldn't have jar
  test -f $src/*$version*.jar || exit 1

  if [ $(cat version) != $version ]; then exit 1; fi
}

it_provides_a_version_file_when_getting_artifact() {

  local src=$(mktemp -d $TMPDIR/check-src.XXXXXX)

  local repository=$src/remote-repository
  mkdir -p $repository

  local url=file://$repository
  local artifact=ci.concourse.maven:maven-resource:jar:standalone

  local version=$(deploy_artifact $url $artifact '1.0.0' $src)

  get_artifact $url $artifact $version $src false

  if [ $(cat version) != $version ]; then exit 1; fi
}

run it_provides_a_version_file_when_getting_artifact
run it_can_skip_download_when_getting_artifact
run it_can_get_artifact
