{ stdenv
, fetchurl

, fuse_3
, glib
, openssh
}:

let
  version = "3.2.0";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/${name}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b494cdbac7ba2e77b994b3d3957171610be640e49c287ff6cb8f2959c4768101";
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
