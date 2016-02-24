{ stdenv
, fetchurl
, makeWrapper

, perlPackages
}:

stdenv.mkDerivation rec {
  name = "intltool-${version}";
  version = "0.51.0";

  src = fetchurl {
    url = "https://launchpad.net/intltool/trunk/${version}/+download/${name}.tar.gz";
    sha256 = "1karx4sb7bnm2j67q0q74hspkfn6lqprpy5r99vkn5bb36a4viv7";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = with perlPackages; [
    perl
    XMLParser
  ];

  preFixup = ''
    for bin in $(find $out/bin -type f); do
      wrapProgram "$bin" \
        --set PERL5LIB "${stdenv.lib.makePerlPath [ perlPackages.XMLParser ]}"
    done
  '';

  meta = with stdenv.lib; {
    description = "Translation helper tool";
    homepage = http://launchpad.net/intltool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      raskin
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
