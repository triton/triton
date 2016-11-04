{ stdenv
, fetchurl
, lib
}:

let
  version = "1.4.0";
in
stdenv.mkDerivation rec {
  name = "libdvdcss-${version}";

  src = fetchurl {
    url = "https://get.videolan.org/libdvdcss/${version}/${name}.tar.bz2";
    outputHash = false;
    sha256 = "2089375984800df29a4817b37f3123c1706723342d6dab4d0a8b75c25c2c845a";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-largefile"
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for decrypting DVDs";
    homepage = http://www.videolan.org/developers/libdvdcss.html;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
