{ stdenv
, fetchurl
}:

let
  version = "1.17";
in
stdenv.mkDerivation rec {
  name = "tslib-${version}";

  src = fetchurl {
    url = "https://github.com/kergoth/tslib/releases/download/${version}/"
      + "${name}.tar.xz";
    hashOutput = false;
    sha256 = "9fdd33e66976bf9cc799be33824ba66672f892826e9b22de12b14df15cb0fddc";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        sha256Urls = map (n: "${n}.sha256") src.urls;
        sha512Urls = map (n: "${n}.sha512") src.urls;
        pgpKeyFingerprint = "F208 2B88 0F9E 4239 3468  6E3F 5003 98DF 5AB3 87D3";
      };
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
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
