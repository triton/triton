{ stdenv
, fetchurl
, coreutils
}:

let
  version = "3.4";

  tarballUrls = version: [
    "mirror://gnu/diffutils/diffutils-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "diffutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "db53c025f2ac3d217bcf753dad6dee7b410b33d0948495ff015aaf8b91189ce2";
  };

  # We need to directly reference coreutils, otherwise the
  # output depends on the bootstrap.
  buildInputs = [
    coreutils
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      inherit (src) outputHashAlgo;
      outputHash = "db53c025f2ac3d217bcf753dad6dee7b410b33d0948495ff015aaf8b91189ce2";
    };
  };

  meta = with stdenv.lib; {
    description = "Commands for showing the differences (diff) between files";
    homepage = http://www.gnu.org/software/diffutils/diffutils.html;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
