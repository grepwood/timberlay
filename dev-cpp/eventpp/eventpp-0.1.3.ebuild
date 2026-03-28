# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

SRC_URI="https://github.com/wqking/eventpp/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Event Dispatcher and callback list for C++"
HOMEPAGE="https://github.com/wqking/eventpp"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="dev-build/cmake"

S="${WORKDIR}/eventpp-${PV}"
