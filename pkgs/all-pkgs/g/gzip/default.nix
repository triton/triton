{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/gzip/gzip-${version}.tar.xz"
  ];

  version = "1.8";
in
stdenv.mkDerivation rec {
  name = "gzip-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ff1767ec444f71e5daf8972f6f8bf68cfcca1d2f76c248eb18e8741fc91dbbd3";
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  makeFlags = [
    "SHELL=/bin/sh"
    "GREP=grep"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.8";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      outputHash = "ff1767ec444f71e5daf8972f6f8bf68cfcca1d2f76c248eb18e8741fc91dbbd3";
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
