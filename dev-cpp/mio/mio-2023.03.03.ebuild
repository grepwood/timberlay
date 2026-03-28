# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Derived from https://github.com/microsoft/vcpkg/blob/e2bf8781641f91d1546d79190e89d31ab3e98908/ports/mio/portfile.cmake#L5
GIT_COMMIT="8b6b7d878c89e81614d05edca7936de41ccdd2da"

SRC_URI="https://github.com/vimpunk/mio/archive/${GIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Cross-platform C++11 header-only library for memory mapped file IO"
HOMEPAGE="https://github.com/vimpunk/mio"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="dev-build/cmake"

S="${WORKDIR}/mio-${GIT_COMMIT}"

src_configure() {
	mycmakeargs+=(
		-Dmio.tests=OFF
	)
	cmake_src_configure
}
