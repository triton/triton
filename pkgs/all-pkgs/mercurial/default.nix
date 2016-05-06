{ stdenv
, fetchurl
, gettext
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "mercurial-3.8.1";

  src = fetchurl {
    url = "https://www.mercurial-scm.org/release/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "face1f058de5530b56b0dfd3b4d0b23d89590c588605c06f3d18b79e8c30d594";
  };

  nativeBuildInputs = [
    gettext
    pythonPackages.docutils
    pythonPackages.python
  ];

  buildFlags = [
    "all"
  ];

  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "FAD6 1395 F642 FC2B 33C8  4B9A 2057 81AC 682A 2D72";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
