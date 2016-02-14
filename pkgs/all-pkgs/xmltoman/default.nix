{ stdenv
, fetchurl
, makeWrapper
, perlPackages
}:

stdenv.mkDerivation rec {
  name = "xmltoman-0.4";

  src = fetchurl {
    url = "mirror://sourceforge/xmltoman/${name}.tar.gz";
    sha256 = "1c0lvzr7kdy63wbn1jv6s126ds7add3pxqb0vlxd3v5a2sir91wl";
  };

  nativeBuildInputs = [
    makeWrapper
    perlPackages.perl
    perlPackages.XMLParser
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
        --set 'PERL5LIB' "${stdenv.lib.makePerlPath [ perlPackages.XMLParser ]}"
    done
  '';

  meta = with stdenv.lib; {
    description = "Simple scripts for converting xml to groff or html";
    homepage = http://sourceforge.net/projects/xmltoman/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
