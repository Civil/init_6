# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#------------------------------------------------------------------------

# Latest version checker:
EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

# # curl -s http://www.kernel.org/kdist/finger_banner
bld_ver="KMV-rc4"
ck_ver="KMV-ck2"
grsecurity_ver="2.9.1-${PV}-201206171836"
imq_ver="3.3"
rt_ver="3.4.3-rt11"

SUPPORTED_FEATURES="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice imq mageia pardus -pld rt suse uksm"

inherit kernel-geek

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"

src_prepare() {
	kernel-geek_src_prepare
}
