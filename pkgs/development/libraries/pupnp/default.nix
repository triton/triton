{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libupnp-1.6.19";

  src = fetchurl {
    url = "mirror://sourceforge/pupnp/${name}.tar.bz2";
    sha256 = "0amjv4lypvclmi4vim2qdyw5xa6v4x50zjgf682vahqjc0wjn55k";
  };

  # Fortify Source breaks compilation
  optimize = false;
  fortifySource = false;

  meta = with stdenv.lib; {
    description = "libupnp, an open source UPnP development kit for Linux";
    homepage = http://pupnp.sourceforge.net/;
    license = "BSD-style";
    platforms = with platforms;
      x86_64-linux;
  };
}
