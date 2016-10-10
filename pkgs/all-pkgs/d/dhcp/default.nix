{ stdenv
, fetchurl
, makeWrapper
, perl

, coreutils
, cyrus-sasl
, gnused
, iproute
, iputils
, krb5_lib
, net-tools
, openldap
}:

let
  version = "4.3.5";
in
stdenv.mkDerivation rec {
  name = "dhcp-${version}";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/dhcp/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "eb95936bf15d2393c55dd505bc527d1d4408289cec5a9fa8abb99f7577e7f954";
  };

  nativeBuildInputs = [
    perl
    makeWrapper
  ];

  buildInputs = [
    cyrus-sasl
    krb5_lib
    openldap
  ];

  postPatch = ''
    sed -i includes/dhcpd.h \
      -e "s|^ *#define \+_PATH_DHCLIENT_SCRIPT.*$|#define _PATH_DHCLIENT_SCRIPT \"$out/bin/dhclient-script\"|g"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-debug"
    "--enable-failover"
    "--enable-execute"
    "--enable-tracing"
    "--enable-delayed-ack"
    "--enable-dhcpv6"
    "--enable-paranoia"
    "--enable-early-chroot"
    "--enable-ipv4-pktinfo"
    "--disable-use-sockets"
    "--disable-secs-byteorder"
    "--disable-log-pid"
    "--enable-binary-leases"
    "--without-libbind"
    "--with-ldap"
    "--with-ldapcrypto"
    "--with-ldap-gssapi"
    "--without-ldapcasa"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  postInstall = ''
    cp -v client/scripts/linux $out/bin/dhclient-script
    sed -i $out/bin/dhclient-script \
      -e 's,/sbin/ip,${iproute}/bin/ip,'
    wrapProgram "$out/bin/dhclient-script" \
      --prefix PATH : "${coreutils}/bin" \
      --prefix PATH : "${gnused}/bin" \
      --prefix PATH : "${iputils}/bin" \
      --prefix PATH : "${net-tools}/bin"
  '';

  # Fails to build the bind library if run in parallel
  parallelBuild = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sha512.asc") src.urls;
      pgpKeyFile = ./signing.key;
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    description = "Dynamic Host Configuration Protocol (DHCP) tools";
    homepage = http://www.isc.org/products/DHCP/;
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
