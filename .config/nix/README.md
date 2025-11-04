## Install Nix
### MacOS
```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

### Debian (rpi)
```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
nix-shell '<home-manager>' -A install

nix-shell -p nix-info --run "nix-info -m"

nix-shell -p dysk --run dysk

home-manager switch --flake .#iomallach --extra-experimental-features nix-command --extra-experimental-features flakes
home-manager switch --flake .#iomallach
```

## Raspberry Pi
### First boot
```bash
nmcli --help
```
than check the state of network interfaces.

List the ip address on the local network
```bash
ipaddr show
```

Shutdown
```bash
sudo shutdown -P now
```

Put this in bashrc/zshrc. The nix source goes there only after the package manager has been installed
```bash
export TERM=xterm-256color
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

### Install pihole
```bash
sudo curl -sSL https://install.pi-hole.net | bash
```

Caddy is going to listen on 80 and 443, so put pihole's web on different ports
```bash
sudo pihole-FTL --config webserver.port '8081o,444os,[::]:8081o,[::]:444os'
sudo systemctl restart pihole-FTL
```

### Make new tmux session
```bash
tmux new -s general
```

### Install plex media server
```bash
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

sudo apt update && sudo apt upgrade
sudo apt install plexmediaserver
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver
```

### Install openvpn
```bash
wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
sudo usermod -a -G kvm "$USER"
sudo reboot

sudo systemctl status openvpn
sudo systemctl restart openvpn-server@server
sudo sysctl net.ipv4.ip_forward
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o wlan0 -j MASQUERADE
sudo systemctl restart openvpn-server@server
```

### Install docker desktop (there is no rancher for aarch64)
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker
```

### Install caddy
```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

sudo apt install libnss3-tools
sudo caddy trust
```

Copy the config
```text
# To use your own domain name (with automatic HTTPS), first make
# sure your domain's A/AAAA DNS records are properly pointed to
# this machine's public IP, then replace ":80" below with your
# domain name.

pakberrypi.local {
        tls internal
        # Set this path to your site's directory.
        root * /usr/share/caddy

        # Enable the static file server.
        file_server

        # Another common task is to set up a reverse proxy:
        # reverse_proxy localhost:8080

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}

# Plex Media Server
plex.pakberrypi.local {
    tls internal
    reverse_proxy localhost:32400
}

# Pi-hole Admin Interface
pihole.pakberrypi.local {
    tls internal
    reverse_proxy localhost:8081
}

# Vaultwarden
vaultwarden.pakberrypi.local {
    tls internal
    reverse_proxy localhost:8080
}

filebrowser.pakberrypi.local {
   tls internal
   reverse_proxy localhost:8082
}
# Refer to the Caddy docs for more information:
# https://caddyserver.com/docs/caddyfile
```

### Run vaultwarden
```bash
sudo docker run -d   --name vaultwarden   --restart unless-stopped   -v /opt/vaultwarden/data:/data   -p 127.0.0.1:8080:80   -e DOMAIN="https://vault.pakberrypi.local"   vaultwarden/server:latest
```

### Run filebrowser
```bash
sudo docker run -v /home/iomallach/filebrowser/srv:/srv -v /home/iomallach/filebrowser/database:/database -v /home/iomallach/filebrowser:/config -e PUID=$(id -u) -e PGID=$(id -g) -p8082:80 -d filebrowser/filebrowser
```
