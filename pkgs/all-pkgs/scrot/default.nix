{ stdenv
, fetchurl

, giblib
, xlibsWrapper
}:

stdenv.mkDerivation rec {
  name = "scrot-0.8";

  src = fetchurl {
    url = "mirror://debian/pool/main/s/scrot/scrot_0.8.orig.tar.gz";
    sha256 = "1wll744rhb49lvr2zs6m93rdmiq59zm344jzqvijrdn24ksiqgb1";
  };

  buildInputs = [
    giblib
    xlibsWrapper
  ];

  meta = with stdenv.lib; {
    homepage = http://linuxbrit.co.uk/scrot/;
    description = "A command-line screen capture utility";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
