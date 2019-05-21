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
  name = "dbus-1.12.14";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    multihash = "QmZo51r8ReNdtLRJEMYkSHY75vcocTL4n7mKj69zqNjKiV";
    hashOutput = false;
    sha256 = "44f9c290ae8f6cadeb2c329316c03716f171ce10daddd85c0bffd0f7df514c8d";
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
