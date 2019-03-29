{ stdenv
, fetchurl
, gettext
, perlPackages
, makeWrapper
}:

let
  version = "1.47.10";

  tarballUrls = version: [
    "mirror://gnu/help2man/help2man-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "help2man-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f371cbfd63f879065422b58fa6b81e21870cd791ef6e11d4528608204aa4dcfb";
  };

  nativeBuildInputs = [
    gettext
    makeWrapper
  ];

  buildInputs = [
    perlPackages.perl
  ];

  postInstall = ''
    wrapProgram "$out/bin/help2man" \
      --prefix PERL5LIB : "$(echo ${perlPackages.LocaleGettext}/${perlPackages.perl.libPrefix})"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.47.10";
      inherit (src) outputHashAlgo;
      outputHash = "f371cbfd63f879065422b58fa6b81e21870cd791ef6e11d4528608204aa4dcfb";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "87EA 44D1 50D8 9615 E39A  3FEE F0DC 8E00 B28C 5995";
      };
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
