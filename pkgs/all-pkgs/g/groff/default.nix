{ stdenv
, fetchurl
, perl
}:

stdenv.mkDerivation rec {
  name = "groff-1.22.3";

  src = fetchurl {
    url = "mirror://gnu/groff/${name}.tar.gz";
    hashOutput = false;
    sha256 = "1998v2kcs288d3y7kfxpvl369nqi06zbbvjzafyvyl3pr7bajj1s";
  };

  nativeBuildInputs = [
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
