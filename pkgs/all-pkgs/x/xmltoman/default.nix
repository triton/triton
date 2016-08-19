{ stdenv
, fetchurl
, makeWrapper
, perlPackages
}:

let
  inherit (stdenv.lib)
    makeSearchPath;
in
stdenv.mkDerivation rec {
  name = "xmltoman-0.4";

  src = fetchurl {
    url = "mirror://sourceforge/xmltoman/${name}.tar.gz";
    multihash = "QmS75WNMsPBp2hkSM6Cze81hJKp5G3jGXAZM1VbUHJiax9";
    sha256 = "948794a316aaecd13add60e17e476beae86644d066cb60171fc6b779f2df14b0";
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
        --set 'PERL5LIB' "${
          makeSearchPath "${perlPackages.perl.libPrefix}" [
            perlPackages.XMLParser
          ]}"
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
      x86_64-linux;
  };
}
