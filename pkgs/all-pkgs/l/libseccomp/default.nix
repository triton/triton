{ stdenv
, fetchurl

, getopt
}:

let
  version = "2.4.3";
in
stdenv.mkDerivation rec {
  name = "libseccomp-${version}";

  src = fetchurl {
    url = "https://github.com/seccomp/libseccomp/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "cf15d1421997fac45b936515af61d209c4fd788af11005d212b3d0fd71e7991d";
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
