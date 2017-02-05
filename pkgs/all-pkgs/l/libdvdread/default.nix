{stdenv
, fetchurl
, lib

, libdvdcss
}:

let
  inherit (lib)
    boolWt;

  version = "5.0.3";
in
stdenv.mkDerivation rec {
  name = "libdvdread-${version}";

  src = fetchurl {
    url = "mirror://videolan/libdvdread/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "321cdf2dbdc83c96572bc583cd27d8c660ddb540ff16672ecb28607d018ed82b";
  };

  buildInputs = [
    libdvdcss
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-largefile"
    "--disable-apidoc"
    "--${boolWt (libdvdcss != null)}-libdvdcss"
  ];

  postInstall = ''
    ln -sv $out/include/dvdread $out/include/libdvdread
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # VideoLAN Release Signing Key
        "65F7 C6B4 206B D057 A7EB  7378 7180 713B E58D 1ADC"
      ];
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
