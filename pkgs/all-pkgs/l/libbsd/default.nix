{ stdenv
, fetchurl

, openssl
}:

let
  tarballUrls = version: [
    "https://libbsd.freedesktop.org/releases/libbsd-${version}.tar.xz"
  ];

  version = "0.8.3";
in
stdenv.mkDerivation rec {
  name = "libbsd-${version}";

  src = fetchurl {
    url = tarballUrls version;
    allowHashOutput = false;
    sha256 = "934b634f4dfd865b6482650b8f522c70ae65c463529de8be907b53c89c3a34a8";
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
      urls = tarballUrls "0.8.3";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "4F3E 74F4 3605 0C10 F569  6574 B972 BF3E A4AE 57A3";
      inherit (src) outputHashAlgo;
      outputHash = "934b634f4dfd865b6482650b8f522c70ae65c463529de8be907b53c89c3a34a8";
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
