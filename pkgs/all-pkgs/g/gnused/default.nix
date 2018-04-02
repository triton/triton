{ stdenv
, fetchurl
, perl

, acl
}:

let
  version = "4.5";

  tarballUrls = version: [
    "mirror://gnu/sed/sed-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnused-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "7aad73c8839c2bdadca9476f884d2953cdace9567ecd0d90f9959f229d146b40";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    acl
  ];

  postPatch = ''
    patchShebangs build-aux/help2man
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      inherit (src) outputHashAlgo;
      outputHash = "7aad73c8839c2bdadca9476f884d2953cdace9567ecd0d90f9959f229d146b40";
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
