{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/libunistring/libunistring-${version}.tar.xz"
  ];

  version = "0.9.9";
in
stdenv.mkDerivation rec {
  name = "libunistring-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "a4d993ecfce16cf503ff7579f5da64619cee66226fb3b998dafb706190d9a833";
  };

  # One of the tests fails to compile for 0.9.6 when run in parallel
  doCheck = true;
  checkParallel = false;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.9.9";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "4622 25C3 B46F 3487 9FC8  496C D605 848E D7E6 9871";
      inherit (src) outputHashAlgo;
      outputHash = "a4d993ecfce16cf503ff7579f5da64619cee66226fb3b998dafb706190d9a833";
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
