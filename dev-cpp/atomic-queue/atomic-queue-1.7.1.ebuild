# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://github.com/max0x7ba/atomic_queue/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="C++14 lock-free queue."
HOMEPAGE="https://github.com/max0x7ba/atomic_queue"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/atomic_queue-${PV}"

src_configure() {
	einfo "Configuration not required for header-only libraries"
}

src_compile() {
	einfo "Compilation not required for header-only libraries"
}

src_install() {
	doheader -r ${S}/include/atomic_queue
}
