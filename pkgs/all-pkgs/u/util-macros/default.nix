{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "util-macros-1.19.0";

  src = fetchurl {
    url = "mirror://xorg/individual/util/${name}.tar.bz2";
    sha256 = "2835b11829ee634e19fa56517b4cfc52ef39acea0cd82e15f68096e27cbed0ba";
  };

  meta = with lib; {
    description = "X.Org autotools utility macros";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
