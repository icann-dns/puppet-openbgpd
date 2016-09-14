#used to validate peer data
type Openbgpd::Peer = Struct[{
  addr4             => Optional[Array[Tea::Ipv4]],
  addr6             => Optional[Array[Tea::Ipv6]],
  desc              => NotUndef[String[1,140]],
  communities       => Optional[Array[Openbgpd::Community]],
  multihop          => Optional[Integer[1,255]],
  prepend           => Optional[Integer[1,255]],
  inbound_routes    => Optional[
    Enum['all', 'none', 'default', 'v6default', 'v4default']]
}]
