# nov/01/2026 18:09:21 by RouterOS 6.49.19
# software id = 
#
#
#
/interface bridge add comment=BL frame-types=admit-only-vlan-tagged name=br-lan vlan-filtering=yes
/interface ethernet set [ find default-name=ether1 ] comment="BL: WAN (S2)" name=ether1-wan
/interface ethernet set [ find default-name=ether2 ] comment="BL: trunk S1" name=ether2-trunk
/interface vlan add comment="BL: MGMT" interface=br-lan name=vlan-mgmt vlan-id=120
/interface vlan add comment="BL: USERS" interface=br-lan name=vlan-users vlan-id=220
/interface list add comment=BL name=WAN
/interface list add comment=BL name=LAN
/interface list add comment=BL name=MGMT
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/ip pool add comment=BL name=pool-users ranges=10.200.2.100-10.200.2.199
/ip dhcp-server add address-pool=pool-users disabled=no interface=vlan-users lease-time=1h name=dhcp-users
/system logging action add bsd-syslog=yes name=blremote remote=10.100.2.10 target=remote
/user group add comment=BL name=bl-ansible policy=local,ssh,ftp,reboot,read,write,policy,test,password,sensitive,api,!telnet,!winbox,!web,!sniff,!romon,!dude,!tikapp
/user group add comment=BL name=bl-monitor policy=ssh,read,test,sensitive,api,!local,!telnet,!ftp,!reboot,!write,!policy,!winbox,!password,!web,!sniff,!romon,!dude,!tikapp
/user group add comment=BL name=bl-remediate policy=read,write,policy,test,api,!local,!telnet,!ssh,!ftp,!reboot,!winbox,!password,!web,!sniff,!sensitive,!romon,!dude,!tikapp
/interface bridge port add bridge=br-lan comment=BL frame-types=admit-only-vlan-tagged ingress-filtering=yes interface=ether2-trunk
/ip neighbor discovery-settings set discover-interface-list=MGMT
/interface bridge vlan add bridge=br-lan comment="BL: MGMT" tagged=br-lan,ether2-trunk vlan-ids=120
/interface bridge vlan add bridge=br-lan comment="BL: USERS" tagged=br-lan,ether2-trunk vlan-ids=220
/interface list member add comment=BL interface=ether1-wan list=WAN
/interface list member add comment=BL interface=vlan-mgmt list=LAN
/interface list member add comment=BL interface=vlan-users list=LAN
/interface list member add comment=BL interface=vlan-mgmt list=MGMT
/ip address add address=192.168.20.22/24 comment="BL: WAN static" interface=ether1-wan network=192.168.20.0
/ip address add address=10.100.2.1/24 comment=BL interface=vlan-mgmt network=10.100.2.0
/ip address add address=10.200.2.1/24 comment=BL interface=vlan-users network=10.200.2.0
/ip dhcp-client add interface=ether1-wan
/ip dhcp-server network add address=10.200.2.0/24 comment=BL dns-server=10.200.2.1 gateway=10.200.2.1
/ip dns set allow-remote-requests=yes servers=1.1.1.1,9.9.9.9
/ip firewall filter add action=accept chain=input comment="BL: in est/rel" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="BL: in invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="BL: in icmp" protocol=icmp
/ip firewall filter add action=accept chain=input comment="BL: in mgmt ssh/winbox" dst-port=22,8291 in-interface-list=MGMT protocol=tcp src-address=10.100.2.0/24
/ip firewall filter add action=accept chain=input comment="BL: in mgmt api-ssl" dst-port=8729 in-interface-list=MGMT protocol=tcp src-address=10.100.2.0/24
/ip firewall filter add action=accept chain=input comment="BL: in users dns/dhcp" dst-port=53,67 in-interface=vlan-users protocol=udp
/ip firewall filter add action=accept chain=input comment="BL: in users dns tcp" dst-port=53 in-interface=vlan-users protocol=tcp
/ip firewall filter add action=drop chain=input comment="BL: in drop all" log=yes log-prefix=BL-IN-DROP
/ip firewall filter add action=accept chain=forward comment="BL: fwd est/rel" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="BL: fwd invalid" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="BL: users -> WAN" in-interface=vlan-users out-interface-list=WAN
/ip firewall filter add action=accept chain=forward comment="BL: mgmt -> WAN (agent: git, TI)" in-interface=vlan-mgmt out-interface-list=WAN
/ip firewall filter add action=drop chain=forward comment="BL: fwd drop all" log=yes log-prefix=BL-FWD-DROP
/ip firewall nat add action=masquerade chain=srcnat comment="BL: masq" out-interface-list=WAN
/ip route add comment="BL: default via ISP" distance=1 gateway=192.168.20.1
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set ssh address=10.100.2.0/24
/ip service set api disabled=yes
/ip service set winbox address=10.100.2.0/24
/ip service set api-ssl address=10.100.2.0/24 certificate=bl-api.crt_0
/ip ssh set strong-crypto=yes
/system clock set time-zone-name=Europe/Warsaw
/system identity set name=R2-v6
/system logging add action=blremote topics=info
/system logging add action=blremote topics=warning
/system logging add action=blremote topics=error
/system logging add action=blremote topics=critical
/system logging add action=blremote topics=account
/system ntp client set enabled=yes server-dns-names=pool.ntp.org
/tool bandwidth-server set enabled=no
/tool mac-server set allowed-interface-list=MGMT
/tool mac-server mac-winbox set allowed-interface-list=MGMT
/tool mac-server ping set enabled=no
