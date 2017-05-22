{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/libsigsegv/libsigsegv-${version}.tar.gz"
  ];

  version = "2.11";
in
stdenv.mkDerivation rec {
  name = "libsigsegv-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "dd7c2eb2ef6c47189406d562c1dc0f96f2fc808036834d596075d58377e37a18";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.11";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "68D9 4D8A AEEA D48A E7DC  5B90 4F49 4A94 2E46 16C2";
      inherit (src) outputHashAlgo;
      outputHash = "dd7c2eb2ef6c47189406d562c1dc0f96f2fc808036834d596075d58377e37a18";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libsigsegv/;
    description = "Library to handle page faults in user mode";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
