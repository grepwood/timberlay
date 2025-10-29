# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Quake data."
HOMEPAGE="https://web.archive.org/web/19971017041403/http://www.idsoftware.com/quake/index.html"
SRC_URI="
	!registered? (
		https://archive.org/download/msdos_Quake106_shareware/msdos_Quake106_shareware.zip
	)
"
LICENSE="
	registered? (
		Quake
	)
	!registered? (
		freeware
	)
"
RESTRICT="bindist mirror"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"
SLOT="0"
IUSE="-registered"

REQUIRED_USE=""
RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	registered? (
		app-cdr/bchunk
		app-cdr/cdrtools
		app-arch/lha
		sys-apps/findutils
		sys-apps/sed
		app-alternatives/awk
		media-video/ffmpeg
	)
	!registered? ( app-arch/unzip )
	sys-apps/coreutils
"

DISTFILES=('QUAKE106.BIN' 'QUAKE106.CUE')
DISTFILES_SHA256=('484390c7824f728ddb0b25404666a142a7b63ce3ff5bbd0b680472f5b5e95625' 'e5e58736d62366082e048f47198ad54c93f9d09a973ba18982a8ba511fc6eb0a')

src_unpack() {
	if use registered; then
		if [ ! -f "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.BIN" ] || [ ! -f "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.CUE" ]; then
			eerror "Please provide the following files into ${PORTAGE_ACTUAL_DISTDIR}:\n\t- QUAKE106.BIN\n\t- QUAKE106.CUE" && die
		fi

		local own_checksum=''
		if [ -f "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.BIN" ]; then
			own_checksum=$(sha256sum "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.BIN" | awk '{print $1}')
			if [ "${own_checksum}" != "${DISTFILES_SHA256[0]}" ]; then
				die "QUAKE106.BIN has wrong checksum"
			fi
		fi
		if [ -f "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.CUE" ]; then
			own_checksum=$(sha256sum "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.CUE" | awk '{print $1}')
			if [ "${own_checksum}" != "${DISTFILES_SHA256[1]}" ]; then
				die "QUAKE106.CUE has wrong checksum"
			fi
		fi

		mkdir id1
		bchunk -w "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.BIN" "${PORTAGE_ACTUAL_DISTDIR}/QUAKE106.CUE" quake
		LANG=C isoinfo -i quake01.iso -x '/RESOURCE.1;1' > resource.exe
		lha x resource.exe ID1/PAK0.PAK ID1/PAK1.PAK
		rm resource.exe quake01.iso
		mv ID1/PAK0.PAK id1/pak0.pak
		mv ID1/PAK1.PAK id1/pak1.pak
		mkdir -p id1/sound/cdtracks
		local real_track_number=''
		for i in $(find . -type f -name 'quake*.wav' -exec basename {} \;); do
			real_track_number=$(echo ${i} | sed -E 's/^quake0?([0-9]+)\.wav$/\1/' | awk '{ c = $1 - 1; if ( c < 10 ) { print "0"c } else { print c } }')
			ffmpeg -i ${i} -compression_level 12 id1/sound/cdtracks/track${real_track_number}.flac
			rm ${i}
		done
	else
		mkdir id1
		unzip -j "${DISTDIR}/msdos_Quake106_shareware.zip" ID1/PAK0.PAK
		mv PAK0.PAK id1/pak0.pak
	fi
	mkdir "${S}"
	mv id1 "${S}"
}

src_install() {
	insinto /usr/share/quake1
	doins -r id1
}
