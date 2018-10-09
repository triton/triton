{ stdenv
, fetchurl
, gettext
, perlPackages
, makeWrapper
}:

let
  version = "1.47.7";

  tarballUrls = version: [
    "mirror://gnu/help2man/help2man-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "help2man-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "585b8e88ed04bdb426403cf7d9b0c0bb9c7630755b0096c2b018a024b29bec0d";
  };

  nativeBuildInputs = [
    makeWrapper
    perlPackages.perl
    gettext
  ];

  postInstall = ''
    wrapProgram "$out/bin/help2man" \
      --prefix PERL5LIB : "$(echo ${perlPackages.LocaleGettext}/${perlPackages.perl.libPrefix})"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.47.7";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "87EA 44D1 50D8 9615 E39A  3FEE F0DC 8E00 B28C 5995";
      inherit (src) outputHashAlgo;
      outputHash = "585b8e88ed04bdb426403cf7d9b0c0bb9c7630755b0096c2b018a024b29bec0d";
    };
  };

  meta = with stdenv.lib; {
    description = "Generate man pages from `--help' output";
    homepage = http://www.gnu.org/software/help2man/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
