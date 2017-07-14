{ stdenv
, fetchurl

, gettext
, perlPackages
}:

let
  version = "0.51.0";
in
stdenv.mkDerivation rec {
  name = "intltool-${version}";

  src = fetchurl {
    url = "https://launchpad.net/intltool/trunk/${version}/+download/${name}.tar.gz";
    multihash = "QmYHDppGQTJfhnQzENFcLPD7iRmqWM9rbqZVtVeHjpZZVu";
    sha256 = "1karx4sb7bnm2j67q0q74hspkfn6lqprpy5r99vkn5bb36a4viv7";
  };

  # Most packages just expect these to be propagated
  propagatedBuildInputs = [
    gettext
    perlPackages.perl
    perlPackages.XMLParser
  ];

  meta = with stdenv.lib; {
    description = "Translation helper tool";
    homepage = http://launchpad.net/intltool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      raskin
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
