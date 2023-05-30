
#
# We emulate a simple ArchLinux makepkg here in order to build a 
# archive that contains everything we need for our curl|bash
# installer.
#

{{- $nfpm := (datasource "nfpm") }}

pkgdir=dist/installer-assets-{{ $nfpm.version }}
srcdir=$(pwd)

set -ex

mkdir -p "${pkgdir}"

# Copy assets to our installer directory
assets_to_copy=(
    'portmaster.desktop'
    'portmaster_notifier.desktop'
    'icons'
    'portmaster.service'
)

for file in "${assets_to_copy[@]}"
do
    cp -rv "${file}" "${pkgdir}"
done

# Copy the arch.install file into our assets
cp archive.install "${pkgdir}/.INSTALL.sh"

# Fix file permissions for archive.
(
    cd ${pkgdir} &&
    find . -type d -exec chmod 0755 {} \; &&
    find . -type f -exec chmod 0644 {} \; &&
    find . -type f -name "*.sh" -exec chmod 0755 {} \;
)

# Create filelist to support easy uninstallation
# like doing a `cat /opt/safing/portmaster/.installed-files | sudo xargs rm`
( cd ${pkgdir} && find . -type f ) > ${pkgdir}/.installed-files

# Create archive
( cd ${pkgdir} && tar cfz ../installer-assets-{{ $nfpm.version }}.tar.gz . )

