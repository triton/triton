{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libupnp-1.6.20";

  src = fetchurl {
    url = "mirror://sourceforge/pupnp/${name}.tar.bz2";
    sha256 = "ee3537081e3ea56f66ada10387486823989210bc98002f098305551c966e3a63";
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
