{ stdenv
, fetchurl
, perl
}:

let
  tarballUrls = version: [
    "mirror://gnu/groff/groff-${version}.tar.gz"
  ];

  version = "1.22.4";
in
stdenv.mkDerivation rec {
  name = "groff-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e78e7b4cb7dec310849004fa88847c44701e8d133b5d4c13057d876c1bad0293";
  };

  buildInputs = [
    perl
  ];

  configureFlags = [
    "--without-doc"
  ];

  # Remove example output with (random?) colors to
  # avoid non-determinism in the output
  postInstall = ''
    rm -r $out/share/doc
  '';

  buildParallel = false;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.22.4";
      inherit (src) outputHashAlgo;
      outputHash = "e78e7b4cb7dec310849004fa88847c44701e8d133b5d4c13057d876c1bad0293";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "2D0C 08D2 B0AD 0D3D 8626  6702 72D2 3FBA C99D 4E75";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/groff/;
    description = "GNU Troff, a typesetting package that reads plain text and produces formatted output";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
