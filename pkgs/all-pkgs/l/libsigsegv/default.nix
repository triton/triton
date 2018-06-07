{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/libsigsegv/libsigsegv-${version}.tar.gz"
  ];

  version = "2.12";
in
stdenv.mkDerivation rec {
  name = "libsigsegv-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "3ae1af359eebaa4ffc5896a1aee3568c052c99879316a1ab57f8fe1789c390b6";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.12";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "68D9 4D8A AEEA D48A E7DC  5B90 4F49 4A94 2E46 16C2";
      inherit (src) outputHashAlgo;
      outputHash = "3ae1af359eebaa4ffc5896a1aee3568c052c99879316a1ab57f8fe1789c390b6";
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
