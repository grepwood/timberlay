# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
CMAKE_MAKEFILE_GENERATOR=emake

SRC_URI="https://github.com/opentibiabr/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="Canary Server 14.12 for OpenTibia community"
HOMEPAGE="https://github.com/opentibiabr/canary"

LICENSE="GPL-2"
SLOT="0"
IUSE="-telemetry debug debuglog lto sanitize openmp"

RDEPEND="
	acct-group/canary
	acct-user/canary
	dev-lang/luajit:=
	net-misc/curl
	sys-libs/zlib
	dev-cpp/abseil-cpp:=
	dev-libs/pugixml:=
	dev-libs/spdlog:=
	dev-libs/libfmt:=
	app-crypt/argon2
	dev-db/mariadb-connector-c
	dev-db/mysql-connector-c
	dev-libs/protobuf
	dev-cpp/nlohmann_json
	openmp? ( dev-libs/gmp )
	sanitize? ( sys-devel/gcc[sanitize] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-cpp/asio:=
	dev-cpp/atomic-queue:=
	dev-cpp/boost-di:=
	dev-cpp/eventpp:=
	dev-cpp/magic-enum:=
	dev-cpp/mio:=
	dev-cpp/parallel-hashmap:=
	dev-cpp/bs-thread-pool:=
	app-alternatives/bzip2
	sys-apps/coreutils
"

S="${WORKDIR}/${PN}-${PV}"
BUILD_DIR="${WORKDIR}/${PN}-${PV}_build"

PATCHES=(
	"${FILESDIR}/dont-use-vcpkg-on-gentoo-v${PV}.patch"
)

src_configure() {
	local mycmakeargs=(
		-DASAN_ENABLED=$(usex sanitize)
		-DBUILD_STATIC_LIBRARY=OFF
		-DCANARY_BUILD_TESTS=OFF
		-DCMAKE_C_FLAGS="${CFLAGS}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
		-DDEBUG_LOG=$(usex debuglog)
		-DFEATURE_METRICS=$(usex telemetry)
		-DOPTIONS_ENABLE_IPO=$(usex lto)
		-DOPTIONS_ENABLE_OPENMP=$(usex openmp)
		-DSPEED_UP_BUILD_UNITY=ON
		-DTOGGLE_BIN_FOLDER=ON
		-DUSE_PRECOMPILED_HEADER=ON
	)
	use debug || append-cppflags -DNDEBUG
	cd "${BUILD_DIR}"
	cmake "${mycmakeargs[@]}" "${S}"
}

src_compile() {
	mkdir examples
	mv "${S}/config.lua.dist" examples/config.lua
	mv "${S}/schema.sql" examples/schema.sql
	cmake_src_compile
}

src_install() {
	dobin "${BUILD_DIR}/bin/canary"
	dodoc -r examples
}

pkg_postinst() {
	elog "Example configuration files have been installed to:"
	elog "  /usr/share/doc/${PF}/examples/"
	elog "Copy config.lua to /etc/canary/ and edit as needed."
	elog "If you are starting a fresh Canary server, then you also need to use the schema from the examples."
}
