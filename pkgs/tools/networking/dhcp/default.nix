{ stdenv, fetchurl, perl, makeWrapper, autoreconfHook
, nettools, iputils, iproute, coreutils, gnused

# Optional Dependencies
, bind ? null, openldap ? null
}:

with stdenv;
let
  optBind = shouldUsePkg bind;
  optOpenldap = shouldUsePkg openldap;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "dhcp-${version}";
  version = "4.3.2";
  
  src = fetchurl {
    url = "http://ftp.isc.org/isc/dhcp/${version}/${name}.tar.gz";
    sha256 = "0rc156qqv7293yi69gxvvc8s4cp7fspwl12iqkf6r7vmb2rwjik2";
  };

  nativeBuildInputs = [ perl makeWrapper autoreconfHook ];
  buildInputs = [ optBind optOpenldap ];

  postPatch = ''
    # Use our prebuilt version of bind
    rm -rf bind
    ln -sv ${bind} bind

    # Don't build an internal version of bind
    sed -i 's,^\(.*SUBDIRS.*\)bind\(.*\)$,\1\2,' Makefile.am

    # Use shared bind libraries instead of static
    grep -r 'bind/lib' . | awk -F: '{print $1}' | sort | uniq | xargs sed \
      -e "s,[^ ]*bind/lib/lib\([^.]*\)\.a,-l\1,g" \
      -i
  '';

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
    (mkWith   (optBind != null)     "libbind"        optBind)
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

  enableParallelBuilding = true;

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
