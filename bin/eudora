#!/bin/bash
#
# eudora - Launcher for Qualcomm's Eudora Mail 7 under Wine
#
#    Copyright (C) 2011 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
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
#    along with this program.  If not, see <http://www.gnu.org/licenses/gpl>.
#
#    IMPORTANT NOTE: The above copyright notice and GPL licence are for this
#    launcher and associated native files only! Eudora Mail itself is 
#    propietary software, copyright of Qualcomm Inc. Wine and its tools
#    are free software under a different copyright and license. See
#    <http://www.eudora.com> and <http://www.winehq.org>
#
# Huge thanks for all the gurus and friends in irc://irc.freenet.org/#bash
# and the contributors of http://mywiki.wooledge.org/ - Best bash source ever!
#
# TODO: use Simple MAPI for attachments
# FIXME: update manual
# FIXME: variables uppercase names
# FIXME: revamp debug

#######################################  Functions

manual()
{
cat << MANUALPAGE
eudora - launcher for Qualcomm's Eudora Mail under wine

Usage

$self [OPTIONS] [ MAILTO-URI | ADDRESS(ES)... | FILE(S)... ]

$self [OPTIONS] --raw [ARGUMENTS...]

$self { --help | --manual | --version }


Description

Eudora is a Mail Client for windows. This launcher provides a basic interface
for native enviroment to use Eudora running under Wine compatability layer.

It is not recommended for the user to directly invoke this eudora launcher
with arguments. Its main purpose is to be registered in a native desktop
environment as default email client / mailto handler, so Eudora can be
integrated and used as a native email client by tools like xdg-email, Nautilus'
"Send to -> Email", Simple Scan, Web browser "mailto:" links, etc.

After eudora is set as default email client, it is strongly encouraged that
xdg-email tool is used for launching eudora, by both direct user invocation
and scripting. It has features like URI encoding, exit codes for missing files,
and its command-line options are much more user-friendly.


Options

Eudora and email options:

MAILTO-URI
    A mailto uri in the format "mailto:[ADDRESS][?OPTION[&OPTION(S)...]]",
    according to RFC2368. Valid OPTIONS are "to=ADDRESS", "cc=ADDRESS",
    "bcc=ADDRESS", "subject=SUBJECT", "body=BODY". Aditionaly, "attach=FILE",
    while not part of RFC2368, is also accepted.

    Some mailto uri examples:
    mailto:aaa@aaa.com?subject=hello&body=Email%20test
    mailto:attach=/dir/file1&attach=/dir/file2

    Since mailto uri is not parsed (except for attachments, see note below), 
    and must be properly encoded, it is highly recommended that xdg-email
    utility is used to compose the mailto uri and invoke eudora.

    If any valid attachment is present in the uri, all other fields are ignored
    See Attachments section for details and limitations on attachment handling.

ADDRESS(ES)...
	A valid (list of) email address(es). If any character other than letters,
	digits or @.-\/ are present in the address, it must be properly url-encoded.
	
	As with mailto uri, it is highly recommended that xdg-email utility is used
	to compose the mailto uri and invoke eudora.
	
FILE(S)...
    A (list of) file to be sent as attachment. If any valid file is given, any
    mailto uri or address(es) are ignored. See Attachments section for details
    and limitations on attachment handling. Files are required to be present
    after eudora returns. Test for Eudora.exe process if deleting temporary
    files is required.

Settings and control options:

--wineprefix DIR
    Path to wine's virtual windows environment where Eudora Mail is installed.

--exefolder DIR
   Unix path where Eudora is installed

--datafolder DIR
   Unix path to Eudora's data Folder (User settings, emails and mailboxes)

--debug
    Turns on shell attribute x (set -x), to print commands and their arguments
    as they are executed, and redirects all output that otherwise would be
    silenced to CONFIG/eudora.log (see Configuration Files section).
    
--raw
    Relay all command-line arguments (except --raw itself and --debug) directly
    to Eudora.exe windows executable. No parsing of addresses, mailto: URI, file
    handling or translation from unix paths to windows paths is performed.
    For testing purposes only.

Above options take precence over environment variables or settings in the
configuration file. See Enviroment Variables and Configuration Files for details.

Generic options:

--help
    Show command synopsis.

--manual
    Show this manualpage.

--version
    Show the launcher version information.


Attachments

Eudora.exe accepts as command line arguments either a mailto uri OR a list of
filenames to be attached, but not both. Furthermore, any "attach" field of a 
mailto uri is silently ignored, since it is not part of original RFC2368
specification. Thus, it is currently not possible to launch Eudora.exe with both
attachments and other (to, cc, bcc, subject, body) fields.

So, when an "attach" field is present is in the mailto uri, file is tested and,
if valid, it is passed as command line argument and the mailto uri argument is
discarted. Any other valid files passed directly in command line also makes
eudora (this launcher) silently ignore and discart any mailto uri before
launching Eudora.exe

Valid files are the ones that satisfy ALL following conditions:

- File must exist and not be a directory

- Full path must contain a target mapped to a wine drive (C:, D:, Z: etc)
  or contain a target of one of wine's user folders (My Documents, Desktop, 
  My Pictures, etc - usually mapped via winecfg's Desktop Integration to native
  user folders \$HOME, $\HOME/Desktop, \$HOME/Pictures etc)

