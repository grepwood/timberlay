# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://github.com/tplgy/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Header-only C++11 library to encode/decode base64, base64url, base32, base32hex and hex (a.k.a. base16) as specified in RFC 4648, plus Crockford's base32. MIT licensed with consistent, flexible API."
HOMEPAGE=""

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}-${PV}"

src_install() {
	insinto /usr/include
	doins -r cppcodec
}
