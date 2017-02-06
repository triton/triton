{ stdenv
, fetchurl
, perl
}:

let
  version = "4.4";

  tarballUrls = version: [
    "mirror://gnu/sed/sed-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnused-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "cbd6ebc5aaf080ed60d0162d7f6aeae58211a1ee9ba9bb25623daa6cd942683b";
  };

  nativeBuildInputs = [
    perl
  ];

  postPatch = ''
    patchShebangs build-aux/help2man
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      inherit (src) outputHashAlgo;
      outputHash = "cbd6ebc5aaf080ed60d0162d7f6aeae58211a1ee9ba9bb25623daa6cd942683b";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/sed/;
    description = "GNU sed, a batch stream editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
