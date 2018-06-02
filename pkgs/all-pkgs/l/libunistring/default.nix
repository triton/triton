{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/libunistring/libunistring-${version}.tar.xz"
  ];

  version = "0.9.10";
in
stdenv.mkDerivation rec {
  name = "libunistring-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "eb8fb2c3e4b6e2d336608377050892b54c3c983b646c561836550863003c05d7";
  };

  # One of the tests fails to compile for 0.9.6 when run in parallel
  doCheck = true;
  checkParallel = false;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.9.10";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "4622 25C3 B46F 3487 9FC8  496C D605 848E D7E6 9871";
      inherit (src) outputHashAlgo;
      outputHash = "eb8fb2c3e4b6e2d336608377050892b54c3c983b646c561836550863003c05d7";
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
