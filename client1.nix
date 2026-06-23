{ config, pkgs, ... }:
{
  networking.hostName = "client1";
  networking.useDHCP = false;
  
  networking.interfaces.enp0s3.ipv4.addresses = [{
    address = "192.168.10.10";
    prefixLength = 24;
  }];

  # Указываем Шлюз 1 как шлюз по умолчанию
  networking.defaultGateway = "192.168.10.1";
}
