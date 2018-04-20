{ stdenv
, fetchurl
}:

let
  version = "1.16";
in
stdenv.mkDerivation rec {
  name = "tslib-${version}";

  src = fetchurl {
    url = "https://github.com/kergoth/tslib/releases/download/${version}/"
      + "${name}.tar.xz";
    hashOutput = false;
    sha256 = "c9a54651337a701a66b074c603c313225579995a7910e519bbc7b1dcdab9a755";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      sha512Urls = map (n: "${n}.sha512") src.urls;
      pgpKeyFingerprint = "F208 2B88 0F9E 4239 3468  6E3F 5003 98DF 5AB3 87D3";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Touchscreen access library";
    homepage = https://github.com/kergoth/tslib/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
