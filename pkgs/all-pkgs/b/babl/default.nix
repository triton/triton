{ stdenv
, fetchurl
}:

let
  major = "0.1";
  patch = "30";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${major}/${name}.tar.bz2";
    multihash = "QmZmkBaEtWoy1UFwb2udUA2ryPH1Rq4un7KxxQWTpAbmx2";
    hashOutput = false;
    sha256 = "45c12c7b06d965123756821fc70c968137d16d44151a6eb55075f904e11d53cc";
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