- Due to a bug in Eudora.exe not properly handling escaping characters, file
  name and path, when translated to a windows syntax path, must not cointain any
  spaces

All non-valid files, either from mailto uri or command line, are silently
ignored.

All file names and paths, in both mailto uri or command line argument, must use
Unix syntax (/path/to/file). Files attached via mailto uri may start with a
"file://" prefix (that is stripped before testing) and must be url encoded.
Url decode and translation to windows path syntax (C:\path\to\file) is performed
by eudora. Relative paths are accepted and properly translated.


Environment Variables

eudora honours the following environment variables, which takes precedence over
settings in the cofiguration file but may be overriden by respective command 
line options.

WINEPREFIX
    Path to wine's virtual windows environment where Eudora Mail is installed.
    See wine documentation for more details. Default is "\$HOME/.wine"

EUDORA_EXEFOLDER
    The full (unix) path where Eudora is installed (where Eudora.exe is located)
    Default is "\$WINEPREFIX/dosdevices/c:/Program Files/Qualcomm/Eudora"

EUDORA_DATAFOLDER
    The full (unix) path to Eudora's Data Folder, which stores user's mailboxes
    and settings. Default is:
    "\$WINEPREFIX/dosdevices/c:/users/\$USER/Application Data/Qualcomm/Eudora"

EUDORA_DEBUG
    If set to any value, will trigger Debug mode. See --debug in Options section

EUDORA_RAW
    If set to any value, will trigger Raw mode. See --raw in Options section

wine, used internally to launch Eudora, is also affected by several other 
environment variables, such as WINEPATH and WINEDEBUG, and can affect eudora.


Configuration files

All configuration files are stored in \$HOME/.eudora ($HOME/eudora
for this user). The following are used:

eudora.log
	Dump of execution commands when debug mode is activated
	
eudora.conf
    Contains default settings for environment variables, in VAR=value format.
    This file will be sourced by this launcher, so #comments are allowed but
    extra caution must be taken with its syntax. These settings may be 
    overriden by environment variables or respective command line options


Exit Codes

An exit code of 0 indicates success while a non-zero exit code indicates
failure. The following failure codes can be returned:

1   Something bad happened


Examples

$self mailto:someone@somewhere.com

$self mailto:eudora@qualcomm.com?cc=a@b.c&subject=Eudora+Lives&body=..kind+of

$self /tmp/somefile.txt

$self mailto:?attach=/tmp/AttachMe&attach=file:///tmp/AndMe' ../test/MeToo.txt

$self /tmp/OkToAttach.jpg "/tmp/no spaces allowed.mp3" /tmp/SorryNoDirsEither/

$self mailto:dontmix@withattaches.com?body=i+will+be+ignored&attach=/tmp/file


Written by

Rodigo Silva (MestreLion) <linux@rodrigosilva.com>


Licenses and Copyright

Copyright (C) 2011 Rodigo Silva (MestreLion) <linux@rodrigosilva.com>.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

