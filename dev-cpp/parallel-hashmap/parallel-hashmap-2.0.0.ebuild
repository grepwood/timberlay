# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

SRC_URI="https://github.com/greg7mdp/parallel-hashmap/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="A family of header-only, very fast and memory-friendly hashmap and btree containers."
HOMEPAGE="https://github.com/greg7mdp/parallel-hashmap"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="dev-build/cmake"

S="${WORKDIR}/${PN}-${PV}"

src_configure() {
	mycmakeargs+=(
		-DPHMAP_BUILD_TESTS=OFF
		-DPHMAP_BUILD_EXAMPLES=OFF
	)
	cmake_src_configure
}
