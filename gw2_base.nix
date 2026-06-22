{ config, pkgs, ... }:

{
  networking.hostName = "vm3-router";
  networking.useDHCP = false;

  # Включение маршрутизации пакетов
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.interfaces.ens33.ipv4.addresses = [{
    address = "100.0.13.2"; # Интерфейс в публичной сети
    prefixLength = 24;
  }];
  
  networking.interfaces.ens37.ipv4.addresses = [{
    address = "192.168.113.1"; # Интерфейс в Сети 2
    prefixLength = 24;
  }];

  networking.firewall.allowedUDPPorts = [ 51820 ];
  
  # Установка WireGuard [cite: 251]
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "13.0.0.2/24" ]; 
      listenPort = 51820;
      
      # Приватный ключ должен быть предварительно сгенерирован
      privateKeyFile = "/etc/wireguard/client.key"; 
      
      peers = [{
        # Публичный ключ ВМ 2
        publicKey = "<ВСТАВЬТЕ_ПУБЛИЧНЫЙ_КЛЮЧ_ВМ2>";
        allowedIPs = [ "13.0.0.1/32" "192.168.13.0/24" ]; 
        endpoint = "100.0.13.1:51820"; 
        persistentKeepalive = 25;
      }];
    };
  };
}
