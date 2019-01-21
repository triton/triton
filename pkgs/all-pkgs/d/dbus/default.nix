{ stdenv
, docbook_xml_dtd_44
, docbook-xsl
, fetchurl
, libxslt
, xmlto

, expat
, libx11
, systemd_lib
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "dbus-1.12.12";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    multihash = "QmcECxv85n72bk2uW5tA3Jp66wdcrzQgCqDNSjn5Dnertt";
    hashOutput = false;
    sha256 = "9546f226011a1e5d9d77245fe5549ef25af4694053189d624d0d6ac127ecf5f8";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_44
    docbook-xsl
    libxslt
    xmlto
  ];

  buildInputs = [
    expat
    libx11
    systemd_lib
    xorgproto
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
      "--with-systemduserunitdir=$out/etc/systemd/user"
    )
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR/var"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-doxygen-docs"
    "--disable-ducktype-docs"
    "--disable-tests"
    "--enable-user-session"
    "--with-session-socket-dir=/tmp"
  ];

  postInstall = ''
    grep -q '/usr' "$out"/etc/systemd/user/dbus.socket
    sed -i 's,/usr,/run/current-system/sw,' "$out"/etc/systemd/user/dbus.socket
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          # Simon McVittie
          "DA98 F25C 0871 C49A 59EA  FF2C 4DE8 FF2A 63C7 CC90"
          "3C86 72A0 F496 37FE 064A  C30F 52A4 3A1E 4B77 B059"
        ];
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A message bus system for interprocess communication (IPC)";
    homepage = http://dbus.freedesktop.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
