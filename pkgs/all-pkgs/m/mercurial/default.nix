{ stdenv
, fetchurl
, gettext
, lib
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "mercurial-4.3.1";

  src = fetchurl {
    url = "https://www.mercurial-scm.org/release/${name}.tar.gz";
    multihash = "QmVu6MoxeVGJ9Q2dnTC6hNjqXxFdacGHvsTJKQLjWk3Ntd";
    hashOutput = false;
    sha256 = "2b12f02e3a452adff4ec9cf007017bab0cadb3f37eaf12f4b25a662df73618a2";
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
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "FAD6 1395 F642 FC2B 33C8  4B9A 2057 81AC 682A 2D72"
        "3A81 5516 3D0E 20A5 30FC  B786 47A6 7FFA A346 AACE"
        "2BCC E14F 5C67 25AA 2EA8  AEB7 B9C9 DC82 4AA5 BDD5"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Scalable distributed SCM";
    homepage = https://www.mercurial-scm.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
