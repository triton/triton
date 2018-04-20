{ stdenv
, fetchurl
, lib
}:

let
  version = "1.4.2";
in
stdenv.mkDerivation rec {
  name = "libdvdcss-${version}";

  src = fetchurl {
    url = "mirror://videolan/libdvdcss/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "78c2ed77ec9c0d8fbed7bf7d3abc82068b8864be494cfad165821377ff3f2575";
  };

  configureFlags = [
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
