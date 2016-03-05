{ stdenv, fetchurl, texinfo, alsa-lib, pulseaudio_lib }:

stdenv.mkDerivation rec {
  name = "libmikmod-3.3.7";
  src = fetchurl {
    url = "mirror://sourceforge/mikmod/${name}.tar.gz";
    sha256 = "18nrkf5l50hfg0y50yxr7bvik9f002lhn8c00nbcp6dgm5011x2c";
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
