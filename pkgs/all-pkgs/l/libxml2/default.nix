{ stdenv
, fetchTritonPatch
, fetchurl

, findXMLCatalogs
, icu
, python
, readline
, xz
, zlib
}:

let
  version = "2.9.4";

  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxml2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libxml2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ffb911191e509b966deb55de705387f14156e1a56b21824357cdf0053233633c";
  };

  buildInputs = [
    icu
    python
    readline
    xz
    zlib
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  patches = [
    (fetchTritonPatch {
      rev = "1491e5f86aac6fbd6cb0e0dad846dd4e1f4cf190";
      file = "l/libxml2/0001-CVE-2016-4658.patch";
      sha256 = "7aee52ca24da6c7d36787cded379eaedd34803f8d355e11806b988a25de6a6bb";
    })
    (fetchTritonPatch {
      rev = "1491e5f86aac6fbd6cb0e0dad846dd4e1f4cf190";
      file = "l/libxml2/0002-CVE-2016-5131.patch";
      sha256 = "4e0248f5a6877b157b9d736c412d4da7a2c015d58a816b859957efddb8d3c8d4";
    })
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-python-install-dir=$(toPythonPath "$out")"
    )
  '';

  configureFlags = [
    "--with-icu=${icu}"
    "--with-python=${python}"
    "--with-readline=${readline}"
    "--with-zlib=${zlib}"
    "--with-lzma=${xz}"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.9.4";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      inherit (src) outputHashAlgo;
      outputHash = "ffb911191e509b966deb55de705387f14156e1a56b21824357cdf0053233633c";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/;
    description = "An XML parsing library for C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
