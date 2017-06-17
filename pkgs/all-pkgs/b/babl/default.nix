{ stdenv
, fetchurl
}:

let
  major = "0.1";
  patch = "26";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${major}/${name}.tar.bz2";
    multihash = "QmYGzxQuU4DvLydhpd9T7Gi19T58jMCUFykQ3L6mLUQGyZ";
    hashOutput = false;
    sha256 = "fd80e165f1534c64457a8cce7a8aa90559ab28ecd32beb9e3948c5b8cd373d34";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
      sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Image pixel format conversion library";
    homepage = http://gegl.org/babl/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
