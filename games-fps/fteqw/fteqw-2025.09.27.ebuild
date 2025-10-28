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
IUSE="bindist -bullet bzip2 client -cod -debug egl -ezhud -ffmpeg -freetype -gnutls -hl2 -image -iqm -irc jpeg -masterserver -models -mpq -ode -openssl png -qcc -qcvm -qi -quake3 -qtv -sdl2 -sdl3 server -terraingen -vorbis -vulkan -wayland -webserver -X -xmpp zlib"

# Notes on REQUIRED_USE:

# Here's a funny thing about Vulkan support.
# It can't be controlled during source configure stage, because the engine
# will load it if you tell it to, even if it ain't there.
# And the build system will activate it, if it sniffs out the Vulkan libraries.
# So to make sure in either case the build doesn't fail, the client has to
# depend on png and zlib, so the Vulkan support nondeterministically detected
# by CMake will never surprise you and fail the build.
REQUIRED_USE="
	|| ( client server iqm image masterserver qcc qcvm qtv webserver )
	client? (
		|| ( X wayland )
		?? ( sdl2 sdl3 )
		png
		zlib
	)
	!client? ( !sdl2 !sdl3 !wayland !X )

	bullet? (
		|| ( client server )
	)
	cod? ( client )
	ezhud? ( client )
	ffmpeg? ( client )
	hl2? (
		client
		zlib
	)
	irc? ( client )
	models? (
		|| ( client server )
	)
	mpq? (
		client
		zlib
	)
	ode? (
		|| ( client server )
	)
	openssl? (
		|| ( client server )
	)
	qi? (
		|| ( client server )
	)
	quake3? (
		|| ( client server )
	)
	terraingen? ( client )
	xmpp? ( client )
"

RDEPEND="
	image? (
		jpeg? ( media-libs/libjpeg-turbo )
		png? ( media-libs/libpng )
	)
	iqm? (
		jpeg? ( media-libs/libjpeg-turbo )
		png? ( media-libs/libpng )
	)
	masterserver? (
		zlib? ( sys-libs/zlib )
	)
	qcc? (
		zlib? ( sys-libs/zlib )
	)
	qcvm? (
		zlib? ( sys-libs/zlib )
	)
	qtv? (
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

		bullet? ( sci-physics/bullet )
		ffmpeg? ( media-video/ffmpeg )
		hl2? ( sys-libs/zlib )
		mpq? ( sys-libs/zlib )
		ode? ( dev-games/ode )
		openssl? (
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
		openssl? (
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
)

src_prepare() {
	dos2unix "${S}/CMakeLists.txt"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr

		-DFTE_PLUG_BULLET="$(usex bullet)"
# FTE_PLUG_CEF can only become managed when Gentoo gets a libcef ebuild
		-DFTE_PLUG_CEF=no
		-DFTE_PLUG_COD="$(usex cod)"
		-DFTE_PLUG_EZHUD="$(usex ezhud)"
		-DFTE_PLUG_FFMPEG="$(usex ffmpeg)"
		-DFTE_PLUG_HL2="$(usex hl2)"
		-DFTE_PLUG_IRC="$(usex irc)"
		-DFTE_PLUG_MODELS="$(usex models)"
		-DFTE_PLUG_MPQ="$(usex mpq)"
# Namemaker is broken in this release
		-DFTE_PLUG_NAMEMAKER=no
		-DFTE_PLUG_ODE="$(usex ode)"
# media-libs/openxr-loader is only available in guru, so it will be available
# in gentoo in the future. For now let's keep this disabled.
		-DFTE_PLUG_OPENXR=no
		-DFTE_PLUG_QI="$(usex qi)"
		-DFTE_PLUG_QUAKE3="$(usex quake3)"
		-DFTE_PLUG_TERRAINGEN="$(usex terraingen)"
# Timidity is declared in CMakeLists.txt, but doesn't exist in code
		-DFTE_PLUG_TIMIDITY=no
# X11 server is also broken in this release
		-DFTE_PLUG_X11SV=no
		-DFTE_PLUG_XMPP="$(usex xmpp)"

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

		-DFTE_TOOL_IMAGE="$(usex image)"
		-DFTE_TOOL_IQM="$(usex iqm)"
		-DFTE_TOOL_MASTER="$(usex masterserver)"
		-DFTE_TOOL_HTTPSV="$(usex webserver)"
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
					usex image yes $(
						usex iqm yes $(
							usex qcvm yes $(
								usex qtv yes $(
									usex qcc yes no
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
		-DFTE_TOOL_QCVM="$(usex qcvm)"
		-DFTE_TOOL_QTV="$(usex qtv)"
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
	if use openssl; then
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

src_compile() {
	cmake_src_compile

# Rename qtv to avoid collision with dev-qt/qtvirtualkeyboard
	if use qtv; then
		mv "${WORKDIR}/${PN}-${PV//./-}_build/qtv" "${WORKDIR}/${PN}-${PV//./-}_build/fteqtv"
	fi
}

src_install() {
	local artifact_dir="${WORKDIR}/${PN}-${PV//./-}_build"
	exeinto /usr/bin
# Main binaries
	if use client; then
		doexe "${artifact_dir}/fteqw"
	fi
	if use server; then
		doexe "${artifact_dir}/fteqw-sv"
	fi

# Tools
	if use image; then
		doexe "${artifact_dir}/imgtool"
	fi
	if use iqm; then
		doexe "${artifact_dir}/iqmtool"
	fi
	if use masterserver; then
		doexe "${artifact_dir}/ftemaster"
	fi
	if use webserver; then
		doexe "${artifact_dir}/httpserver"
	fi
	if use qcc; then
		doexe "${artifact_dir}/fteqcc"
	fi
	if use qcvm; then
		doexe "${artifact_dir}/qcvm"
	fi
	if use qtv; then
		doexe "${artifact_dir}/fteqtv"
	fi

# Plugins
	local libdir=$(get_libdir)
	insinto "/usr/${libdir}/fteqw"
	if use bullet; then
		doins "${artifact_dir}/fteplug_bullet.so"
	fi
	if use cod; then
		doins "${artifact_dir}/fteplug_cod.so"
	fi
	if use ezhud; then
		doins "${artifact_dir}/fteplug_ezhud.so"
	fi
	if use ffmpeg; then
		doins "${artifact_dir}/fteplug_ffmpeg.so"
	fi
	if use hl2; then
		doins "${artifact_dir}/fteplug_hl2.so"
	fi
	if use irc; then
		doins "${artifact_dir}/fteplug_irc.so"
	fi
	if use models; then
		doins "${artifact_dir}/fteplug_models.so"
	fi
	if use mpq; then
		doins "${artifact_dir}/libplug_mpq.so"
	fi
	if use ode; then
		doins "${artifact_dir}/fteplug_ode.so"
	fi
	if use openssl; then
		doins "${artifact_dir}/fteplug_openssl.so"
	fi
# Uncomment this when openxr exists in Gentoo.
#	if use openxr; then
#		doins "${artifact_dir}/fteplug_openxr.so"
#	fi
	if use qi; then
		doins "${artifact_dir}/fteplug_qi.so"
	fi
	if use quake3; then
		doins "${artifact_dir}/fteplug_quake3.so"
	fi
	if use terraingen; then
		doins "${artifact_dir}/fteplug_terraingen.so"
	fi
	if use xmpp; then
		doins "${artifact_dir}/fteplug_xmpp.so"
	fi
}
