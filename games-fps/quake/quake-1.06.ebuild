# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Quake."
HOMEPAGE="https://web.archive.org/web/19971017041403/http://www.idsoftware.com/quake/index.html"
SRC_URI=""
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"
SLOT="0"
IUSE="
	-registered
	-client
	-server
	-engine_fteqw
"

REQUIRED_USE="
	|| ( client server )
	|| (
		engine_fteqw
	)
"
RDEPEND="
	!registered? (
		games-fps/quake-data[-registered]
	)
	registered? (
		client? (
			games-fps/quake-data[registered]
		)
	)
	engine_fteqw? (
		client? (
			!registered? (
				games-fps/fteqw[client]
			)
			registered? (
				games-fps/fteqw[client,fte_plugins_ffmpeg]
			)
		)
		server? (
			games-fps/fteqw[server]
		)
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
"
S="${WORKDIR}"

src_install() {
	insinto /usr/share/applications
	if use registered; then
		if use engine_fteqw; then
			doins "${FILESDIR}/com.idsoftware.quake.desktop"
		fi
	else
		if use engine_fteqw; then
			doins "${FILESDIR}/com.idsoftware.quakedemo.desktop"
		fi
	fi
}
