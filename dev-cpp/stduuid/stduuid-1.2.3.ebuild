# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

SRC_URI="https://github.com/mariusbancila/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"

DESCRIPTION="A C++17 cross-platform implementation for UUIDs"
HOMEPAGE="https://github.com/mariusbancila/stduuid"

LICENSE="MIT"
SLOT="0"
IUSE="debug system time -cxx20"

RDEPEND="
	system? ( sys-apps/util-linux )
	!cxx20? ( dev-cpp/ms-gsl )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/cmake
	sys-apps/coreutils
"

S="${WORKDIR}/${PN}-${PV}"

src_configure() {
	local mycmakeargs=()
	if use debug; then
		mycmakeargs+=( \
			-DCMAKE_BUILD_TYPE=Debug \
		)
	fi
	mycmakeargs+=( \
		-DUUID_SYSTEM_GENERATOR=$(usex system) \
		-DUUID_TIME_GENERATOR=$(usex time) \
		-DUUID_USING_CXX20_SPAN=$(usex cxx20) \
		-DUUID_BUILD_TESTS=OFF \
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
# For some reason stduuid keeps and installs a clone of dev-cpp/ms-gsl headers
	rm -rf "${D}/usr/include/gsl"
# OTClient wants this in a separate directory
	mkdir stduuid
	mv "${D}/usr/include/uuid.h" stduuid
	insinto /usr/include
	doins -r stduuid
}
