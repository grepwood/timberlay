# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Adventure game about furries searching for a lost artifact"
HOMEPAGE="https://wyrmkeep.com/ite/"
SRC_URI="http://s3.amazonaws.com/wyrmkeep.com/downloads/InheritTheEarthTrial.tar.gz"
LICENSE="proprietary"
RESTRICT="bindist mirror"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"
SLOT="0"

REQUIRED_USE=""
RDEPEND="games-engines/scummvm"
DEPEND="${RDEPEND}"
BDEPEND="
	app-cdr/bchunk
	app-cdr/cdrtools
	sys-apps/coreutils
"

DISTFILES=('ite.BIN' 'ite.cue')
DISTFILES_SHA256=('b3d49e95aa9176c6d9a1c600a3b895736df83b97917b31f1255dd7996face950' 'a70698939fabf3ba28a774c792d16314593e6e072cefb67392cf05d553731b59')
GAME_FILES=(
	'GAME/DRIVERS/INSTR.AD'
	'GAME/DRIVERS/INSTR.OPL'
	'GAME/ITE.RSC'
	'GAME/SCRIPTS.RSC'
	'GAME/SOUNDS.RSC'
	'GAME/VOICES.RSC'
)

src_unpack() {
	if [ ! -f "${PORTAGE_ACTUAL_DISTDIR}/${DISTFILES[0]}" ] || [ ! -f "${PORTAGE_ACTUAL_DISTDIR}/${DISTFILES[1]}" ]; then
		die "Please provide the following files into ${PORTAGE_ACTUAL_DISTDIR}:\n\t- ${DISTFILES[0]}\n\t- ${DISTFILES[1]}"
	fi

	local own_checksum=''
	for((counter = 0; counter < 2; ++counter)); do
		if [ -f "${PORTAGE_ACTUAL_DISTDIR}/${DISTFILES[${counter}]}" ]; then
			own_checksum=$(sha256sum "${PORTAGE_ACTUAL_DISTDIR}/${DISTFILES[${counter}]}" | awk '{print $1}')
			if [ "${own_checksum}" != "${DISTFILES_SHA256[${counter}]}" ]; then
				die "${DISTFILES[${counter}]} has wrong checksum"
			fi
		fi
	done
	mkdir "${PN}-${PV}"
	cd "${PN}-${PV}"

	bchunk "${PORTAGE_ACTUAL_DISTDIR}/${DISTFILES[0]}" "${PORTAGE_ACTUAL_DISTDIR}/${DISTFILES[1]}" track
	rm -f track0*.cdr
	mkdir -p GAME/DRIVERS
	for i in "${GAME_FILES[@]}"; do
		LANG=C isoinfo -i track01.iso -x "/${i};1" > "${i}"
	done
	rm -f track01.iso

	tar --strip-component 1 -xf "${DISTDIR}/InheritTheEarthTrial.tar.gz" InheritTheEarth/ite_icon_256.png
	mv ite_icon_256.png com.wyrmkeep.ite.png
}

src_install() {
	insinto '/usr/share/inherit-the-earth-quest-for-the-orb'
	doins -r GAME/DRIVERS
	doins GAME/ITE.RSC
	doins GAME/SCRIPTS.RSC
	doins GAME/SOUNDS.RSC
	doins GAME/VOICES.RSC
	doins "${FILESDIR}/ite.ini"
	insinto /usr/share/icons/hicolor/256x256/apps
	doins com.wyrmkeep.ite.png
	insinto /usr/share/applications
	doins "${FILESDIR}/com.wyrmkeep.ite.desktop"
}
