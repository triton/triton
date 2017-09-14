{ stdenv
, fetchurl
, perl

, interactive ? true, ncurses
}:

let
  inherit (stdenv.lib)
    optionals;

  tarballUrls = version: [
    "mirror://gnu/texinfo/texinfo-${version}.tar.xz"
  ];

  version = "6.4";
in
stdenv.mkDerivation rec {
  name = "texinfo-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "6ae2e61d87c6310f9af7c6f2426bd0470f251d1a6deb61fba83a3b3baff32c3a";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = optionals interactive [
    ncurses
  ];

  preInstall = ''
    installFlagsArray+=("TEXMF=$out/texmf-dist")
  '';

  installTargets = [
    "install"
    "install-tex"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "6.5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "EAF6 69B3 1E31 E1DE CBD1  1513 DDBC 579D AB37 FBA9";
      inherit (src) outputHashAlgo;
      outputHash = "77774b3f4a06c20705cc2ef1c804864422e3cf95235e965b1f00a46df7da5f62";
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.gnu.org/software/texinfo/";
    description = "The GNU documentation system";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
