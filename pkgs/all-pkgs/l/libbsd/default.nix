{ stdenv
, fetchurl

, openssl
}:

let
  tarballUrls = version: [
    "https://libbsd.freedesktop.org/releases/libbsd-${version}.tar.xz"
  ];

  version = "0.8.5";
in
stdenv.mkDerivation rec {
  name = "libbsd-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmYsWkRm41GFNiVjNx5dFw21en1YqX6oV5TwGYUQXPpgj9";
    hashOutput = false;
    sha256 = "7647d024f41389305272c263da933a6f2a978213c1801592f47e68d83ac05b28";
  };

  buildInputs = [
    openssl
  ];

  postPatch = ''
    sed \
      -e "s,/usr,$out,g" \
      -e 's,{exec_prefix},{prefix},g' \
      -i Makefile.in
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.8.5";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "4F3E 74F4 3605 0C10 F569  6574 B972 BF3E A4AE 57A3";
      inherit (src) outputHashAlgo;
      outputHash = "7647d024f41389305272c263da933a6f2a978213c1801592f47e68d83ac05b28";
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
