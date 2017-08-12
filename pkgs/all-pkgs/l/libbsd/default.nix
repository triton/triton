{ stdenv
, fetchurl

, openssl
}:

let
  tarballUrls = version: [
    "https://libbsd.freedesktop.org/releases/libbsd-${version}.tar.xz"
  ];

  version = "0.8.6";
in
stdenv.mkDerivation rec {
  name = "libbsd-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmYH7K6N1vN9EAG4pwQxk8f3MPwoK51XSTifUPFNwnUUtg";
    hashOutput = false;
    sha256 = "467fbf9df1f49af11f7f686691057c8c0a7613ae5a870577bef9155de39f9687";
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
      urls = tarballUrls "0.8.6";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "4F3E 74F4 3605 0C10 F569  6574 B972 BF3E A4AE 57A3";
      inherit (src) outputHashAlgo;
      outputHash = "467fbf9df1f49af11f7f686691057c8c0a7613ae5a870577bef9155de39f9687";
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
