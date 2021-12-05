#!/bin/bash -e
# ----------------------------------------------------------------------------
# Check the git-lfs handling.
#
# Copyright (c) 2021 by Clemens Rabe <clemens.rabe@clemensrabe.de>
# All rights reserved.
# This file is part of gitcache (https://github.com/seeraven/gitcache)
# and is released under the "BSD 3-Clause License". Please see the LICENSE file
# that is included as part of this package.
# ----------------------------------------------------------------------------


EXPECTED_OUTPUT_PREFIX=$(basename $0 .sh)
source $TEST_BASE_DIR/helpers/output_helpers.sh


# -----------------------------------------------------------------------------
# Tests of git lfs fetch:
# -----------------------------------------------------------------------------

REPO=https://github.com/seeraven/lfs-example.git

# Initial clone ignoring git-lfs excluded entries
capture_output_success clone git -C ${TMP_WORKDIR} clone ${REPO}

if grep -q "oid sha256" ${TMP_WORKDIR}/lfs-example/included/first.png; then
    echo "ERROR: Included git-lfs file should be fetched during clone!"
    exit 10
fi

if ! grep -q "oid sha256" ${TMP_WORKDIR}/lfs-example/excluded/first.png; then
    echo "ERROR: Excluded git-lfs file should not be fetched!"
    exit 10
fi

# Fetching commands with no mirror update
capture_output_success lfs_fetch1 git -C ${TMP_WORKDIR}/lfs-example lfs fetch
capture_output_success lfs_fetch2 git -C ${TMP_WORKDIR}/lfs-example lfs fetch origin

# Fetching commands with mirror update
capture_output_success lfs_fetch3 git -C ${TMP_WORKDIR}/lfs-example lfs fetch --include '*' --exclude ''
capture_output_success lfs_fetch4 git -C ${TMP_WORKDIR}/lfs-example lfs fetch origin --include '*' --exclude ''

# Pulling excluded entries
if ! grep -q "oid sha256" ${TMP_WORKDIR}/lfs-example/excluded/first.png; then
    echo "ERROR: Excluded git-lfs file should not be pulled yet!"
    exit 10
fi

capture_output_success lfs_pull git -C ${TMP_WORKDIR}/lfs-example lfs pull --include '*' --exclude ''

if grep -q "oid sha256" ${TMP_WORKDIR}/lfs-example/excluded/first.png; then
    echo "ERROR: Included git-lfs file should be pulled during git lfs pull!"
    exit 10
fi


# -----------------------------------------------------------------------------
# Tests of git lfs pull:
# -----------------------------------------------------------------------------

capture_output_success delete_via_gitcache -d ${REPO}

capture_output_success clone2 git -C ${TMP_WORKDIR} clone ${REPO} lfs-example2

if ! grep -q "oid sha256" ${TMP_WORKDIR}/lfs-example2/excluded/first.png; then
    echo "ERROR: Excluded git-lfs file should not be pulled yet!"
    exit 10
fi

capture_output_success pull   git -C ${TMP_WORKDIR}/lfs-example2 lfs pull --include '*' --exclude ''

if grep -q "oid sha256" ${TMP_WORKDIR}/lfs-example2/excluded/first.png; then
    echo "ERROR: Included git-lfs file should be pulled during git lfs pull!"
    exit 10
fi