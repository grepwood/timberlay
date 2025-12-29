# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://github.com/bshoshany/thread-pool/archive/refs/tags/v${PV}.tar.gz -> bs-thread-pool-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Fast, lightweight, modern, and easy-to-use C++17 / C++20 / C++23 thread pool library"
HOMEPAGE="https://github.com/bshoshany/thread-pool"

LICENSE="MIT"
SLOT="0"
IUSE="cxx20"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/thread-pool-${PV}"

src_install() {
	insinto /usr/include
	doins include/BS_thread_pool.hpp
	if use cxx20; then
		insinto /usr/include/modules
		doins modules/BS.thread_pool.cppm
	fi
}
