# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

SRC_URI="https://codeberg.org/CYBERDEV/REWise/archive/v${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Extract files from Wise installers without executing them."
HOMEPAGE="https://codeberg.org/CYBERDEV/REWise"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug +man"

RDEPEND="
	sys-libs/zlib
	man? ( sys-apps/man-db )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/cmake
"

S="${WORKDIR}/${PN}"

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=()
	if use debug; then
		mycmakeargs+=( \
			-DCMAKE_C_FLAGS='-DREWISE_DEBUG' \
			-DCMAKE_BUILD_TYPE=Debug \
		)
	fi
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	if use man; then
		insinto /usr/share/man/man1
		doins rewise.1
	fi
	exeinto /usr/bin
	doexe ../${PN}_build/rewise
}
