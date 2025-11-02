# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Forethought Entertainment Quake World engine."
HOMEPAGE="https://www.fteqw.org"
SRC_URI="https://github.com/fte-team/fteqw/archive/refs/tags/${PV//./-}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${PN}-${PV//./-}"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm64 ~ppc64"
SLOT="0"
# add cef when libcef becomes available
IUSE="
	bindist
	bzip2
	client
	-debug
	egl
	-freetype
	-gnutls
	jpeg
	png
	-sdl2
	-sdl3
	server
	-vorbis
	-vulkan
	-wayland
	-X
	zlib

	-fte_plugins_bullet
	-fte_plugins_cod
	-fte_plugins_ezhud
	-fte_plugins_ffmpeg
	-fte_plugins_hl2
	-fte_plugins_irc
	-fte_plugins_models
	-fte_plugins_mpq
	-fte_plugins_ode
	-fte_plugins_openssl
	-fte_plugins_qi
	-fte_plugins_quake3
	-fte_plugins_terraingen
	-fte_plugins_xmpp

	-fte_tools_image
	-fte_tools_iqm
	-fte_tools_masterserver
	-fte_tools_qcc
	-fte_tools_qcvm
	-fte_tools_qtv
	-fte_tools_webserver
"

# Notes on REQUIRED_USE:

# Here's a funny thing about Vulkan support.
# It can't be controlled during source configure stage, because the engine
# will load it if you tell it to, even if it ain't there.
# And the build system will activate it, if it sniffs out the Vulkan libraries.
# So to make sure in either case the build doesn't fail, the client has to
# depend on png and zlib, so the Vulkan support nondeterministically detected
# by CMake will never surprise you and fail the build.
REQUIRED_USE="
	|| ( client server fte_tools_image fte_tools_iqm fte_tools_masterserver fte_tools_qcc fte_tools_qcvm fte_tools_qtv fte_tools_webserver )
	client? (
		|| ( X wayland )
		?? ( sdl2 sdl3 )
		png
		zlib
	)
	!client? ( !sdl2 !sdl3 !wayland !X )

	fte_plugins_bullet? (
		|| ( client server )
	)
	fte_plugins_cod? ( client )
	fte_plugins_ezhud? ( client )
	fte_plugins_ffmpeg? ( client )
	fte_plugins_hl2? (
		client
		zlib
	)
	fte_plugins_irc? ( client )
	fte_plugins_models? (
		|| ( client server )
	)
	fte_plugins_mpq? (
		client
		zlib
	)
	fte_plugins_ode? (
		|| ( client server )
	)
	fte_plugins_openssl? (
		|| ( client server )
	)
	fte_plugins_qi? (
		|| ( client server )
	)
	fte_plugins_quake3? (
		|| ( client server )
	)
	fte_plugins_terraingen? ( client )
	fte_plugins_xmpp? ( client )
"

RDEPEND="
	fte_tools_image? (
		jpeg? ( media-libs/libjpeg-turbo )
		png? ( media-libs/libpng )
	)
	fte_tools_iqm? (
		jpeg? ( media-libs/libjpeg-turbo )
		png? ( media-libs/libpng )
	)
	fte_tools_masterserver? (
		zlib? ( sys-libs/zlib )
	)
	fte_tools_qcc? (
		zlib? ( sys-libs/zlib )
	)
	fte_tools_qcvm? (
		zlib? ( sys-libs/zlib )
	)
	fte_tools_qtv? (
		zlib? ( sys-libs/zlib )
	)

	client? (
		media-libs/alsa-lib
		media-libs/openal
		sys-libs/zlib
		media-libs/libpng

		gnutls? ( net-libs/gnutls )
		vulkan? ( media-libs/vulkan-loader )
		egl? ( media-libs/libglvnd )
		bzip2? ( app-arch/bzip2 )
		freetype? (
			media-libs/freetype
			media-libs/fontconfig
		)
		jpeg? ( media-libs/libjpeg-turbo )
		sdl3? ( media-libs/libsdl3 )
		vorbis? ( media-libs/libvorbis )

		fte_plugins_bullet? ( sci-physics/bullet )
		fte_plugins_ffmpeg? ( media-video/ffmpeg )
		fte_plugins_hl2? ( sys-libs/zlib )
		fte_plugins_mpq? ( sys-libs/zlib )
		fte_plugins_ode? ( dev-games/ode )
		fte_plugins_openssl? (
			bindist? ( >=dev-libs/openssl-3.0.0 )
			!bindist? ( <dev-libs/openssl-3.0.0 )
		)

		sdl2? ( media-libs/libsdl2 )

		wayland? (
			dev-libs/wayland
			x11-libs/libxkbcommon[wayland]
		)
		X? (
			x11-libs/libICE
			x11-libs/libSM
			x11-libs/libX11
			x11-libs/libXau
			x11-libs/libXaw
			x11-libs/libXcomposite
			x11-libs/libXcursor
			x11-libs/libXdamage
			x11-libs/libXdmcp
			x11-libs/libXext
			x11-libs/libXfixes
			x11-libs/libxkbcommon[X]
		)
	)
	server? (
		gnutls? ( net-libs/gnutls )
		bzip2? ( app-arch/bzip2 )
		zlib? ( sys-libs/zlib )
		fte_plugins_openssl? (
			bindist? ( >=dev-libs/openssl-3.0.0 )
			!bindist? ( <dev-libs/openssl-3.0.0 )
		)
	)
