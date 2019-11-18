{ stdenv
, fetchurl
, lib
}:

let
  tarballUrls = version: [
    "mirror://sourceforge/expat/expat/${version}/expat-${version}.tar.bz2"
  ];

  version = "2.2.9";
in
stdenv.mkDerivation rec {
  name = "expat-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f1063084dc4302a427dabcca499c8312b3a32a29b7d2506653ecc8f950a9a237";
  };

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        outputHashAlgo;
      urls = tarballUrls "2.2.9";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "3D7E 959D 89FA CFEE 3837  1921 B00B C66A 401A 1600";
      };
      outputHash = "f1063084dc4302a427dabcca499c8312b3a32a29b7d2506653ecc8f950a9a237";
    };
  };

  meta = with lib; {
    description = "A stream-oriented XML parser library written in C";
    homepage = http://www.libexpat.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
