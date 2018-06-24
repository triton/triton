{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.50";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmZ7CrSj2ZoVi1RoFMSDc36wfig6VbNbaecFqEALbLL1Fo";
    hashOutput = false;
    sha256 = "b52c1dc081ff9ae8bc4cb7cdb959c762ea692b9f4431bacf8d17a14dbcc85b2d";
  };

  configureFlags = [
    "--disable-maintainer-mode"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
      sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
