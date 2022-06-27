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


zle -N expand-or-complete-incr
# zle -N expand-or-complete-prefix expand-or-complete-incr
# zle -N expand-or-complete expand-or-complete-incr


# zle -N 
compinit

bindkey -M emacs '^?' backward-delete-char-incr
# tab 执行的动作
bindkey -M emacs '^i' expand-or-complete-incr

unsetopt automenu
compdef -d scp
compdef -d tar
compdef -d make
compdef -d java
compdef -d svn
compdef -d cvs

incr::zecho() {
	# echo $@ > /dev/ttys000
	
}

function limit-completion
{
	incr::zecho $0
	# incr::zecho $0 $@
	if ((compstate[nmatches] <= 0)); then
		zle -M ""
	elif ((compstate[list_lines] > 6)); then
		compstate[list]=""
		zle -M "too many matches."
	fi
}

function show-prediction
{
	if
		((PENDING == 0)) &&
		((CURSOR > 1)) &&
		[[ "$PREBUFFER" == "" ]] &&
		[[ "$BUFFER[CURSOR]" != " " ]]
	then
		comppostfuncs=(limit-completion) 
		zle list-choices
		echo -n "\e[32m"
	else

		zle -M ""
	fi
}


function self-insert-incr
{
	incr::zecho  $0 $@
	if zle .self-insert; then
		show-prediction
	fi
}

function backward-delete-char-incr
{
	# incr::zecho  backward-delete-char-incr $@
	incr::zecho $0
	if zle backward-delete-char; then
		show-prediction
	fi
}


function expand-or-complete-incr
{
	incr::zecho  'here'
	if [[ -n $BUFFER ]]; then
		# echo 'complete_predict' > /dev/ttys000
		zle expand-or-complete
	else
		BUFFER="cd " 
		zle end-of-line
		comppostfuncs=(limit-completion)
		zle list-choices
	fi
}

