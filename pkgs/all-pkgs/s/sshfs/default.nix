{ stdenv
, fetchurl

, fuse
, glib
, openssh
}:

let
  version = "2.8";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/sshfs_${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "7f689174d02e6b7e2631306fda4fb8e6b4483102d1bce82b3cdafba33369ad22";
  };

  buildInputs = [
    fuse
    glib
    openssh
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
