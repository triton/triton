{ stdenv
, fetchurl

, fuse_3
, glib
, openssh
}:

let
  version = "3.0.0";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/${name}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "644966c7326c1b788a80318c5806f20f6d42dd72ab686f66d6120bd108b54d2d";
  };

  buildInputs = [
    fuse_3
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
