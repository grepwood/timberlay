# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

GIT_COMMIT='6276296590bc5c338b4fd212bcfdfc7eaea65a15'
SRC_URI="https://github.com/piskelapp/piskel/archive/${GIT_COMMIT}.tar.gz"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Piskel is a free editor for animated sprites & pixel art"
HOMEPAGE="https://www.piskelapp.com"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RESTRICT="network-sandbox"

RDEPEND="
	sys-libs/glibc
	sys-devel/gcc
	media-libs/alsa-lib
	app-accessibility/at-spi2-core
	x11-libs/cairo
	net-print/cups
	sys-apps/dbus[X]
	dev-libs/expat
	media-libs/mesa
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	x11-libs/pango
	sys-apps/systemd-utils
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
"
DEPEND="${RDEPEND}"
BDEPEND="
	net-libs/nodejs[npm]
	sys-apps/sed
"

S="${WORKDIR}/piskel-${GIT_COMMIT}"

src_prepare() {
	default
	eapply "${FILESDIR}/build-for-gentoo.patch"
}

src_compile() {
	npm ci --no-audit --no-fund --loglevel=error --no-progress
	npx grunt build nwjs:gentoo --verbose
	sed -i 's?\(^Icon=\).*?\1/usr/share/icons/hicolor/64x64/piskel.png?' out/piskel.desktop
	echo 'Keywords=GIMP;graphic;design;illustration;painting;' >> out/piskel.desktop
	echo 'Exec=piskel' >> out/piskel.desktop
	echo 'Terminal=false' >> out/piskel.desktop
	echo 'Categories=Graphics;2DGraphics;' >> out/piskel.desktop
}

src_install() {
	insinto /opt/piskel
	newins out/credits.html credits.html
	newins out/icudtl.dat icudtl.dat
	newins out/nw_100_percent.pak nw_100_percent.pak
	newins out/nw_200_percent.pak nw_200_percent.pak
	newins out/resources.pak resources.pak
	newins out/v8_context_snapshot.bin v8_context_snapshot.bin
	doins -r out/locales
	doins -r out/package.nw
	doins -r out/swiftshader

	insinto /opt/piskel/lib
	doins out/lib/vk_swiftshader_icd.json

	exeinto /opt/piskel
	doexe out/piskel
	doexe out/chrome_crashpad_handler

	exeinto /opt/piskel/lib
	doexe out/lib/libEGL.so
	doexe out/lib/libffmpeg.so
	doexe out/lib/libGLESv2.so
	doexe out/lib/libnode.so
	doexe out/lib/libnw.so
	doexe out/lib/libvk_swiftshader.so
	doexe out/lib/libvulkan.so.1

	insinto /usr/share/applications
	newins out/piskel.desktop piskel.desktop

	insinto /usr/share/icons/hicolor/64x64
	newins src/logo.png piskel.png

	insinto /opt/piskel/package.nw/dest/prod
	doins dest/prod/index.html
	doins -r dest/prod/css
	doins -r dest/prod/img
	doins -r dest/prod/js
	doins -r dest/prod/piskelapp-partials

	dosym /opt/piskel/piskel /usr/bin/piskel
}
