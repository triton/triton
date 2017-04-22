{ stdenv
, fetchurl

, fuse_2
, glib
, openssh
}:

let
  version = "2.9";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/${name}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "46d1e1287ce97255fcb50010355184d8c5585329f73ab1e755217419a8e6e5de";
  };

  buildInputs = [
    fuse_2
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
