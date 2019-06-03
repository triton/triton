{stdenv
, fetchurl
, lib

, libdvdcss
}:

let
  version = "6.0.1";
in
stdenv.mkDerivation rec {
  name = "libdvdread-${version}";

  src = fetchurl {
    url = "mirror://videolan/libdvdread/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "28ce4f0063883ca4d37dfd40a2f6685503d679bca7d88d58e04ee8112382d5bd";
  };

  buildInputs = [
    libdvdcss
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-apidoc"
    "--with-libdvdcss"
  ];

  postInstall = ''
    ln -sv "$out"/include/dvdread "$out"/include/libdvdread
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: "${n}.sha256") src.urls;
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          # VideoLAN Release Signing Key
          "65F7 C6B4 206B D057 A7EB  7378 7180 713B E58D 1ADC"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for reading DVDs";
    homepage = http://dvdnav.mplayerhq.hu/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