IMPORTANT NOTE: The above copyright notice and GPL licence are for this launcher
and associated native files only! Eudora Mail itself is propietary software,
copyright of Qualcomm Inc. Wine and its tools are free software under different
copyright and license. See <http://www.eudora.com> and <http://www.winehq.org>

MANUALPAGE
}

usage()
{
cat << USAGE
Usage: $self [OPTIONS] [ MAILTO-URI | ADDRESS(ES)... | FILE(S)... ]
       $self [OPTIONS] --raw [ARGUMENTS...]
       $self { --help | --manual | --version }

Launches Eudora Mail under Wine

Options:
--wineprefix DIR  Unix path to wine's windows environment where Eudora Mail is
--exepath DIR     Unix path where Eudora.exe is located
--datafolder DIR  Unix path to Eudora's data Folder
--debug           Turns on debug mode
--raw             Relay all command-line arguments unparsed to Eudora.exe

Use "$self --manual" for additional info
USAGE
}

version() {
cat << VERSION
$self 1.0

Copyright (C) 2011 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Eudora Mail is a copyright of Qualcomm Inc. See <http://www.eudora.com>
For wine copyright and license, see <http://www.winehq.com>

Launcher written by Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
VERSION
}

debug() {
	exec 3>>"$HOME/.config/eudora/eudora.log" 1>&3 2>&3
	printf '\n\n%s - Eudora starting\n' "$(date --rfc-3339 seconds)"
	printf 'Arguments:' ; printf ' %q' "${args[@]}" ; printf '\n'
	set -x
}

fix_crash() {

	if [[ ! -e "$EUDORA_DATAFOLDER/OWNER.LOK" ]] || \
	   { ps -A | grep -qi Eudora.exe ; }
	then return ; fi
	
	local msg

	case "$LANG" in
	pt*)
		msg+="Eudora parece ter falhado da última vez. "
		msg+="Você gostaria de tentar consertar?\n\n"
		msg+="(isso vai apenas fechar as janelas de caixas de correio. "
		msg+="Nenhuma mensagem será apagada ou perdida.)"
		;;
	*  )
		msg+="Looks like Eudora has crashed last time. "
		msg+="Would you like me to try to fix that?\n\n"
		msg+="(that will close all your currently opened mailboxes tough. "
		msg+="No messages will be deleted or lost)"
		;;
	esac
	
	zenity --question --no-wrap --title="Eudora" --text="$msg" || return
	
	ini=$( awk '
		BEGIN { RS="\r\n"; ORS=RS; ok=1 }
		/^\[Open Windows\]/ { ok=0; next }
		/^\[/ { ok=1 }
		ok { print }
		' "$EUDORA_DATAFOLDER/eudora.ini"
	)
	printf "%s\r\n" "$ini" > "$EUDORA_DATAFOLDER/eudora.ini"
	rm -f -- "$EUDORA_DATAFOLDER/OWNER.LOK"
}