"
DEPEND="${RDEPEND}"
# For some reason, the cmake build process calls zip, so we need to add it.
# dos2unix is needed to convert CMakeLists.txt before patching.
BDEPEND="
	app-text/dos2unix
	dev-build/cmake
	dev-util/pkgconf
	app-arch/zip
"

# First patch removes logic that adds -O3 -march=native. The first flag is not
# deemed safe on Gentoo, and the second is non-deterministic. It may produce
# operations that are not compatible with consumers of a binary version of this
# ebuild.

# Second patch is needed to fix a tiny little warning with the CMakeLists.txt
# file. Having that out of the way in the logs is always nice.
PATCHES=(
	"${FILESDIR}/0000-remove-march-native-and-O3.patch"
	"${FILESDIR}/0010-change-argless-elseif-to-else.patch"
	"${FILESDIR}/0030-dont-install-applications.patch"
)

src_prepare() {
	dos2unix "${S}/CMakeLists.txt"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DFTE_INSTALL_BINDIR=bin

		-DFTE_PLUG_BULLET="$(usex fte_plugins_bullet)"
# FTE_PLUG_CEF can only become managed when Gentoo gets a libcef ebuild
		-DFTE_PLUG_CEF=no
		-DFTE_PLUG_COD="$(usex fte_plugins_cod)"
		-DFTE_PLUG_EZHUD="$(usex fte_plugins_ezhud)"
		-DFTE_PLUG_FFMPEG="$(usex fte_plugins_ffmpeg)"
		-DFTE_PLUG_HL2="$(usex fte_plugins_hl2)"
		-DFTE_PLUG_IRC="$(usex fte_plugins_irc)"
		-DFTE_PLUG_MODELS="$(usex fte_plugins_models)"
		-DFTE_PLUG_MPQ="$(usex fte_plugins_mpq)"
# Namemaker is broken in this release
		-DFTE_PLUG_NAMEMAKER=no
		-DFTE_PLUG_ODE="$(usex fte_plugins_ode)"
# media-libs/openxr-loader is only available in guru, so it will be available
# in gentoo in the future. For now let's keep this disabled.
		-DFTE_PLUG_OPENXR=no
		-DFTE_PLUG_QI="$(usex fte_plugins_qi)"
		-DFTE_PLUG_QUAKE3="$(usex fte_plugins_quake3)"
		-DFTE_PLUG_TERRAINGEN="$(usex fte_plugins_terraingen)"
# Timidity is declared in CMakeLists.txt, but doesn't exist in code
		-DFTE_PLUG_TIMIDITY=no
# X11 server is also broken in this release
		-DFTE_PLUG_X11SV=no
		-DFTE_PLUG_XMPP="$(usex fte_plugins_xmpp)"

		-DFTE_ENGINE="$(usex client)"
		-DFTE_ENGINE_SERVER_ONLY="$(usex server)"
# Compiling fteqw-cl seems to always fail, so let's disable it anyway
		-DFTE_ENGINE_CLIENT_ONLY=no

		-DFTE_USE_SDL="$(usex sdl2)"

		-DFTE_DEP_BZIP2="$(usex bzip2)"
# FTE_DEP_DRACO can only become managed when Gentoo gets a draco ebuild
		-DFTE_DEP_DRACO=no
		-DFTE_DEP_FREETYPE="$(usex freetype)"
		-DFTE_DEP_JPEG="$(usex jpeg)"
		-DFTE_DEP_PNG="$(usex png)"
		-DFTE_DEP_SDL3="$(usex sdl3)"
		-DFTE_DEP_VORBISFILE="$(usex vorbis)"
		-DFTE_DEP_ZLIB="$(usex zlib)"

		-DFTE_TOOL_IMAGE="$(usex fte_tools_image)"
		-DFTE_TOOL_IQM="$(usex fte_tools_iqm)"
		-DFTE_TOOL_MASTER="$(usex fte_tools_masterserver)"
		-DFTE_TOOL_HTTPSV="$(usex fte_tools_webserver)"
# fteqcc needs to be compiled if any of those targets are requested:
# - server
# - client
# - image
# - iqm
# - masterserver
# - webserver
# - qcvm
# - qtv
# Without it, they all fail. The actual useflag determines if you keep the
# compiled fteqcc afterwards... Wait, aren't those all targets?
		-DFTE_TOOL_QCC=$(
			usex server yes $(
				usex client yes $(
					usex fte_tools_image yes $(
						usex fte_tools_iqm yes $(
							usex fte_tools_qcvm yes $(
								usex fte_tools_qtv yes $(
									usex fte_tools_qcc yes no
								)
							)
						)
					)
				)
			)
		)
# fteqccgui depends on qscintilla. We can only enable this via use, when fteqw
# migrates to Qt6, because that's what qscintilla from Gentoo uses.
		-DFTE_TOOL_QCCGUI=no
		-DFTE_TOOL_QCVM="$(usex fte_tools_qcvm)"
		-DFTE_TOOL_QTV="$(usex fte_tools_qtv)"
	)

	if use gnutls; then
		mycmakeargs+=(
			-DFTE_DEP_GNUTLS=yes
# I know it says static, but trust me on this one - it's not what you think.
# If you were to say "false" here, it would try and load GnuTLS via dlopen.
			-DGNUTLS_STATIC=true
		)
	else
		mycmakeargs+=(
			-DFTE_DEP_GNUTLS=no
		)
	fi
	if use fte_plugins_openssl; then
