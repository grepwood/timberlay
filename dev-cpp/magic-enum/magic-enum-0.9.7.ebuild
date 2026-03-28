# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

SRC_URI="https://github.com/Neargye/magic_enum/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Static reflection for enums (to string, from string, iteration) for modern C++, work with any enum type without any macro or boilerplate code"
HOMEPAGE="https://github.com/Neargye/magic_enum"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="dev-build/cmake"

S="${WORKDIR}/magic_enum-${PV}"

src_configure() {
	mycmakeargs+=(
		-DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
		-DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
	)
	cmake_src_configure
}
