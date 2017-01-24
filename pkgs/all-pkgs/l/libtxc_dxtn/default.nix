{ stdenv
, autoreconfHook
, fetchurl

, mesa
}:

let
  version = "1.0.1";
in
stdenv.mkDerivation rec {
  name = "libtxc_dxtn-${version}";

  src = fetchurl {
    url = "https://people.freedesktop.org/~cbrill/libtxc_dxtn/${name}.tar.bz2";
    multihash = "QmYYNT1UW7fFmpXUfbNf2RKoWwsyvXKspAFe9t1y5wUcPV";
    sha256 = "0q5fjaknl7s0z206dd8nzk9bdh8g4p23bz7784zrllnarl90saa5";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    mesa
  ];

  meta = with stdenv.lib; {
    homepage = http://dri.freedesktop.org/wiki/S3TC;
    repositories.git = git://people.freedesktop.org/~mareko/libtxc_dxtn;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