load_settings() {

	# eudora_conf: fac, env, arg
	# wineprefix: fac, conf, env, arg
	# others: fac, conf, arg
	local FAC_EUDORA_CONFIG="$HOME/.config/eudora/eudora.conf"

	# Save wineprefix env
	ENV_WINEPREFIX="$WINEPREFIX"

	# load config file
	config="${ARG_EUDORA_CONFIG:-"$EUDORA_CONFIG"}"
	config="${config:-"$FAC_EUDORA_CONFIG"}"
	[[ -r "$config" ]] && source "$config"
	
	# Load wineprefix
	WINEPREFIX="${WINEPREFIX:-"$HOME"/.wine}"
	[[ "$ENV_WINEPREFIX" ]] && WINEPREFIX="$ENV_WINEPREFIX" 
	[[ "$ARG_WINEPREFIX" ]] && WINEPREFIX="$ARG_WINEPREFIX" 

	# Load other variables factory values
	EUDORA_EXEFOLDER="${EUDORA_EXEFOLDER:-"$WINEPREFIX/dosdevices/c:/Program Files/Qualcomm/Eudora"}"
	EUDORA_DATAFOLDER="${EUDORA_DATAFOLDER:-"$WINEPREFIX/dosdevices/c:/users/$USER/Application Data/Qualcomm/Eudora"}"
	EUDORA_WINDOW="${EUDORA_WINDOW:-restored}"
	
	# Other variables argument values
	[[ "$ARG_EUDORA_EXEFOLDER"  ]] && EUDORA_EXEFOLDER="$ARG_EUDORA_EXEFOLDER"
	[[ "$ARG_EUDORA_DATAFOLDER" ]] && EUDORA_DATAFOLDER="$ARG_EUDORA_DATAFOLDER"
	[[ "$ARG_EUDORA_WINDOW"     ]] && EUDORA_WINDOW="$ARG_EUDORA_WINDOW"
	[[ "$ARG_EUDORA_RAW"        ]] && EUDORA_RAW="$ARG_EUDORA_RAW"
	[[ "$ARG_EUDORA_DEBUG"      ]] && EUDORA_DEBUG="$ARG_EUDORA_DEBUG"
	
	# Write settings
	[[ -f "$FAC_EUDORA_CONFIG" ]] || {
		mkdir -p "${FAC_EUDORA_CONFIG%/*}/"
		cat > "$FAC_EUDORA_CONFIG" <<- LOADSETTINGS
		# Eudora settings file
		# Use shell syntax only
		# For additional info, see "$self --manual"
		WINEPREFIX="$WINEPREFIX"
		EUDORA_EXEFOLDER="${EUDORA_EXEFOLDER/"$WINEPREFIX"/\$WINEPREFIX}"
		EUDORA_DATAFOLDER="${EUDORA_DATAFOLDER/"$WINEPREFIX"/\$WINEPREFIX}"
		EUDORA_WINDOW="$EUDORA_WINDOW"
		EUDORA_RAW="$EUDORA_RAW"
		EUDORA_DEBUG="$EUDORA_DEBUG"
		LOADSETTINGS
	}
	
	# translate window setting to real value
	case "${EUDORA_WINDOW,,}" in
	min*) EUDORA_WINDOW="/M"   ;;
	max*) EUDORA_WINDOW="/MAX" ;;
	*   ) EUDORA_WINDOW="/R"   ;;
	esac
}


