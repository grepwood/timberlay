# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://github.com/adamyaxley/Obfuscate/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Guaranteed compile-time string literal obfuscation header-only library for C++14"
HOMEPAGE="https://github.com/adamyaxley/Obfuscate"

LICENSE="Unlicense"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/Obfuscate-${PV}"

src_install() {
	insinto /usr/include
	doins obfuscate.h
}
