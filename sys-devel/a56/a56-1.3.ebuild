# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Freeware Motorola DSP56001 assembler"
HOMEPAGE="http://zdomain.com/a56.html https://salsa.debian.org/alteholz/a56"

SRC_URI="https://salsa.debian.org/alteholz/${PN}/-/archive/debian/${PV}+dfsg-12/${PN}-debian-${PV}+dfsg-12.tar.bz2"

KEYWORDS="~amd64 ~x86 ~ppc64 ~arm64"
LICENSE="freeware"
SLOT="0"
IUSE=""
S="${WORKDIR}/${PN}-debian-${PV}+dfsg-12"
BDEPEND="
	dev-build/make
	sys-devel/gcc
	app-alternatives/awk
	app-alternatives/yacc
	sys-apps/coreutils
	sys-devel/patch
"
RDEPEND="
	sys-libs/glibc
"

PATCHES=(
	debian/patches/pc-type.patch
	debian/patches/include.patch
	debian/patches/Makefile.patch
	debian/patches/fgets.patch
	debian/patches/use-standard-function-declarations.patch
	debian/patches/declare-attribute-format.patch
	debian/patches/clean-up.patch
	debian/patches/ansi-c.patch
	debian/patches/fix-type-warnings.patch
	debian/patches/fix-miscellaneous-warnings.patch
)

src_compile() {
	make
	mv bin2h a56-bin2h
	mv toomf a56-toomf
	mv keybld a56-keybld
}

src_install() {
	dobin a56
	dobin a56-bin2h
	dobin a56-tobin
	dobin a56-toomf
	dobin a56-keybld
}