# search for an alternate path for a unix file,
# based on wine's user profile dirs (Desktop, My Pictures, etc)
userprofile_search() {

	local unixfile="$1"
	local dir
	local key
	local list

	# create profile map only once	
	if [[ ${#profilemap[@]} = 0 ]]; then

		# Loop wine's user folder, for symlinks to filesystem dirs
		# (so files in ~/Desktop, ~/Music, etc are correctly translated
		# by winepath even if wine has no "Z:\ => /" mapping)
		# (reference: cmd switches qksautc)
		dir=$( wine winepath -u \
		       "$(wine cmd /c echo '%USERPROFILE%'|cut -d$'\r' -f1)" )
		if [[ -d "$dir" ]]; then
			list=("$dir"/*)
			for dir in "${list[@]}"; do
				key=$(readlink -s "$dir")
				[[ -h "$dir" ]] && profilemap[${key%/}]="${dir%/}"
			done
		fi
		[[ "$EUDORA_DEBUG" ]] && declare -p profilemap
	fi

	# winepath with no options nicely convert from relative to absolute
	# without canonicalizing it, but give weird results if file already absolute
	[[ "$unixfile" = /* ]] || unixfile=$( wine winepath "$1" )
	
	# loop profile map and try to get a match
	while IFS= read -rd '' dir; do
		if [[ "${unixfile%/*}/" = "$dir"/* ]]; then
			
			result="${profilemap[$dir]}${unixfile#$dir}"
			return
		fi
	done < <(printf '%s\0' "${!profilemap[@]}" | sort -z --reverse)
	
	result=""
}

# Translate file from unix path to windows path
translate_file() {

	local unixfile="$1"
	local winfile=""

	# File must exist and not be a directory
	if [[ -e "$unixfile" && ! -d "$unixfile" ]]; then
	
		# Get the windows path
		winfile=$(wine winepath -w "$unixfile")
		
		# Check if file was not succesfully mapped
		if [[ "$winfile" = \\\\\?\\unix\\* ]]; then
			
			# Try to map to a user folder
			userprofile_search "$unixfile"
			[[ "$result" ]] && winfile=$(wine winepath -w "$result")			
		fi
		
		# Lame eudora does not support filenames with espaces (not even quoted)
		[[ "$winfile" = *[[:blank:]]* ]] && winfile=""		
	fi
	
	result="$winfile"
}

# Look for attachments in mailto: url
read_mailto_attachments() {
	
	local url="${1#mailto:}"
	local querystring="${url#*\?}"
	local field
	local value
	local userfile
	
	while IFS="=" read -r field value; do
		if [[ "${field,,}" = "attach" ]]; then
			userfile=$(echo "$value"|sed 's/^file:\/\///;s/+/ /g;s/%/\\x/g')
			files+=( "$(echo -e "$userfile")" )
		fi
	done <<< "${querystring//&/$'\n'}"
}

# not used, for now...
parse_mailto() {
	
	local url="${1#mailto:}"
	local querystring="$url"
	local to
	local field
	local value
	local options
	
	if [[ "$url" = *\?* ]]; then
		IFS="?" read -r to querystring <<< "$url"
		options=" --to $to"
	fi
	
	while IFS="=" read -r field value; do
		options+=" --$field $value"
	done <<< "${querystring//&/$'\n'}"
}


####################################### Main

exec 3>/dev/null # to avoid harcoding /dev/null everywhere. For tools' stderr.

self="${0##*/}" # buitin $(basename $0)

while [[ $# -gt 0 ]]; do
	
	arg="$1"
	shift
	
	case "$arg" in
	
	--help   ) usage   ; exit ;;
	--manual ) manual  ; exit ;;
	--version) version ; exit ;;
	
	--debug  ) ARG_EUDORA_DEBUG=1 ;;
	--raw    ) ARG_EUDORA_RAW=1   ;;
	
	--wineprefix) ARG_WINEPREFIX="$1"        ; shift ;;
	--exepath   ) ARG_EUDORA_EXEFOLDER="$1"  ; shift ;;
	--datafolder) ARG_EUDORA_DATAFOLDER="$1" ; shift ;;
	--window    ) ARG_EUDORA_WINDOW="$1"     ; shift ;;
	--config    ) ARG_EUDORA_CONFIG="$1"     ; shift ;;	
	
	mailto:*) args+=( "$arg" ); mailto="$arg";;
	
	*@*)
		args+=( "$arg" )
        if [[ "$mailto" ]] ; then
            recipients+="to=${arg}&"
        else
			mailto="mailto:${arg}?"
        fi
        ;;

	*) args+=( "$arg" ); files+=( "$arg" ) ;;
	
	esac
done

load_settings

export WINEPREFIX

unset profilemap; declare -A profilemap
unset output    ; declare -a output
unset result    ; declare result

[[ "$EUDORA_DEBUG" ]] && debug

if [[ "$EUDORA_RAW" ]]; then
	output=( "${args[@]}" )
else

	# handle mailto args
	if [[ "$mailto" ]]; then
	
		# add recipients
		case "$mailto" in
		*\? ) mailto="${mailto}${recipients}"  ;;
		*\?*) mailto="${mailto}&${recipients}" ;;
		*   ) mailto="${mailto}?${recipients}" ;;
		esac

		# Strip trailing ? and &
		mailto="$(echo "${mailto}"| sed 's/[?&]$//')"
		
		read_mailto_attachments "$mailto"
	fi
	
	# handle file args
	for file in "${files[@]}"; do
		translate_file "$file"
		[[ "$result" ]] && output+=( "$result" )
	done
	
	# Eudora can handle either mailto: or attachments, but not both
	[[ "${#output[@]}" -gt 0 ]] || output=( "$mailto" )
fi

fix_crash

cd "$EUDORA_EXEFOLDER" || exit 1
wine "C:\\windows\\command\\start.exe" "$EUDORA_WINDOW" ./Eudora.exe "${output[@]}" 2>&3

