{ config, pkgs, ... }:
{
  networking.hostName = "client2";
  networking.useDHCP = false;
  
  networking.interfaces.enp0s3.ipv4.addresses = [{
    address = "10.0.3.10";
    prefixLength = 24;
  }];

  # Указываем Шлюз 2 как шлюз по умолчанию
  networking.defaultGateway = "10.0.3.1";
}
