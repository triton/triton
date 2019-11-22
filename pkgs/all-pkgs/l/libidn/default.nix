{ stdenv
, fetchurl
}:

let
  version = "1.35";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f11af1005b46b7b15d057d7f107315a1ad46935c7fcdf243c16e46ec14f0fe1e";
  };

  makeFlags = [
    "localedir=${placeholder "data"}/share/locale"
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "data"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = tarballUrls "1.35";
      inherit (src)
        outputHashAlgo;
      outputHash = "f11af1005b46b7b15d057d7f107315a1ad46935c7fcdf243c16e46ec14f0fe1e";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libidn/;
    description = "Library for internationalized domain names";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
