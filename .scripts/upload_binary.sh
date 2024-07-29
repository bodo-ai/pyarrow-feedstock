#!/usr/bin/env bash
set -exo pipefail

echo "********** Publishing to Artifactory **********"
USERNAME=`cat /home/secrets/secret_file | grep artifactory.ci.username | cut -f 2 -d' '`
TOKEN=`cat /home/secrets/secret_file | grep artifactory.ci.token | cut -f 2 -d' '`
ANACONDA_TOKEN=`cat /home/secrets/secret_file | grep anaconda.org.token | cut -f 2 -d' '`

CHANNEL_NAME="bodo.ai-platform"

for package in `ls ${FEEDSTOCK_ROOT}/build_artifacts/linux-64/*.conda`; do
    package_name=`basename $package`
    echo "Package Name: $package_name"

    curl -u${USERNAME}:${TOKEN} -T $package "https://bodo.jfrog.io/artifactory/${CHANNEL_NAME}/linux-64/$package_name"
    anaconda -t $ANACONDA_TOKEN upload -u bodo.ai -c bodo.ai $package --label main --force
done

# Reindex Conda
curl -s -X POST "https://$USERNAME:$TOKEN@bodo.jfrog.io/artifactory/api/conda/$CHANNEL_NAME/reindex?async=0"
