# About IP Address

- 📚 [Network Articles](https://datacadamia.com/network/start)
- 📚 [IPv6 Tutorial](https://www.tutorialspoint.com/ipv6/index.htm)
- 🌐 [IPv6 and SNMP](https://www.snmp.com/protocol/ipv6.shtml)

## IANA

- 🌐 [Reserved Example Domains](https://www.iana.org/help/example-domains)
- 🌐 [IPv6 Address Space](https://www.iana.org/assignments/ipv6-address-space)
- 🌐 [IPv4 Multicast Address Space Registry](https://www.iana.org/assignments/multicast-addresses)
- 🌐 [IPv6 Multicast Address Space Registry](https://www.iana.org/assignments/ipv6-multicast-addresses)
- 🌐 [IANA IPv6 Special-Purpose Address Registry](https://www.iana.org/assignments/iana-ipv6-special-registry)

## RFC

- 🌐 [rfc6890](https://datatracker.ietf.org/doc/html/rfc6890) ⬳
     [Special-Purpose IPv4/IPv6 Address](https://www.rfc-editor.org/rfc/rfc6890)
- 🌐 [rfc5453](https://datatracker.ietf.org/doc/html/rfc5453) ⬳
     [Reserved IPv6 Interface Identifiers](https://www.rfc-editor.org/rfc/rfc5453)
- 🌐 [rfc4291](https://datatracker.ietf.org/doc/html/rfc4291) ⬳
     [IPv6 Address Architecture](https://www.rfc-editor.org/rfc/rfc4291)
- 🌐 [rfc4007](https://datatracker.ietf.org/doc/html/rfc4007) ⬳
     [IPv6 Scoped Address Architecture](https://www.rfc-editor.org/rfc/rfc4007)
- 🌐 [rfc7346](https://datatracker.ietf.org/doc/html/rfc7346) ⬳
     [IPv6 Multicast Address Scopes](https://www.rfc-editor.org/rfc/rfc7346)
- 🌐 [rfc4193](https://datatracker.ietf.org/doc/html/rfc4193) ⬳
     [IPv6 Unique Local Unicast Addresses](https://www.rfc-editor.org/rfc/rfc4193) ⬳
     [Private Address Generator](https://v6tools.kasperd.dk/rfc4193)

## Online Tools

- ⚒ [IPv6 Private Address Generator by simpledns](https://simpledns.plus/private-ipv6)
- ⚒ [IPv6 Private Address Generator by dnschecker](https://dnschecker.org/ipv6-address-generator.php)

## FAQ

- 💬 [Difference between `127.0.0.1` and `127.0.1.1`](https://serverfault.com/questions/925136)
- 💬 [IPv6 loopback-addresses equivalent to `127.x.x.x`](https://serverfault.com/questions/193377)
- 🗄 [Steven Black](http://stevenblack.com) [hosts](https://github.com/StevenBlack/hosts)
  💬 [What does the record mean?](https://superuser.com/questions/1407575)

## IPv6 地址格式

A=10, B=11, C=12, D=13, E=14, F=15

- 标记 `G` -> Global ID, `S` -> Subnet ID, `X` -> Interface ID
- 格式 `GGGG GGGG GGGG SSSS   XXXX XXXX XXXX XXXX`    全局地址(Global-Unicast)
- 格式 `fcGG GGGG GGGG SSSS   XXXX XXXX XXXX XXXX`    私用地址(Unique-Local)
  [rfc4193(`fc00::/7`)](https://datatracker.ietf.org/doc/html/rfc4193)
- 格式 `fdGG GGGG GGGG SSSS   XXXX XXXX XXXX XXXX`    私用地址(Unique-Local)
  [rfc4193(`fc00::/7`)](https://datatracker.ietf.org/doc/html/rfc4193)
- 格式 `fe80 0000 0000 0000   XXXX XXXX XXXX XXXX`    本地链路(Link-Local)
  [rfc4291(2.5.6节)](https://datatracker.ietf.org/doc/html/rfc4291)
- 格式 `fecS SSSS SSSS SSSS   XXXX XXXX XXXX XXXX`    本地站点(Site-Local)
  [rfc3879(弃用 `fec0::/10`)](https://datatracker.ietf.org/doc/html/rfc3879)
- 格式 `ffYZ GGGG GGGG GGGG   GGGG GGGG GGGG GGGG`    多播地址(Multicast-Addresses)
  [rfc4291(2.7节)](https://datatracker.ietf.org/doc/html/rfc4291#section-2.7)
- [特殊地址](https://datatracker.ietf.org/doc/html/rfc6890)
  `0000 0000 0000 0000   0000 0000 0000 0000`         无效地址(Unspecified-Address)
- [特殊地址](https://datatracker.ietf.org/doc/html/rfc6890)
  `0000 0000 0000 0000   0000 0000 0000 0001`         回路地址(Loopback-Address)
- [特殊地址](https://datatracker.ietf.org/doc/html/rfc6890)
  `0000 0000 0000 0000   0000 0000   x.x.x.x`         已经弃用(IPv4-Compatible IPv6 address)
- [特殊地址](https://datatracker.ietf.org/doc/html/rfc6890)
  `0064 0000 0000 0000   0000 ff9b   x.x.x.x`         转换地址(IPv4-IPv6 Translat)
- [特殊地址](https://datatracker.ietf.org/doc/html/rfc6890)
  `0000 0000 0000 0000   0000 ffff   x.x.x.x`         映射地址(IPv4-mapped Address)

## 管理命令

- `ip 6 -a` 显示本机的 IPv6 地址

## FAQs

- [The diff between `0.0.0.0` and `127.0.0.1`](https://superuser.com/questions/949428)
- What is the meaning of percent sign `%` in the IP address
  [rfc4007](# https://datatracker.ietf.org/doc/html/rfc4007),
  [link1](https://superuser.com/questions/99746),
  [link2](https://superuser.com/questions/241642)
