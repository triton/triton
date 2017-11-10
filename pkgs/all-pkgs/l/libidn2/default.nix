{ stdenv
, fetchurl
}:

let
  version = "2.0.4";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "644b6b03b285fb0ace02d241d59483d98bc462729d8bb3608d5cad5532f3d2f0";
  };

  configureFlags = [
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = tarballUrls "2.0.4";
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      inherit (src) outputHashAlgo;
      outputHash = "644b6b03b285fb0ace02d241d59483d98bc462729d8bb3608d5cad5532f3d2f0";
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
