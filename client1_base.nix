{ config, pkgs, ... }:

{
  networking.hostName = "ximper-client1";
  networking.useDHCP = false;
  
  networking.interfaces.ens33.ipv4.addresses = [{
    address = "192.168.13.10";
    prefixLength = 24;
  }];
  
  # Шлюз по умолчанию указывает на ВМ 2
  networking.defaultGateway = "192.168.13.1";
}
