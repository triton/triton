{ stdenv, fetchurl, perl, makeWrapper, autoreconfHook
, nettools, iputils, iproute, coreutils, gnused

# Optional Dependencies
, openldap ? null
}:

with stdenv;
let
  optOpenldap = shouldUsePkg openldap;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "dhcp-${version}";
  version = "4.3.3-P1";
  
  src = fetchurl {
    url = "http://ftp.isc.org/isc/dhcp/${version}/${name}.tar.gz";
    sha256 = "08crcsmg4dm2v533aq3883ik8mf4vvvd6r998r4vrgx1zxnqj7n1";
  };

  nativeBuildInputs = [ perl makeWrapper ];
  buildInputs = [ optOpenldap ];

  preConfigure = ''
    sed -i "includes/dhcpd.h" \
      -e "s|^ *#define \+_PATH_DHCLIENT_SCRIPT.*$|#define _PATH_DHCLIENT_SCRIPT \"$out/sbin/dhclient-script\"|g"
  '';

  configureFlags = [
    (mkOther                        "sysconfdir"     "/etc")
    (mkOther                        "localstatedir"  "/var")
    (mkEnable false                 "debug"          null)
    (mkEnable true                  "failover"       null)
    (mkEnable true                  "execute"        null)
    (mkEnable true                  "tracing"        null)
    (mkEnable true                  "delayed-ack"    null)  # Experimental in 4.3.2
    (mkEnable true                  "dhcpv6"         null)
    (mkEnable true                  "paranoia"       null)
    (mkEnable true                  "early-chroot"   null)
    (mkEnable true                  "ipv4-pktinfo"   null)
    (mkEnable false                 "use-sockets"    null)
    (mkEnable false                 "secs-byteorder" null)
    (mkEnable false                 "log-pid"        null)
    (mkWith   false                 "libbind"        null)
    (mkWith   (optOpenldap != null) "ldap"           null)
    (mkWith   (optOpenldap != null) "ldapcrypto"     null)
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
  ];

  postInstall = ''
    cp client/scripts/linux $out/sbin/dhclient-script
    substituteInPlace $out/sbin/dhclient-script \
      --replace /sbin/ip ${iproute}/sbin/ip
    wrapProgram "$out/sbin/dhclient-script" --prefix PATH : \
      "${nettools}/bin:${nettools}/sbin:${iputils}/bin:${coreutils}/bin:${gnused}/bin"
  '';

  # Fails to build the bind library if run in parallel
  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Dynamic Host Configuration Protocol (DHCP) tools";

    longDescription = ''
      ISC's Dynamic Host Configuration Protocol (DHCP) distribution
      provides a freely redistributable reference implementation of
      all aspects of DHCP, through a suite of DHCP tools: server,
      client, and relay agent.
   '';

    homepage = http://www.isc.org/products/DHCP/;
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wkennington ];
  };
}
