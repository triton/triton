{ stdenv
, cc
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/libunistring/libunistring-${version}.tar.xz"
  ];

  version = "0.9.10";
in
(stdenv.override { cc = null; }).mkDerivation rec {
  name = "libunistring-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "eb8fb2c3e4b6e2d336608377050892b54c3c983b646c561836550863003c05d7";
  };

  nativeBuildInputs = [
    cc
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  # Needed to prevent libunistring.so from referencing dev
  CC_WRAPPER_CFLAGS = "-DLIBDIR=\"${placeholder "lib"}/lib\"";

  outputs = [
    "dev"
    "lib"
  ];

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
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
