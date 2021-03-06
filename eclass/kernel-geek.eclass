# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Andrey Ovcharov <sudormrfhalt@gmail.com>
# Purpose: kernel-2 replacer.
#
# Bugs to sudormrfhalt@gmail.com
#

EXPORT_FUNCTIONS ApplyPatch src_unpack src_prepare src_compile src_install pkg_postinst

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
DEPEND="${DEPEND} app-arch/xz-utils"

OLDIFS="$IFS"
VER="${PV}"
IFS='.'
set -- ${VER}
IFS="${OLDIFS}"

# the kernel version (e.g 3 for 3.4.2)
VERSION="${1}"
# the kernel patchlevel (e.g 4 for 3.4.2)
PATCHLEVEL="${2}"
# the kernel sublevel (e.g 2 for 3.4.2)
SUBLEVEL="${3}"
# the kernel major version (e.g 3.4 for 3.4.2)
KMV="${1}.${2}"

KV_FULL="${PVR}-geek"
S="${WORKDIR}"/linux-"${KV_FULL}"
SLOT="${PV}"

KNOWN_FEATURES="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice imq mageia pardus pld reiser4 rt suse uksm"
SRC_URI="http://www.kernel.org/pub/linux/kernel/v3.x/linux-${KMV}.tar.xz
	http://www.kernel.org/pub/linux/kernel/v3.x/patch-${PV}.xz"

# Alternate CPU load distribution technique for Linux kernel scheduler
bld_src="http://bld.googlecode.com/files/bld-${bld_ver/KMV/$KMV}.tar.bz2"

# Con Kolivas' high performance patchset
ck_src="http://ck.kolivas.org/patches/3.0/${KMV}/${KMV}-ck2/patch-${ck_ver/KMV/$KMV}.bz2"

# deblob
deblob_src="http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-${KMV} http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-check"

# Spock's fbsplash patch
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/${KMV}/4200_fbcondecor-0.9.6.patch"

# grsecurity security patches
grsecurity_src="http://grsecurity.net/test/grsecurity-${grsecurity_ver/KMV/$KMV}.patch"

# Intermediate Queueing Device patches
imq_src="http://www.linuximq.net/patches/patch-imqmq-${imq_ver/KMV/$KMV}.diff.xz"

reiser4_src="mirror://kernel/linux/kernel/people/edward/reiser4/reiser4-for-2.6/reiser4-for-${REISER4_OKV}${REISER4_VER}.patch.bz2"

# Ingo Molnar's realtime preempt patches
rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/${KMV}/patch-${rt_ver/KMV/$KMV}.patch.xz"

xenomai_src="http://download.gna.org/xenomai/stable/xenomai-${xenomai_ver/KVM/$KMV}.tar.bz2"

