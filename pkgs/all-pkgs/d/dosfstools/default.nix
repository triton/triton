{ stdenv
, fetchurl

, systemd_lib
}:

let
  version = "4.1";
in
stdenv.mkDerivation rec {
  name = "dosfstools-${version}";

  src = fetchurl {
    url = "https://github.com/dosfstools/dosfstools/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "e6b2aca70ccc3fe3687365009dd94a2e18e82b688ed4e260e04b7412471cc173";
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
