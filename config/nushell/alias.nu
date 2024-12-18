alias winget = winget.exe
alias neovide = neovide.exe --wsl
alias nivm = nvim

alias nue = nvim ~/dotnix/config/nushell/config.nu ;
alias nuee = nvim ~/dotnix/config/nushell/env.nu ;
alias nuea = nvim ~/dotnix/config/nushell/alias.nu ;

alias win = cd /mnt/c/Users/pande
alias windev = cd /mnt/c/Users/pande/dev
alias windl = cd /mnt/c/Users/pande/Downloads

alias :e = nvim
alias :q = exit
alias eixt = exit

alias ni = nix-env -f '<nixpkgs>' -iA

alias cp = cp -ir
alias df = df -h
alias free = free -m
alias np = nano -w PKGBUILD
alias more = less

alias j = z

alias ns = nix-shell shell.nix --command "nu"
alias nsp = nix-shell --command "nu" -p

alias clonec = git clone --depth 1 (xclip -selection clipboard -o)
alias wgetc = wget -c (xclip -selection clipboard -o)

alias commit = git commit -m
alias commita = git commit -am
alias push = git push
alias psuh = git push

alias cls = clear
export def --env cmd [d] { ^mkdir -p $d; cd $d }

def hme [] {
	cd ~/.config/home-manager/ ;
	nvim ~/.config/home-manager/home.nix ;
	home-manager switch --log-format bar-with-logs;
	~/.config/home-manager/result/activate ;
	rm -fr ~/.config/home-manager/result ;
	cd -
}

def noe [] {
	sudo -E nvim /etc/nixos/configuration.nix ;
	sudo nixos-rebuild switch nix-build --log-format bar-with-logs
}

def cleansys [] {
	^df -h /
		sudo nix-collect-garbage -d
		^df -h /
		sudo journalctl --vacuum-time=3d
		^df -h /
		rm -fr ~/.cache/thumbnails ~/.local/share/baloo
		^df -h /
		python3 -m pip cache purge
		^df -h /
		npm cache clean --force
		^df -h /
		python2 -m pip cache purge
		^df -h /
		go clean --modcache
		^df -h /
		^find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
		^df -h /
}

def cmg [] {
	rm -fr compile_commands.json ;
	cmake -D CMAKE_EXPORT_COMPILE_COMMANDS=ON -S . -B Debug ;
	compdb -p Debug/ list | save compile_commands.json

}
alias cmb = cmake --build Debug/
alias cmc = rm -fr CMakeCache.txt CMakeFiles Debug/ compile_commands.json


alias cso = xclip -selection clipboard -o
alias cs = xclip -selection clipboard

alias f = fuck
alias idea = nvim /home/shawn/dev/ideas.txt
alias l = ls -la

alias md = mkdir

alias py = python3

alias sizeof = du -h --max-depth=0

alias sl = ls

alias tls = clear

alias tree = tre

def weather [] {
	curl wttr.in ;
 	curl "wttr.in?format=1" ;
 	curl "wttr.in?format=2";
 	curl "wttr.in?format=3" ;
 	curl "wttr.in?format=4" ;
 	curl wttr.in/moon
}


alias taskkill = taskkill.exe /F /IM
alias wsl = wsl.exe
alias pwsh = pwsh.exe


def zf [] {
	zoxide query --list --score |
		fzf --height 40% --layout reverse --info inline --border --preview "eza --all --group-directories-first --header --long --no-user --no-permissions --color=always {2}" --no-sort |
		awk '{print $2}'
}
