{ config, pkgs, ... }:

{
  networking.hostName = "ximper-attacker";
  networking.useDHCP = false;
  
  networking.interfaces.ens33.ipv4.addresses = [{
    address = "100.0.13.3";
    prefixLength = 24;
  }];
  
  # Установленный пакет tshark или tcpdump [cite: 253]
  environment.systemPackages = with pkgs; [
    tcpdump
    tshark
  ];
}
