{ stdenv
, fetchurl

, attr
}:

let
  tarballUrls = version: [
    "mirror://gnu/patch/patch-${version}.tar.xz"
  ];

  version = "2.7.6";
in
stdenv.mkDerivation rec {
  name = "gnupatch-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd";
  };

  buildInputs = [
    attr
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.7.6";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "259B 3792 B3D6 D319 212C  C4DC D5BF 9FEB 0313 653A";
      inherit (src) outputHashAlgo;
      outputHash = "ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd";
    };
  };

  meta = with stdenv.lib; {
    description = "GNU Patch, a program to apply differences to files";
    homepage = http://savannah.gnu.org/projects/patch;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
