{ stdenv
, fetchurl
, gettext
, perlPackages
, makeWrapper
}:

let
  version = "1.47.4";

  tarballUrls = version: [
    "mirror://gnu/help2man/help2man-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "help2man-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "d4ecf697d13f14dd1a78c5995f06459bff706fd1ce593d1c02d81667c0207753";
  };

  nativeBuildInputs = [
    makeWrapper
    perlPackages.perl
    gettext
  ];

  postInstall = ''
    wrapProgram "$out/bin/help2man" \
      --prefix PERL5LIB : "$(echo ${perlPackages.Locale-gettext}/${perlPackages.perl.libPrefix})"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.47.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "87EA 44D1 50D8 9615 E39A  3FEE F0DC 8E00 B28C 5995";
      inherit (src) outputHashAlgo;
      outputHash = "d4ecf697d13f14dd1a78c5995f06459bff706fd1ce593d1c02d81667c0207753";
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
