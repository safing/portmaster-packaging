#!/bin/bash
source tests/common.sh

if [ ! -e ./PKGBUILD ]; then
    error 'Run `make gen-pkgbuild` first'
    exit 1
fi

if [ -z $GITHUB_COMMIT_MESSAGE ]; then
    error "No commit message defined in GITHUB_COMMIT_MESSAGE"
    exit 1
fi

set -e

group "Configuring git"
    git config user.name "Safing"
    git config user.email "noc@safing.io"
endgroup

target="/tmp/portmaster-stub-bin"

group "Cloning AUR repository to /tmp/portmaster-stub-bin"
    git clone ssh://aur@aur.archlinux.org/portmaster-stub-bin.git "${target}"
endgroup

group "Copying files to AUR repository"
    for file in PKGBUILD arch.install portmaster.desktop portmaster_notifier.desktop portmaster_logo.png portmaster.service
    do
        info "Copying ${file}"
        cp "${file}" "${target}"
    done
endgroup

cd "${target}"
if [[ `git status --porcelain` ]]; then
    # we only generate a new .SRCINFO file if we have actual changes to the AUR repo
    # that we want to publish.
    group "Generating .SRCINFO"
        docker run --rm -v "$(pwd):/workspace" -w /workspace -u 1000 archlinux:latest makepkg --printsrcinfo > "${target}/.SRCINFO"
    endgroup

    group "Commiting and pushing to AUR"
        git add .
        git commit --author "Safing <noc@safing.io>" -m "${GITHUB_COMMIT_MESSAGE}" --no-gpg-sign
        git log
        git push
    endgroup
else
   info "No changes detected, aborting" 
fi