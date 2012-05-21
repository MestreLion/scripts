#!/bin/bash
#
# reposize - Calculates the size of an Ubuntu or Debian repository
#
#    Based on reposize.sh <https://pzt.me/6xbd> written by Eduardo Lago Aguilar
#    <eduardo.lago.aguilar@gmail.com>. Original code retrieved in 2012-03-21
#
#    Copyright (C) 2012 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/gpl.html>
#
# This script computes the total size of various Debian-based repositories by
# means of downloading the Packages.gz and making a sum of the size of every
# package. Of course, there are many shared/common packages between different
# versions of the same Linux distro. So this script will compute the max
# possible size.
#
# Additionally the script saves the size for every collection of packages
# (Packages.gz) on a temporal archive, so if you run the script twice it won't
# download the Packages.gz again.

usage() {
cat <<- USAGE
	Usage: $self [options]
USAGE
if [[ "$1" ]] ; then
	cat <<- USAGE
		Try '$self --help' for more information.
	USAGE
	exit 1
fi
cat <<-USAGE

	Calculates the size of Debian repositories, including derivatives as Ubuntu

	General Options:
	-h|--help     - show this page.
	-v|--verbose  - print more details about what is being done.
	-q|--quiet    - do not print download status or errors

	Cache Options:
	   --update   - update cache by re-scanning repositories' urls
	   --purge    - purge all cache files, forcing re-download of remote files

	Filter Options:
	--distros    DISTRO,[...]    Distribuitions (debian,ubuntu,linuxmint)
	--releases   RELEASE,[...]   Releases (stable,oneiric,lisa)
	--components COMPONENT,[...] Components (main,contrib,universe,multiverse)
	--archs      ARCH,[...]      Architectures (i386,amd64)

	For each filter option, if blank or ommited, all values are shown.
	For archs, "binary-" will be appended to each selected arch

	Result Options:
	--installed        show Installed Size instead. Default is package size
	--collapse  GROUP  collapse the given group (distro,release,component,arch),
	                   and all its "subgroups", in a single result line.

	Examples:
	$self --update --collapse arch
	$self --archs i386 --installed --collapse component
	$self --distros ubuntu --releases lucid,maverick --components main

	Copyright (C) 2012 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
	License: GPLv3 or later. See <http://www.gnu.org/licenses/gpl.html>
USAGE
exit 0
}
invalid() { echo "$self: invalid option $1" ; usage 1 ; }
missing() { echo "missing ${1:+$1 }operand" ; usage 1 ; }

fatal() { [[ "$1" ]] && printf "%s\n" "$self: $1" >&2 ; exit "${2:-1}" ; }

_set_group() {
	case "$1" in
	distro   ) group=4 ;;
	release  ) group=3 ;;
	component) group=2 ;;
	arch     ) group=1 ;;
	?*       ) invalid "for --collapse: $1" ;;
	*        ) missing "collapse"
	esac
}

_show_distro(){
	(( "${#udistros[@]}" )) || return 0
	local dist
	for dist in "${udistros[@]}"; do [[ "$1" == "$dist" ]] && return 0; done
	return 1
}

_printrepo() {
	printf "%'9d MiB - %s %s %s\n" $(( $1/(1024*1024) )) "$2" "$3" "$4"
}

_get_repo_info() {
	local timecond
	local url="${baseurl}/dists/${1}/${2}/${3}/Packages.gz"
	local cachefile="${cachedir}/${distro/\//_}_${1/\//_}_${2/\//_}_${3}.gz"
	local infofile="${cachefile}.info.txt"

	# Download
	{ ! [[ -f "$cachefile" ]] || (( update )) ; } && {
		(( quiet )) || echo "Processing $url"
		[[ -f "$cachefile" ]] && timecond=( "-S" "--time-cond" "$cachefile" )
		curl -L -f -s -o "$cachefile" "${timecond[@]}" "$url"
	}

	# Extract and generate info
	[[ "$infofile" -nt "$cachefile" ]] || {
		if [[ -f "$cachefile" ]] ; then zcat "$cachefile"; else echo ""; fi |
		awk '
			BEGIN { size=0; inst=0; lblsize="Size:"; lblinst="Installed-Size:" }
			$1==lblsize {size += $2}
			$1==lblinst {inst += $2 * 1024}
			END{ printf("%s %.0f\n",lblsize,size);printf("%s %.0f\n",lblinst,inst) }
		' > "$infofile"
	}
}

_size_for_repo() {
	local infofile="$cachedir/${distro/\//_}_${1/\//_}_${2/\//_}_$3.gz.info.txt"
	if (( installed )) ; then field="Installed-Size:" ; else field="Size:"; fi
	awk -v "field=$field" '$1==field{printf("%.0f\n",$2)}' "$infofile"
}

_size_for_distro() {
	local distro_total=0
	local reposize=0
	local subtotal=0

	# Download and cache loop
	for rel in "${releases[@]}" ; do
		for comp in "${components[@]}" ; do
			for arch in "${archs[@]}" ; do
				_get_repo_info "$rel" "$comp" "$arch"
			done
		done
	done

	# Read and show loop
	echo -e "\n${distro} DISTRO${instlabel} SIZE SUMMARY"
	echo "===================================="
	for rel in "${releases[@]}" ; do
		for comp in "${components[@]}" ; do
			for arch in "${archs[@]}" ; do
				(( reposize = $(_size_for_repo "$rel" "$comp" "$arch") ))
				(( subtotal += reposize ))
				(( distro_total += reposize ))
				(( group == 0 )) && { _printrepo "$subtotal" "$rel" "$comp" "$arch" ; subtotal=0 ; }
			done
			(( group == 1 )) && { _printrepo "$subtotal" "$rel" "$comp" ; subtotal=0 ; }
		done
		(( group == 2 )) && { _printrepo "$subtotal" "$rel" ; subtotal=0 ; }
	done
	(( total += distro_total ))
	printf "%'9d MiB [%'6d GiB] - TOTAL DISTRO${instlabel} SIZE\n\n" \
		$((distro_total/(1024*1024))) \
		$((distro_total/(1024*1024*1024)))
}

