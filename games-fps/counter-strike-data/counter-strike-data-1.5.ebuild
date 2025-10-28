# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://archive.org/download/counter-strike-1.5/csv15full.exe"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Game data files needed to play the freeware releases of Counter-Strike."
HOMEPAGE="https://archive.org/details/counter-strike-1.5"

LICENSE="freeware"
RESTRICT="bindist mirror"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	app-arch/rewise
"

S="${WORKDIR}/MAINDIR"

src_unpack() {
	rewise -x . -f 'MAINDIR/*' "${DISTDIR}/csv15full.exe"
}

src_install() {
	insinto /usr/share/games
	doins -r cstrike
}
