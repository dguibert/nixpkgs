rebuild:
	nix-env -p container -I nixos-config=`pwd`/configuration_nixup.nix -I nixpkgs=`pwd` -f "<nixpkgs/nixos>" --set -A system

create: rebuild
	sudo nixos-container create nixup --system-path `realpath container`

update: stop rebuild start

stop:
	sudo nixos-container stop nixup

start:
	sudo nixos-container start nixup

login: start
	sudo nixos-container login nixup

destroy:
	sudo nixos-container destroy nixup

ssh:
	ssh test@`sudo nixos-container show-ip nixup`

profile:
	scp profile.nix test@`sudo nixos-container show-ip nixup`:.config/nixup/profile.nix

