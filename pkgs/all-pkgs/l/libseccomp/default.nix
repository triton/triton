{ stdenv
, fetchurl

, getopt
}:

let
  version = "2.4.0";
in
stdenv.mkDerivation rec {
  name = "libseccomp-${version}";

  src = fetchurl {
    url = "https://github.com/seccomp/libseccomp/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "2e74c7e8b54b340ad5d472e59286c6758e1e1e96c6b43c3dbdc8ddafbf0e525d";
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
