{ stdenv
, fetchurl

, glib
}:

let
  version = "0.7.6";
in
stdenv.mkDerivation rec {
  name = "gts-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/gts/gts/${version}/${name}.tar.gz";
    sha256 = "07mqx09jxh8cv9753y2d2jsv7wp8vjmrd7zcfpbrddz3wc9kx705";
  };

  buildInputs = [
    glib
  ];

  meta = with stdenv.lib; {
    description = "GNU Triangulated Surface Library";
    homepage = http://gts.sourceforge.net/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