featureKnown() {
	local feature="${1/-/}"
	feature="${feature/+/}"
	[ "${feature}" == "" ] && die "Feature not defined!"

	expr index "${SUPPORTED_FEATURES}" "${feature}" >/dev/null || die "${feature} is not supported in current kernel"
	expr index "${KNOWN_FEATURES}" "${feature}" >/dev/null || die "${feature} is not known"
	IUSE="${IUSE} ${feature}"
	case ${feature} in
		aufs)
			HOMEPAGE="${HOMEPAGE} http://aufs.sourceforge.net/"
			;;
		bfq)
			# Budget Fair Queueing Budget I/O Scheduler
			if [ "${OVERRIDE_bld_src}" != "" ]; then
				bld_src="${OVERRIDE_bld_src}"
			fi
			HOMEPAGE="${HOMEPAGE} http://algo.ing.unimo.it/people/paolo/disk_sched/"
			SRC_URI="${SRC_URI}
				bld?		( ${bld_src} )"
			;;
		bld)
			HOMEPAGE="${HOMEPAGE} http://code.google.com/p/bld"
			;;
		ck)
			if [ "${OVERRIDE_ck_src}" != "" ]; then
				ck_src="${OVERRIDE_ck_src}"
			fi
			HOMEPAGE="${HOMEPAGE} http://users.on.net/~ckolivas/kernel"
			SRC_URI="${SRC_URI}
				ck?		( ${ck_src} )"
			;;
		deblob)
			if [ "${OVERRIDE_deblob_src}" != "" ]; then
				deblob_src="${OVERRIDE_deblob_src}"
			fi
			HOMEPAGE="${HOMEPAGE} http://linux-libre.fsfla.org/pub/linux-libre/"
			SRC_URI="${SRC_URI}
				deblob?		( ${deblob_src} )"
			;;
		fbcondecor)
			if [ "${OVERRIDE_fbcondecor_src}" != "" ]; then
				fbcondecor_src="${OVERRIDE_fbcondecor_src}"
			fi
			HOMEPAGE="${HOMEPAGE} http://dev.gentoo.org/~spock/projects/fbcondecor"
			SRC_URI="${SRC_URI}
				fbcondecor?	( ${fbcondecor_src} )"
			;;
		fedora)
			HOMEPAGE="${HOMEPAGE} http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary"
			;;
		grsecurity)
			if [ "${OVERRIDE_grsecurity_src}" != "" ]; then
				grsecurity_src="${OVERRIDE_grsecurity_src}"
			fi
			HOMEPAGE="${HOMEPAGE} http://grsecurity.net"
			RDEPEND="${RDEPEND}
				grsecurity?	( >=sys-apps/gradm-2.2.2 )"
			SRC_URI="${SRC_URI}
				grsecurity?	( ${grsecurity_src} )"
			;;
		ice)
			HOMEPAGE="${HOMEPAGE} http://tuxonice.net"
			RDEPEND="${RDEPEND}
				ice?		( >=sys-apps/tuxonice-userui-1.0
					( || ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) ) )"
			;;
		imq)
			if [ "${OVERRIDE_imq_src}" != "" ]; then
				imq_src="${OVERRIDE_imq_src}"
			fi
			HOMEPAGE="${HOMEPAGE} http://www.linuximq.net"
			SRC_URI="${SRC_URI}
				imq?		( ${imq_src} )"
			;;
		mageia)
			HOMEPAGE="${HOMEPAGE} http://svnweb.mageia.org/packages/cauldron/kernel/current"
			;;
		pardus)
			HOMEPAGE="${HOMEPAGE} https://svn.pardus.org.tr/pardus/playground/kaan.aksit/2011/kernel/default/kernel"
			;;
		pld)
			HOMEPAGE="${HOMEPAGE} http://cvs.pld-linux.org/cgi-bin/viewvc.cgi/cvs/packages/kernel/?pathrev=MAIN"
			;;
		reiser4)
			HOMEPAGE="${HOMEPAGE} http://sourceforge.net/projects/reiser4"
			;;
		rt)
			HOMEPAGE="${HOMEPAGE} http://www.kernel.org/pub/linux/kernel/projects/rt"
			SRC_URI="${SRC_URI}
				rt?		( ${rt_src} )"
			;;
		suse)
			HOMEPAGE="${HOMEPAGE} http://kernel.opensuse.org/cgit/kernel-source"
			;;
		uksm)
			HOMEPAGE="${HOMEPAGE} http://kerneldedup.org"
			;;
	esac
}

for I in ${SUPPORTED_FEATURES}; do
	featureKnown "${I}"
done

patch_command='patch -p1 -F1 -s'
ExtractApply() {
	local patch=$1
	shift
	case "$patch" in
	*.bz2) bunzip2 < "$patch" | $patch_command ${1+"$@"} ;;
	*.gz)  gunzip  < "$patch" | $patch_command ${1+"$@"} ;;
	*.xz)  unxz    < "$patch" | $patch_command ${1+"$@"} ;;
	*) $patch_command ${1+"$@"} < "$patch" ;;
	esac
}

