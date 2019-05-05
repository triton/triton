{ stdenv
, fetchurl

, getopt
}:

let
  version = "2.4.1";
in
stdenv.mkDerivation rec {
  name = "libseccomp-${version}";

  src = fetchurl {
    url = "https://github.com/seccomp/libseccomp/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "1ca3735249af66a1b2f762fe6e710fcc294ad7185f1cc961e5bd83f9988006e8";
  };

  buildInputs = [
    getopt
  ];

  patchPhase = ''
    patchShebangs .
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha256Urls = map (n: "${n}.SHA256SUM.asc") src.urls;
        pgpKeyFingerprint = "7100 AADF AE6E 6E94 0D2E  0AD6 55E4 5A5A E8CA 7C8A";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "high level library for the Linux Kernel seccomp filter";
    homepage = "http://sourceforge.net/projects/libseccomp";
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
