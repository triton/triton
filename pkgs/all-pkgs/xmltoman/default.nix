{ stdenv
, fetchurl
, perlPackages
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "xmltoman-0.4";

  src = fetchurl {
    url = "mirror://sourceforge/xmltoman/${name}.tar.gz";
    sha256 = "1c0lvzr7kdy63wbn1jv6s126ds7add3pxqb0vlxd3v5a2sir91wl";
  };

  nativeBuildInputs = [
    perlPackages.perl
    perlPackages.XMLParser
    makeWrapper
  ];

  postPatch = ''
    patchShebangs .
  '';

  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  preFixup = ''
    for prog in xmltoman xmlmantohtml; do
      wrapProgram "$out/bin/$prog" \
        --set PERL5LIB "${stdenv.lib.makePerlPath [ perlPackages.XMLParser ]}"
    done
  '';

  meta = with stdenv.lib; {
    license = licenses.gpl2;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
