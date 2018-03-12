{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/gzip/gzip-${version}.tar.xz"
  ];

  version = "1.9";
in
stdenv.mkDerivation rec {
  name = "gzip-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ae506144fc198bd8f81f1f4ad19ce63d5a2d65e42333255977cf1dcf1479089a";
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  makeFlags = [
    "SHELL=/bin/sh"
    "GREP=grep"
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.9";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      outputHash = "ae506144fc198bd8f81f1f4ad19ce63d5a2d65e42333255977cf1dcf1479089a";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/gzip/;
    description = "GNU zip compression program";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
