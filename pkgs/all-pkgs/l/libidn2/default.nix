{ stdenv
, fetchurl
, lzip
}:

let
  version = "2.0.4";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.lz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "a446ac5e40b801edfc4f6ba50fdeb614dcfeb34ab0d8c6868e29f359b877c201";
  };

  nativeBuildInputs = [
    lzip
  ];

  configureFlags = [
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.0.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      inherit (src) outputHashAlgo;
      outputHash = "a446ac5e40b801edfc4f6ba50fdeb614dcfeb34ab0d8c6868e29f359b877c201";
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
