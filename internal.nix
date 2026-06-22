{ config, pkgs, ... }:

{
  networking.hostName = "internal-node";
  networking.useDHCP = false;
  networking.networkmanager.enable = false;
  
  networking.interfaces.ens33.ipv4.addresses = [{
    address = "192.168.13.10";
    prefixLength = 24;
  }];
  
  # Шлюзом по умолчанию выступает ВМ 2 (Сервер OpenVPN)
  networking.defaultGateway = "192.168.13.1";
}
