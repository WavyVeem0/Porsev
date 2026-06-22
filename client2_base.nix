{ config, pkgs, ... }:

{
  networking.hostName = "ximper-client2";
  networking.useDHCP = false;
  
  networking.interfaces.ens33.ipv4.addresses = [{
    address = "192.168.113.10";
    prefixLength = 24;
  }];
  
  # Шлюз по умолчанию указывает на ВМ 3
  networking.defaultGateway = "192.168.113.1";
}
