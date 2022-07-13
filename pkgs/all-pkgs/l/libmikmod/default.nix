{ stdenv, fetchurl, texinfo, alsa-lib, pulseaudio_lib }:

let
  version = "3.3.11.1";
in
stdenv.mkDerivation rec {
  name = "libmikmod-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mikmod/libmikmod/${version}/${name}.tar.gz";
    sha256 = "ad9d64dfc8f83684876419ea7cd4ff4a41d8bcd8c23ef37ecb3a200a16b46d19";
  };

  buildInputs = [ texinfo alsa-lib pulseaudio_lib ];

  NIX_LDFLAGS = "-lasound";

  meta = with stdenv.lib; {
    description = "A library for playing tracker music module files";
    homepage    = http://mikmod.shlomifish.org/;
    license     = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms   = platforms.all;
  };
}
