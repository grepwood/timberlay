# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
CMAKE_MAKEFILE_GENERATOR=emake

SRC_URI="https://github.com/opentibiabr/otclient/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~arm64 ~ppc64"

DESCRIPTION="An alternative tibia client for otserv written in C++20 and Lua, made with a modular system that uses lua scripts for ingame interface and functionality, making otclient flexible and easy to customize"
HOMEPAGE="https://github.com/opentibiabr/otclient"

LICENSE="MIT"
SLOT="0"
IUSE="debug debuglog lto sanitize +sound"

RDEPEND="
	dev-libs/protobuf
	dev-libs/zlib
	app-arch/xz-utils
	>=dev-libs/openssl-3.0.0
	dev-cpp/cpp-httplib
	dev-libs/inih
	x11-libs/libX11
	x11-libs/libXext
        sound? (
		media-libs/openal
		media-libs/libvorbis
		media-libs/libogg
	)
	sanitize? ( sys-devel/gcc[sanitize] )
	dev-cpp/nlohmann_json
	dev-cpp/abseil-cpp:=
	dev-libs/pugixml:=
	dev-libs/libfmt
	dev-libs/utfcpp
	dev-lang/luajit:=
	media-libs/glew
	dev-games/physfs
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-cpp/asio:=
	dev-cpp/stduuid:=
	dev-cpp/parallel-hashmap:=
	dev-cpp/bs-thread-pool:=
	dev-cpp/cppcodec:=
	dev-cpp/obfuscate:=
"

S="${WORKDIR}/${PN}-${PV}"

PATCHES=(
	"${FILESDIR}/0000-fix-cmake-enforcing-vcpkg.patch"
	"${FILESDIR}/0010-fix-strange-bsthreadpool-bug.patch"
	"${FILESDIR}/0020-catch-unnecessary-redefinition.patch"
	"${FILESDIR}/0030-uplift-for-asio.patch"
)

src_configure() {
	local mycmakeargs=(
		-DASAN_ENABLED=$(usex sanitize)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DDEBUG_LOG=$(usex debuglog)
		-DOPTIONS_ENABLE_IPO=$(usex lto)
		-DOTCLIENT_BUILD_TESTS=OFF
		-DSPEED_UP_BUILD_UNITY=ON
		-DTOGGLE_FRAMEWORK_SOUND=$(usex sound)
		-DTOGGLE_PRE_COMPILED_HEADER=ON
	)
	use debug || append-cppflags -DNDEBUG
	cd "${BUILD_DIR}"
	cmake "${mycmakeargs[@]}" "${S}"
}

src_install() {
	dobin "${S}/otclient"
}
