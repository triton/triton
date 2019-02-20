{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.62";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmRLYw3aYoZDTW4z9nGb7GJYDUFjE4VLYurBhg2grefMNQ ";
    hashOutput = false;
    sha256 = "dc279f174edbcb08821cf37e4ab0bc02e6949369b00b150c759a6c24bfd3f510";
  };

  configureFlags = [
    "--disable-maintainer-mode"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
        sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      };
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
