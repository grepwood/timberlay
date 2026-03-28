# Copyright 2026 mva
# Distributed under the terms of the Public Domain or CC0 License

EAPI=8

DESCRIPTION="C++14 Dependency Injection Library"
HOMEPAGE="https://boost-ext.github.io/di/"
LICENSE="Boost-1.0"
SLOT="0"

MY_PN="${PN//boost-}"

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/boost-ext/${MY_PN}"
else
	SRC_URI="https://github.com/boost-ext/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~mips ~x86"
	S="${WORKDIR}/${MY_PN}-${MY_SHA:-${PV}}"
fi

DEPEND="dev-libs/boost"
RDEPEND="${DEPEND}"

src_install() {
	doheader -r ${S}/include/boost
	doheader -r ${S}/extension/include/boost
}
