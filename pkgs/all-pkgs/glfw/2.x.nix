{ stdenv
, fetchurl

, mesa
, xorg
}:

stdenv.mkDerivation rec {
  name = "glfw-2.7.9";

  src = fetchurl {
    url = "mirror://sourceforge/glfw/${name}.tar.bz2";
    sha256 = "17c2msdcb7pn3p8f83805h1c216bmdqnbn9hgzr1j8wnwjcpxx6i";
  };

  buildInputs = [
    mesa
    xorg.libX11
    xorg.xproto
  ];

  buildPhase = ''
    make x11
  '';

  installPhase = ''
    mkdir -p $out
    make x11-dist-install PREFIX=$out
    mv $out/lib/libglfw.so $out/lib/libglfw.so.2
    ln -s libglfw.so.2 $out/lib/libglfw.so
  ''; 
  
  meta = with stdenv.lib; { 
    homepage = "http://glfw.sourceforge.net/";
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
