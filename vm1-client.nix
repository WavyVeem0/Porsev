{ config, pkgs, ... }:

{
  networking.hostName = "openvpn-client";
  networking.useDHCP = false;
  networking.networkmanager.enable = false;
  
  networking.interfaces.ens33.ipv4.addresses = [{
    address = "100.0.13.2";
    prefixLength = 24;
  }];

  # Установка пакетов для работы OpenVPN и генерации ключей
  environment.systemPackages = with pkgs; [
    openvpn
    easyrsa
  ];
}
