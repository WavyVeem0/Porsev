{ config, pkgs, ... }:

{
  networking.hostName = "openvpn-server";
  networking.useDHCP = false;
  networking.networkmanager.enable = false;

  # Включение пересылки пакетов между интерфейсами
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.interfaces.ens33.ipv4.addresses = [{
    address = "100.0.13.1"; # Публичная сеть
    prefixLength = 24;
  }];
  
  networking.interfaces.ens37.ipv4.addresses = [{
    address = "192.168.13.1"; # Частная сеть
    prefixLength = 24;
  }];

  # Открытие порта UDP для туннеля
  networking.firewall.allowedUDPPorts = [ 1194 ];

  # Установка пакетов
  environment.systemPackages = with pkgs; [
    openvpn
    easyrsa
  ];
}
