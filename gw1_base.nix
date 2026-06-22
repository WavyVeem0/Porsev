{ config, pkgs, ... }:

{
  networking.hostName = "ximper-gw1";
  networking.useDHCP = false;

  # Включение маршрутизации пакетов
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.interfaces.ens33.ipv4.addresses = [{
    address = "192.168.13.1"; # Интерфейс в Сети 1
    prefixLength = 24;
  }];
  
  networking.interfaces.ens37.ipv4.addresses = [{
    address = "100.0.13.1"; # Интерфейс в публичной сети
    prefixLength = 24;
  }];

  networking.firewall.allowedUDPPorts = [ 51820 ];

  # Установка WireGuard
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "13.0.0.1/24" ]; # IP адрес в туннеле [cite: 278]
      listenPort = 51820; # [cite: 279]
      
      # Приватный ключ должен быть предварительно сгенерирован [cite: 269]
      privateKeyFile = "/etc/wireguard/server.key"; # [cite: 281]
      
      peers = [{
        # Публичный ключ ВМ 3 [cite: 285]
        publicKey = "xhpjDKbTNga+pr/y+2PSfZOR73fXvDErps8UVntl/Xc=";
        allowedIPs = [ "13.0.0.2/32" "192.168.113.0/24" ]; # Маршруты в туннель [cite: 286]
        endpoint = "100.0.13.2:51820"; # [cite: 284]
        persistentKeepalive = 25; # [cite: 286]
      }];
    };
  };
}
