{ stdenv
, fetchurl
, lzip
}:

let
  version = "2.0.3";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.lz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "b52fd3bc9693de16db93aa23a11a56f3cdb3fbf005a360145401ab5d252490f5";
  };

  nativeBuildInputs = [
    lzip
  ];

  configureFlags = [
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = tarballUrls "2.0.3";
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      inherit (src) outputHashAlgo;
      outputHash = "b52fd3bc9693de16db93aa23a11a56f3cdb3fbf005a360145401ab5d252490f5";
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