Handler() {
	local patch=$1
	shift
	if [ ! -f $patch ]; then
		ewarn "Patch $patch does not exist."
		exit 1
	fi
	# don't apply patch if it's empty
	local C=$(wc -l $patch | awk '{print $1}')
	if [ "$C" -gt 9 ]; then
		patch_command='patch -p1 --dry-run'
		if ExtractApply "$patch" &>/dev/null; then
			patch_command='patch -p1 -F1 -s'
			ExtractApply "$patch" &>/dev/null
		else
			ewarn "Skipping patch --> $(basename $patch)"
		fi
	fi
}

kernel-geek_ApplyPatch() {
	local patch=$1
	local msg=$2
	shift
	echo
	einfo "${msg}"
	case `basename "$patch"` in
	patch_list)
		while read -r line
		do
			# skip comments
			[[ $line =~ ^\ {0,}# ]] && continue
			# skip empty lines
			[[ -z "$line" ]] && continue
				ebegin "Applying $line"
					dir=`dirname "$patch"`
					Handler "$dir/$line"
				eend $?
		done < "$patch"
	;;
	*)
		ebegin "Applying $(basename $patch)"
			Handler "$patch"
		eend $?
	;;
	esac
}

kernel-geek_src_unpack() {
	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${DISTDIR}/linux-${KMV}.tar.xz" &>/dev/null
		eend $?
		cd "${WORKDIR}"
		mv "linux-${KMV}" "${S}"
	fi
	cd "${S}"
	ApplyPatch "${DISTDIR}/patch-${PV}.xz" "Update to latest upstream ..."

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		cp "${DISTDIR}/deblob-${KMV}" "${T}" || die "cp deblob-${KMV} failed"
		cp "${DISTDIR}/deblob-check" "${T}/deblob-check" || die "cp deblob-check failed"
		chmod +x "${T}/deblob-${KMV}" "${T}/deblob-check" || die "chmod deblob scripts failed"
	fi
}

