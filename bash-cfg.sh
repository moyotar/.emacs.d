# my bash config

export LANGUAGE=en_US.UTF-8
export TERM=xterm-256color
export LS_COLORS="$LS_COLORS:di=00;36:"
alias ls='ls --color=auto'
PS1="\w\$ "

# 根据文件名后缀进行解压,case的运用.
function extract() {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1		;;
			*.tar.gz)    tar xzf $1		;;
			*.bz2)       bunzip2 $1		;;
			*.rar)       unrar e $1		;;
			*.gz)        gunzip $1		;;
			*.tar)       tar xf $1		;;
			*.tbz2)      tar xjf $1		;;
			*.tgz)       tar xzf $1		;;
			*.zip)       unzip $1		;;
			*.Z)         uncompress $1	;;
			*.7z)        7z x $1		;;
			*.tar.xz)    tar xf $1		;;
			*)     echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

function sec2date () 
{ 
    if [ $# -lt 1 ]; then
        echo "usage:sec2date sec";
        return 1;
    fi;

    date --date="@$1"  "+%Y-%m-%d %H:%M:%S"
    return 0
}

function date2sec()
{
	if [ $# -lt 1 ]; then
		echo "usage:date2sec YYYY-mm-DD HH:MM:SS"
		return 1;
	fi

	date --date="$1" "+%s"
	return 0
}

function _emacsfunc()
{
	# Replace with `emacs` to not run as server/client
	emacsclient -t -a "" "$@"
	emacsclient -n --eval '(kill-buffer "*stdin*")' > /dev/null 2>&1
}

# An emacs 'alias' with the ability to read from stdin
function ec()
{
	# If the argument is - then write stdin to a tempfile and open the
	# tempfile.
	if [[ $# -ge 1 ]] && [[ "$1" == - ]]; then
		tempfile="$(mktemp emacs-stdin-$USER.XXXXXXX --tmpdir)"
		cat - > "$tempfile"
		_emacsfunc --eval "(find-file \"$tempfile\")" \
			   --eval '(set-visited-file-name nil)' \
			   --eval '(rename-buffer "*stdin*" t))'
		
		# At Last, rm this tmp file
		rm -f "$tmpfile" && echo "clean success" || \
				echo "clean failure"
	else
		_emacsfunc "$@"
	fi
}

#My man function. Use emacs to look up manual of commands.
function mm()
{
	if [[ $# -ne 1 || $1 == '--help' ]]; then
		echo "Usage: mm cmd"
		return 1
	fi
	man $1 > /dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "No mannual for $1"
		return 1
	fi
	man $1 | ec -
	return 0
}
