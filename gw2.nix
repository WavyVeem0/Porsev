{ config, pkgs, lib, ... }:

let
  # Переменные Шлюза 2 (ОТЗЕРКАЛЕНЫ)
  localIp = "10.0.2.2";          # Внешний IP этого шлюза (Сеть 2)
  remoteIp = "10.0.2.1";         # Внешний IP первого шлюза
  remoteSubnet = "192.168.10.0/24"; # Внутренняя сеть за первым шлюзом (Сеть 1)
  tunnelIpLocal = "172.16.0.2/23"; # IP туннеля для Шлюза 2 (другой IP в той же подсети)
in
{
  networking.hostName = "gateway2";
  networking.useDHCP = false;

  # Форвардинг пакетов
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # Физические интерфейсы
  networking.interfaces.enp0s3.ipv4.addresses = [{
    address = "10.0.2.2";     # Сеть 2 (Транзитная)
    prefixLength = 24;
  }];
  networking.interfaces.enp0s8.ipv4.addresses = [{
    address = "10.0.3.1";     # Сеть 3 (Внутренняя)
    prefixLength = 24;
  }];

  # Пакеты и модули
  environment.systemPackages = with pkgs; [ iproute2 tcpdump wireshark-cli ];
  boot.kernelModules = [ "fou" ];

  # --- ТУННЕЛИ ---
  systemd.services = {
    # 4.1: IPIP
    tunnel-ipip = {
      description = "IPIP Tunnel (Task 4.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 ];
      script = ''
        ip tunnel add ipip0 mode ipip local ${localIp} remote ${remoteIp}
        ip addr add ${tunnelIpLocal} dev ipip0
        ip link set ipip0 up
        ip route add ${remoteSubnet} dev ipip0
      '';
      preStop = "ip link delete ipip0 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 5.1: VTI (IPsec)
    tunnel-vti = {
      description = "VTI Tunnel with IPsec (Task 5.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 ];
      script = ''
        ip link add name vti1 type vti key 111 local ${localIp} remote ${remoteIp}
        ip addr add ${tunnelIpLocal} dev vti1
        ip link set vti1 up
        # ВНИМАНИЕ: Зеркальные SPI. SPI 2 для исходящего, SPI 1 для входящего
        ip xfrm state add src ${localIp} dst ${remoteIp} proto esp spi 2 reqid 1 mode tunnel
        ip xfrm state add src ${remoteIp} dst ${localIp} proto esp spi 1 reqid 1 mode tunnel
        ip xfrm policy add dir in tmpl src ${remoteIp} dst ${localIp} proto esp reqid 1 mode tunnel mark 111
        ip xfrm policy add dir out tmpl src ${localIp} dst ${remoteIp} proto esp reqid 1 mode tunnel mark 111
        ip route add ${remoteSubnet} dev vti1
      '';
      preStop = "ip xfrm policy flush; ip xfrm state flush; ip link delete vti1 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 6.1: GRE
    tunnel-gre = {
      description = "GRE Tunnel (Task 6.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 ];
      script = ''
        ip link add name gre1 type gre local ${localIp} remote ${remoteIp} seq key 12345
        ip addr add ${tunnelIpLocal} dev gre1
        ip link set gre1 up
        ip route add ${remoteSubnet} dev gre1
      '';
      preStop = "ip link delete gre1 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 7.1: GRETAP
    tunnel-gretap = {
      description = "GRETAP Tunnel (Task 7.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 pkgs.coreutils ];
      script = ''
        ip link add name gretap1 type gretap local ${localIp} remote ${remoteIp}
        # Уникальный MAC для интерфейса на 2-ом шлюзе
        ip link set dev gretap1 address 02:00:00:00:00:11
        ip addr add ${tunnelIpLocal} dev gretap1
        ip link set gretap1 up
        ip route add ${remoteSubnet} dev gretap1
        echo 1 > /proc/sys/net/ipv4/conf/gretap1/proxy_arp
      '';
      preStop = "ip link delete gretap1 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 8.1: FOU
    tunnel-fou = {
      description = "FOU Tunnel (Task 8.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 ];
      script = ''
        ip fou add port 5555 ipproto 4
        ip link add name fou1 type ipip remote ${remoteIp} local ${localIp} ttl 225 encap fou encap-sport auto encap-dport 5555
        ip addr add ${tunnelIpLocal} dev fou1
        ip link set fou1 up
        ip route add ${remoteSubnet} dev fou1
      '';
      preStop = "ip link delete fou1 || true; ip fou del port 5555 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 9.1: GUE
    tunnel-gue = {
      description = "GUE Tunnel (Task 9.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 ];
      script = ''
        ip fou add port 5555 gue
        ip link add name gue1 type ipip remote ${remoteIp} local ${localIp} encap gue encap-sport auto encap-dport 5555
        ip addr add ${tunnelIpLocal} dev gue1
        ip link set gue1 up
        ip route add ${remoteSubnet} dev gue1
      '';
      preStop = "ip link delete gue1 || true; ip fou del port 5555 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 10.1: GENEVE
    tunnel-geneve = {
      description = "GENEVE Tunnel (Task 10.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 pkgs.coreutils ];
      script = ''
        ip link add name geneve1 type geneve id 100 remote ${remoteIp}
        ip link set dev geneve1 address 02:00:00:00:00:12
        ip addr add ${tunnelIpLocal} dev geneve1
        ip link set geneve1 up
        ip route add ${remoteSubnet} dev geneve1
        echo 1 > /proc/sys/net/ipv4/conf/geneve1/proxy_arp
      '';
      preStop = "ip link delete geneve1 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };

    # 11.1: ERSPAN
    tunnel-erspan = {
      description = "ERSPAN Tunnel (Task 11.1)";
      after = [ "network.target" ];
      # wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 pkgs.coreutils ];
      script = ''
        ip link add name erspan1 type erspan local ${localIp} remote ${remoteIp} seq key 10 erspan_ver 1 erspan 123
        ip link set dev erspan1 address 02:00:00:00:00:13
        ip addr add ${tunnelIpLocal} dev erspan1
        ip link set erspan1 up
        ip route add ${remoteSubnet} dev erspan1
        echo 1 > /proc/sys/net/ipv4/conf/erspan1/proxy_arp
      '';
      preStop = "ip link delete erspan1 || true";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    };
  };
}
