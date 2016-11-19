{ stdenv
, fetchurl
, lib

, libxt
}:

stdenv.mkDerivation rec {
  name = "trapproto-3.4.3";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "ff32a0d3bc696cadc3457be9c85e9818af2b6daa2f159188bb01aad7e932a0e1";
  };

  buildInputs = [
    libxt
  ];

  meta = with lib; {
    description = "X.Org Trap protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
