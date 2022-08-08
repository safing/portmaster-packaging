#!/bin/bash
source tests/common.sh

if [ -d ./dist ]; then
    error 'Run `make gen-pkgbuild` first'
    exit 1
fi

if [ -z $GITHUB_COMMIT_MESSAGE ]; then
    error "No commit message defined in GITHUB_COMMIT_MESSAGE"
    exit 1
fi

set -e

target="/tmp/portmaster-stub-bin"

group "Cloning AUR repository to /tmp/portmaster-stub-bin"
    git init "${target}"
    # git clone ssh://aur@aur.archlinux.org/portmaster-stub-bin.git "${target}"
endgroup

group "Copying files to AUR repository"
    for file in PKGBUILD arch.install portmaster.desktop portmaster_notifier.desktop portmaster_logo.png portmaster.service
    do
        info "Copying ${file}"
        cp "${file}" "${target}"
    done
endgroup

group "Generating .SRCINFO"
    docker run --rm -v "$(pwd):/workspace" -w /workspace -u 1000 archlinux:latest makepkg --printsrcinfo > "${target}/.SRCINFO"
endgroup

cd "${target}"
if [[ `git status --porcelain` ]]; then
    group "Commiting and pushing to AUR"
        git add .
        git commit -m "${GITHUB_COMMIT_MESSAGE}"
        git push
    endgroup
else
   info "No changes detected, aborting" 
fi