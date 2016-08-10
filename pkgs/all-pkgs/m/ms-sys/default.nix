{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "ms-sys-${version}";
  version = "2.5.3";
 
  src = fetchurl {
    url = "mirror://sourceforge/ms-sys/${name}.tar.gz";
    md5Confirm = "a33f0ca96d0ba2688503183b74a86568";
    sha256 = "0mijf82cbji4laip6hiy3l5ka5mzq5sivjvyv7wxnc2fd3v7hgp0";
  };

  nativeBuildInputs = [
    gettext
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    description = "A program for writing Microsoft-compatible boot records";
    homepage = http://ms-sys.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
