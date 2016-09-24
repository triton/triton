{ stdenv
, fetchurl
}:

let
  major = "4";
  minor = "1";
  patch = "4";
  version = "${major}.${minor}.${patch}";

  name = "libungif-${version}";

  baseUrls = [
    "mirror://sourceforge/giflib/libungif-${major}.x/${name}/libungif-4.1.4"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.tar.bz2") baseUrls;
    hashOutput = false;
    sha256 = "708a7eac218d3fd8e8dfb13f1089d4e1e98246985180a17d6ecfca5a6bd4d332";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}.sha.asc") baseUrls;
      pgpKeyFingerprint = "1289 DAF3 C7FC 1108 C77D  ADD9 5FAC 8089 CD84 EE48";
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