kernel-geek_src_prepare() {
	use bfq && ApplyPatch "${FILESDIR}/${PV}/bfq/patch_list" "Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}"

	use ck && ApplyPatch "$DISTDIR/patch-${ck_ver}.bz2" "Con Kolivas high performance patchset - ${ck_url}"

	use fbcondecor && ApplyPatch "${DISTDIR}/4200_fbcondecor-0.9.6.patch" "Spock's fbsplash patch - ${fbcondecor_url}"

	use grsecurity && ApplyPatch "${DISTDIR}/grsecurity-${grsecurity_ver}.patch" "GrSecurity patches - ${grsecurity_url}"

	use ice && ApplyPatch "${FILESDIR}/tuxonice-kernel-${PV}.patch.xz" "TuxOnIce - ${ice_url}"

	use imq && ApplyPatch "${DISTDIR}/patch-imqmq-${imq_ver}.diff.xz" "Intermediate Queueing Device patches - ${imq_url}"
#	use imq && ApplyPatch "$FILESDIR/${PV}/pld/kernel-imq.patch" "Intermediate Queueing Device patches - ${imq_url} ${pld_url}"

	use reiser4 && ApplyPatch "${DISTDIR}/reiser4-for-${PV}.patch.bz2" "Reiser4 - ${reiser4_url}"
#	use reiser4 && ApplyPatch "$FILESDIR/${PV}/pld/kernel-reiser4.patch" "Reiser4 - ${reiser4_url} ${pld_url}"

	use rt && ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "Ingo Molnar's realtime preempt patches - ${rt_url}"

	if use bld; then
		echo
		cd "${T}"
		unpack "bld-${bld_ver}.tar.bz2"
		cp "${T}/bld-${bld_ver}/BLD-${bld_ver}.patch" "${S}/BLD-${bld_ver}.patch"
		cd "${S}"
		ApplyPatch "BLD-${bld_ver}.patch" "Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}"
		rm -f "BLD-${bld_ver}.patch"
		rm -r "${T}/bld-${bld_ver}" # Clean temp
	fi

	use uksm && ApplyPatch "${FILESDIR}/${PV}/uksm/patch_list" "Ultra Kernel Samepage Merging - ${uksm_url}"

#	if use xenomai; then
#		# Portage's ``unpack'' macro unpacks to the current directory.
#		# Unpack to the work directory.  Afterwards, ``work'' contains:
#		#   linux-2.6.29-xenomai-r5
#		#   xenomai-2.4.9
#		cd ${WORKDIR}
#		unpack ${XENO_TAR} || die "unpack failed"
#		cd ${WORKDIR}/${XENO_SRC}
#		ApplyPatch ${FILESDIR}/prepare-kernel.patch || die "patch failed"
#		scripts/prepare-kernel.sh --linux=${S} || die "prepare kernel failed"
#	fi

### BRANCH APPLY ###

	use aufs && ApplyPatch "$FILESDIR/${PV}/aufs/patch_list" "aufs3 - ${aufs_url}"

	use mageia && ApplyPatch "$FILESDIR/${PV}/mageia/patch_list" "Mandriva/Mageia - ${mageia_url}"

	use fedora && ApplyPatch "$FILESDIR/${PV}/fedora/patch_list" "Fedora - ${fedora_url}"

	use suse && ApplyPatch "$FILESDIR/${PV}/suse/patch_list" "OpenSuSE - ${suse_url}"

	use pardus && ApplyPatch "$FILESDIR/${PV}/pardus/patch_list" "Pardus - ${pardus_url}"

	use pld && ApplyPatch "$FILESDIR/${PV}/pld/patch_list" "PLD - ${pld_url}"

	ApplyPatch "${FILESDIR}/acpi-ec-add-delay-before-write.patch" "Oops: ACPI: EC: input buffer is not empty, aborting transaction - 2.6.32 regression https://bugzilla.kernel.org/show_bug.cgi?id=14733#c41"

	# USE branding
	if use branding; then
		ApplyPatch "${FILESDIR}/font-8x16-iso-latin-1-v2.patch" "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		ApplyPatch "${FILESDIR}/gentoo-larry-logo-v2.patch" "logo - CONFIG_LOGO_LARRY_CLUT224 https://github.com/init6/init_6/raw/master/sys-kernel/geek-sources/files/larry.png"
	fi

### END OF PATCH APPLICATIONS ###

	echo
	einfo "Live long and prosper."
	echo

	# Comment out EXTRAVERSION added by CK patch:
	use ck && sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "Makefile"
	
	einfo "Copy current config from /proc"
	if [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then
		ewarn "Kernel config file already exist."
		ewarn "I will NOT overwrite that."
	else
		einfo "Copying kernel config file."
		zcat /proc/config > .config || ewarn "Can't copy /proc/config"
	fi

	einfo "Cleanup backups after patching"
	find '(' -name '*~' -o -name '*.orig' -o -name '.gitignore' ')' -print0 | xargs -0 -r -l512 rm -f
}

kernel-geek_src_compile() {
	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		echo ">>> Running deblob script ..."
		sh "${T}/deblob-${KMV}" --force || \
			die "Deblob script failed to run!!!"
	fi
}

kernel-geek_src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	cd "${S}"
	dodir /usr/src
	echo ">>> Copying sources ..."

	mv ${WORKDIR}/linux* "${D}"/usr/src
}

kernel-geek_pkg_postinst() {
	einfo " If you are upgrading from a previous kernel, you may be interested "
	einfo " in the following document:"
	einfo "   - General upgrade guide: http://www.gentoo.org/doc/en/kernel-upgrade.xml"
	einfo " geek-sources is UNSUPPORTED by Funtoo or Gentoo Security."
	einfo " This means that it is likely to be vulnerable to recent security issues."
	einfo " For specific information on why this kernel is unsupported, please read:"
	einfo " http://www.gentoo.org/proj/en/security/kernel.xml"
	echo
	einfo " Now is the time to configure and build the kernel."
	use uksm && einfo " Do not forget to disable the remote bug reporting feature by echo 0 > /sys/kernel/mm/uksm/usr_spt_enabled
	more http://kerneldedup.org/en/projects/uksm/uksmdoc/usage/"
}
