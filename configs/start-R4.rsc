:local i 0
:while ([:len [/interface ethernet find name=ether5]] = 0 && $i < 30) do={ :delay 1s; :set i ($i + 1) }
/system identity set name=R4
/ip dhcp-client remove [find]
/interface list add name=WAN
/interface list add name=LAN
/interface list member add list=WAN interface=ether1
/interface list member add list=LAN interface=ether5
/ip address add address=172.20.34.2/30 interface=ether1
/ip address add address=10.50.4.1/24 interface=ether5
/ip pool add name=lan ranges=10.50.4.100-10.50.4.199
/ip dhcp-server add name=lan interface=ether5 address-pool=lan
/ip dhcp-server network add address=10.50.4.0/24 gateway=10.50.4.1
/ip firewall filter add chain=input action=accept connection-state=established,related,untracked comment="defconf: accept established,related,untracked"
/ip firewall filter add chain=input action=drop connection-state=invalid comment="defconf: drop invalid"
/ip firewall filter add chain=input action=accept protocol=icmp comment="defconf: accept ICMP"
/ip firewall filter add chain=input action=accept dst-address=127.0.0.1 comment="defconf: accept to local loopback (for CAPsMAN)"
/ip firewall filter add chain=input action=drop in-interface-list=!LAN comment="defconf: drop all not coming from LAN"
/ip firewall filter add chain=forward action=accept ipsec-policy=in,ipsec comment="defconf: accept in ipsec policy"
/ip firewall filter add chain=forward action=accept ipsec-policy=out,ipsec comment="defconf: accept out ipsec policy"
/ip firewall filter add chain=forward action=fasttrack-connection connection-state=established,related comment="defconf: fasttrack"
/ip firewall filter add chain=forward action=accept connection-state=established,related,untracked comment="defconf: accept established,related, untracked"
/ip firewall filter add chain=forward action=drop connection-state=invalid comment="defconf: drop invalid"
/ip firewall filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment="defconf: drop all from WAN not DSTNATed"
/ip firewall nat add chain=srcnat action=masquerade out-interface-list=WAN ipsec-policy=out,none comment="defconf: masquerade"
