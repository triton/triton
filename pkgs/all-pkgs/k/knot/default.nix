{ stdenv
, fetchurl

, fstrm
, gnutls
, jansson
, libcap-ng
, libedit
, libidn2
, libmaxminddb
, liburcu
, lmdb
, protobuf-c
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "knot-2.9.2";

  src = fetchurl {
    url = "https://secure.nic.cz/files/knot-dns/${name}.tar.xz";
    multihash = "QmVdcbEcinpPvns2dZUGBcXsCyTUebQxBj9JLzy2GQ2jQZ";
    hashOutput = false;
    sha256 = "298cdf33aa7589b50df7e5833694b24cd2de8b6d17cee7e1673873fe576db6ee";
  };

  buildInputs = [
    fstrm
    gnutls
    jansson
    libcap-ng
    libedit
    libidn2
    libmaxminddb
    liburcu
    lmdb
    protobuf-c
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-recvmmsg=yes"
    "--enable-reuseport=yes"
    "--enable-systemd=yes"
    "--enable-dnstap"
    "--with-urcu=${liburcu}"
    "--with-lmdb=${lmdb}"
    "--with-module-dnstap=yes"
  ];

  preInstall = ''
    grep -q '\$(DESTDIR)//' src/Makefile
    sed -i '\,\$(DESTDIR)//,d' src/Makefile

    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "config_dir=$out/etc/knot"
    )
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
        sha256Urls = map (n: "${n}.sha256") src.urls;
        pgpKeyFingerprint = "742F A4E9 5829 B6C5 EAC6  B857 10BB 7AF6 FEBB D6AB";
      };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
