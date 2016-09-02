{ stdenv
, fetchurl

, systemd_lib
}:

let
  version = "4.0";
in
stdenv.mkDerivation rec {
  name = "dosfstools-${version}";

  src = fetchurl {
    url = "https://github.com/dosfstools/dosfstools/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "9037738953559d1efe04fc5408b6846216cc0138f7f9d32de80b6ec3c35e7daf";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--enable-compat-symlinks"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "2571 4AEC DBFD ACEE 1CE9  5FE7 7F60 2251 6E86 9F64";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Utilities for creating and checking FAT and VFAT file systems";
    homepage = http://www.daniel-baumann.ch/software/dosfstools/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
