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
  name = "dbus-1.12.10";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    multihash = "QmefpXB5sQLwBsECpugje7MvmLkeQRhKLPBHmrxVp63Ucm";
    hashOutput = false;
    sha256 = "4b693d24976258c3f2fa9cc33ad9288c5fbfa7a16481dbd9a8a429f7aa8cdcf7";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Simon McVittie
        "DA98 F25C 0871 C49A 59EA  FF2C 4DE8 FF2A 63C7 CC90"
        "3C86 72A0 F496 37FE 064A  C30F 52A4 3A1E 4B77 B059"
      ];
      inherit (src) urls outputHash outputHashAlgo;
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
