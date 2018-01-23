{ stdenv
, fetchurl
, lib
}:

let
  version = "1.4.1";
in
stdenv.mkDerivation rec {
  name = "libdvdcss-${version}";

  src = fetchurl {
    url = "mirror://videolan/libdvdcss/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "eb073752b75ae6db3a3ffc9d22f6b585cd024079a2bf8acfa56f47a8fce6eaac";
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
