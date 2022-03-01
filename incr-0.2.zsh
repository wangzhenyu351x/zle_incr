# Incremental completion for zsh
# by y.fujii <y-fujii at mimosa-pudica.net>, public domain


autoload -U compinit
zle -N self-insert self-insert-incr
# zle -N vi-cmd-mode-incr
# zle -N vi-backward-delete-char vi-backward-delete-char-incr
# zle -N backward-delete-char backward-delete-char-incr

## tab 会执行这个方法
# zle -N expand-or-complete-prefix-incr

# zle -N vi-backward-delete-char-incr
zle -N backward-delete-char-incr


# zle -N expand-or-complete-incr
# zle -N expand-or-complete expand-or-complete-incr


# zle -N 
compinit

bindkey -M emacs '^?' backward-delete-char-incr
# bindkey -M emacs '^i' expand-or-complete-prefix-incr

unsetopt automenu
compdef -d scp
compdef -d tar
compdef -d make
compdef -d java
compdef -d svn
compdef -d cvs

# TODO:
#     cp dir/

now_predict=0

incr::zecho() {
	echo $@ > /dev/ttys004
}

function limit-completion
{
	
	# incr::zecho $0 $@
	if ((compstate[nmatches] <= 1)); then
		zle -M ""
	elif ((compstate[list_lines] > 6)); then
		compstate[list]=""
		zle -M "too many matches."
	fi
}

function correct-prediction
{
	# return
	# incr::zecho  $0 $@
	if ((now_predict == 1)); then
		## 
		if [[ "$BUFFER" != "$buffer_prd" ]] || ((CURSOR != cursor_org)) ; then
			now_predict=0
		fi
	fi
}

function remove-prediction
{
	# incr::zecho  $0 $@
	if ((now_predict == 1)); then
		BUFFER="$buffer_org"
		# BUFFER='this is test by zhenyu'
		now_predict=0
	fi
}

function show-prediction
{

	# incr::zecho  'preBUFFER'$PREBUFFER $PENDING
	# assert(now_predict == 0)
	if
		((PENDING == 0)) &&
		((CURSOR > 1)) &&
		[[ "$PREBUFFER" == "" ]] &&
		[[ "$BUFFER[CURSOR]" != " " ]]
	then
		cursor_org="$CURSOR"
		buffer_org="$BUFFER"
		comppostfuncs=(limit-completion) # 
		zle complete-word
		cursor_prd="$CURSOR"
		buffer_prd="$BUFFER"
		# incr::zecho "$buffer_org[1,cursor_org]"  $buffer_prd "$buffer_prd[1,cursor_org]"
		if [[ "$buffer_org[1,cursor_org]" == "$buffer_prd[1,cursor_org]" ]]; then
			CURSOR="$cursor_org"
			BUFFER="$buffer_org"
			if [[ "$buffer_org" != "$buffer_prd" ]] || ((cursor_org != cursor_prd)); then
				now_predict=1

			fi
		else
			BUFFER="$buffer_org"
			# BUFFER="this is zhenyu edit"
			CURSOR="$cursor_org"
		fi
		# POSTDISPLAY='hahah'
		# BUFFER=$buffer_org
		echo -n "\e[32m"
	else
		zle -M ""
	fi
}


function self-insert-incr
{
	# incr::zecho  $0 $@
	correct-prediction
	remove-prediction
	if zle .self-insert; then
		show-prediction
	fi
}

function backward-delete-char-incr
{
	# incr::zecho  backward-delete-char-incr $@
	correct-prediction
	remove-prediction
	if zle backward-delete-char; then
		show-prediction
	fi
}

function expand-or-complete-incr
{
	# incr::zecho  'here'
	correct-prediction
	if ((now_predict == 1)); then
		CURSOR="$cursor_prd"
		now_predict=0
		comppostfuncs=(limit-completion)
		zle list-choices
	else
		remove-prediction
		zle .expand-or-complete
	fi
}

