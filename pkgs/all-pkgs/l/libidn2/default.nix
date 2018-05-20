{ stdenv
, fetchurl
, lzip
}:

let
  version = "2.0.5";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.lz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "0ff7a59eeedff3865fa17151d656991f56d8835f593982d7327af5e0bf9a9668";
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
      urls = tarballUrls "2.0.5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      inherit (src) outputHashAlgo;
      outputHash = "0ff7a59eeedff3865fa17151d656991f56d8835f593982d7327af5e0bf9a9668";
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
