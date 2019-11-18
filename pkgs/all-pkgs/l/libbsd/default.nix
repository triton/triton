{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://libbsd.freedesktop.org/releases/libbsd-${version}.tar.xz"
  ];

  version = "0.10.0";
in
stdenv.mkDerivation rec {
  name = "libbsd-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmZfsi4qLUfk3bzx7AqJGYRhyPJ1KnFZHN6PKzRv6Zm5pC";
    hashOutput = false;
    sha256 = "34b8adc726883d0e85b3118fa13605e179a62b31ba51f676136ecb2d0bc1a887";
  };

  postPatch = ''
    sed \
      -e "s,/usr,$out,g" \
      -e 's,{exec_prefix},{prefix},g' \
      -i Makefile.in
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.10.0";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "4F3E 74F4 3605 0C10 F569  6574 B972 BF3E A4AE 57A3";
      inherit (src) outputHashAlgo;
      outputHash = "34b8adc726883d0e85b3118fa13605e179a62b31ba51f676136ecb2d0bc1a887";
    };
  };

  meta = with stdenv.lib; {
    description = "Common functions found on BSD systems";
    homepage = http://libbsd.freedesktop.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
