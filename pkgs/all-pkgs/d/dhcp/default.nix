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
  version = "4.4.1";
in
stdenv.mkDerivation rec {
  name = "dhcp-${version}";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/dhcp/${version}/${name}.tar.gz";
    multihash = "QmTk4M3VUeRGNfHeUev2qnNViU7NZbNe4DJJvQcv399Jey";
    hashOutput = false;
    sha256 = "2a22508922ab367b4af4664a0472dc220cc9603482cf3c16d9aff14f3a76b608";
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

    SOURCE_TIME=$(stat -c "%Y" configure)
    sed -i 's, -Werror,,g' configure
    touch -d "@$SOURCE_TIME" configure
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
    "--enable-dhcpv4o6"
    "--enable-relay-port"
    "--enable-paranoia"
    "--enable-early-chroot"
    "--enable-ipv4-pktinfo"
    "--disable-use-sockets"
    "--disable-log-pid"
    "--enable-binary-leases"
    #"--enable-libtool"
    "--without-libbind"
    "--with-ldap"
    "--with-ldapcrypto"
    "--with-ldap-gssapi"
    "--without-ldapcasa"
  ];

  # Fix kerberos rpath
  NIX_LDFLAGS = "-rpath ${krb5_lib}/lib";

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
  buildParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # 2017-2018
        "BE0E 9748 B718 253A 28BB  89FF F1B1 1BF0 5CF0 2E57"
      ];
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    description = "Dynamic Host Configuration Protocol (DHCP) tools";
    homepage = http://www.isc.org/products/DHCP/;
    license = licenses.mpl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
