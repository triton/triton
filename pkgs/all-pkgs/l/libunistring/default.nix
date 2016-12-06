{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/libunistring/libunistring-${version}.tar.xz"
  ];

  version = "0.9.7";
in
stdenv.mkDerivation rec {
  name = "libunistring-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "2e3764512aaf2ce598af5a38818c0ea23dedf1ff5460070d1b6cee5c3336e797";
  };

  # One of the tests fails to compile for 0.9.6 when run in parallel
  doCheck = true;
  parallelCheck = false;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.9.7";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "4622 25C3 B46F 3487 9FC8  496C D605 848E D7E6 9871";
      inherit (src) outputHashAlgo;
      outputHash = "2e3764512aaf2ce598af5a38818c0ea23dedf1ff5460070d1b6cee5c3336e797";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libunistring/;
    description = "Unicode string library";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