self="${0##*/}"
cachedir=${XDG_CACHE_HOME:-~/.cache}/reposize
today=$(date +'%Y%m%d')
verbose=0
quiet=0
update=0
installed=0
purge=0
group=0
total=0

instlabel=
udistros=()
ureleases=()
ucomponents=()
uarch=()

# Loop options
while (( $# )); do
	case "$1" in
	-h|--help     ) usage                    ;;
	-v|--verbose  ) verbose=1                ;;
	-q|--quiet    ) quiet=1                  ;;
	--update      ) update=1                 ;;
	--installed   ) installed=1              ;;
	--purge       ) purge=1                  ;;
	--collapse    ) shift ; _set_group "$1"  ;;
	--distros     ) shift ; IFS="," read -a udistros    <<< "$1" ;;
	--releases    ) shift ; IFS="," read -a ureleases   <<< "$1" ;;
	--components  ) shift ; IFS="," read -a ucomponents <<< "$1" ;;
	--archs       ) shift ; IFS="," read -a uarchs      <<< "$1" ;;
	*             ) invalid "$1" ;;
	esac
	shift
done


# Handle user input
(( purge )) && { rm -rf "$cachedir" ; echo "$self: purged $cachedir" ; exit ; }
(( installed )) && instlabel=" INSTALLED"

for i in "${!uarchs[@]}"; do uarchs[i]="binary-${uarchs[i]}"; done

# Check if external tools are present
type curl >/dev/null 2>&1 ||
fatal "curl not found. Install it with 'sudo apt-get install curl'"


mkdir -p "$cachedir" || fatal "could not create cache directory $cachedir"

distro=ubuntu
if _show_distro "$distro"; then
	baseurl=http://archive.ubuntu.com/ubuntu
	if (( ${#ureleases[@]} )); then releases=("${ureleases[@]}")
	else
		releases=()
		releases+=(lucid    lucid-backports    lucid-proposed    lucid-security    lucid-updates)
		releases+=(maverick maverick-backports maverick-proposed maverick-security maverick-updates)
		releases+=(natty    natty-backports    natty-proposed    natty-security    natty-updates)
		releases+=(oneiric  oneiric-backports  oneiric-proposed  oneiric-security  oneiric-updates)
		releases+=(precise  precise-backports  precise-proposed  precise-security  precise-updates)
	fi
	if (( ${#ucomponents[@]} )); then components=("${ucomponents[@]}")
	else components=("main" "multiverse" "restricted" "universe") ; fi
	if (( ${#uarchs[@]} )); then archs=("${uarchs[@]}")
	else archs=("binary-i386" "binary-amd64") ; fi
	_size_for_distro

	baseurl=http://archive.canonical.com/ubuntu
	if (( ${#ureleases[@]} )); then releases=("${ureleases[@]}")
	else
		releases=()
		releases+=(lucid)
		releases+=(maverick)
		releases+=(natty)
		releases+=(oneiric)
		releases+=(precise)
	fi
	if (( ${#ucomponents[@]} )); then components=("${ucomponents[@]}")
	else components=("partner") ; fi
	if (( ${#uarchs[@]} )); then archs=("${uarchs[@]}")
	else archs=("binary-i386" "binary-amd64") ; fi
	_size_for_distro
fi

distro=debian
if _show_distro "$distro"; then
	baseurl=http://ftp.debian.org/debian
	if (( ${#ureleases[@]} )); then releases=("${ureleases[@]}")
	else
		releases=()
		releases+=(stable-proposed-updates stable-updates stable)
		releases+=(testing-proposed-updates testing)
		releases+=(unstable)
	fi
	if (( ${#ucomponents[@]} )); then components=("${ucomponents[@]}")
	else components=("main" "contrib" "non-free") ; fi
	if (( ${#uarchs[@]} )); then archs=("${uarchs[@]}")
	else archs=("binary-i386" "binary-amd64") ; fi
	_size_for_distro
fi

distro=debian-security
if _show_distro "$distro"; then
	baseurl=http://security.debian.org/debian-security
	if (( ${#ureleases[@]} )); then releases=("${ureleases[@]}")
	else
		releases=()
		releases+=(stable/updates)
		releases+=(testing/updates)
	fi
	if (( ${#ucomponents[@]} )); then components=("${ucomponents[@]}")
	else components=("main" "contrib" "non-free") ; fi
	if (( ${#uarchs[@]} )); then archs=("${uarchs[@]}")
	else archs=("binary-i386" "binary-amd64") ; fi
	_size_for_distro
fi

distro=linuxmint
if _show_distro "$distro"; then
	baseurl=http://packages.linuxmint.com
	if (( ${#ureleases[@]} )); then releases=("${ureleases[@]}")
	else
		releases=()
		releases+=(debian)
		releases+=(julia)
		releases+=(katya)
		releases+=(lisa)
		releases+=(maya)
	fi
	if (( ${#ucomponents[@]} )); then components=("${ucomponents[@]}")
	else components=("backport" "import" "main" "romeo" "upstream") ; fi
	if (( ${#uarchs[@]} )); then archs=("${uarchs[@]}")
	else archs=("binary-i386" "binary-amd64") ; fi
	_size_for_distro
fi

printf "%'9d MiB [%'6d GiB] - GRAND TOTAL${instlabel} SIZE\n" \
	$((total/(1024*1024))) \
	$((total/(1024*1024*1024)))
