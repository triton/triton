{stdenv
, fetchurl
, lib

, libdvdcss
}:

let
  inherit (lib)
    boolWt;

  version = "6.0.0";
in
stdenv.mkDerivation rec {
  name = "libdvdread-${version}";

  src = fetchurl {
    url = "mirror://videolan/libdvdread/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b33b1953b4860545b75f6efc06e01d9849e2ea4f797652263b0b4af6dd10f935";
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