# If you want to create non-redistributable binaries, we will enable this flag
# that will allow you to link against OpenSSL before 3.0.0.
		if ! use bindist; then
			mycmakeargs+=(
				-DFTE_PRIVATE_USE_ONLY=true
			)
		fi
		mycmakeargs+=(
			-DOPENSSL_USE_STATIC_LIBS=false
			-DOPENSSL_ROOT_DIR=/usr
			-DFTE_PLUG_OPENSSL=yes
		)
	fi

	echo ${mycmakeargs[@]}

	use debug || append-cppflags -DNDEBUG

	cmake_src_configure
}

src_install() {
	cmake_src_install
	local artifact_dir="${WORKDIR}/${PN}-${PV//./-}_build"
	local libdir=$(get_libdir)
	exeinto /usr/bin
	insinto "/usr/${libdir}/fteqw"
# Tools
	if ! use fte_tools_qcc; then
		rm "${D}/usr/bin/fteqcc"
	fi
	if use fte_tools_qtv; then
# Rename qtv to avoid collision with dev-qt/qtvirtualkeyboard
		mv "${D}/usr/bin/qtv" "${D}/usr/bin/fteqtv"
	fi
	if use fte_tools_webserver; then
		mv "${artifact_dir}/httpserver" "${artifact_dir}/ftehttpserver"
		doexe "${artifact_dir}/ftehttpserver"
	fi
# Plugins
	if use fte_plugins_mpq; then
# For some reason CMake doesn't install this
		doins "${artifact_dir}/libplug_mpq.so"
	fi
}
