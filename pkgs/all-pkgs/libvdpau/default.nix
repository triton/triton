{ stdenv
, fetchurl

, xorg
, mesa_noglu
}:

stdenv.mkDerivation rec {
  name = "libvdpau-1.1.1";

  src = fetchurl {
    url = "http://people.freedesktop.org/~aplattner/vdpau/${name}.tar.bz2";
    sha256 = "857a01932609225b9a3a5bf222b85e39b55c08787d0ad427dbd9ec033d58d736";
  };

  configureFlags = [
    "--enable-dri2"
    "--disable-documentation"
    "--with-module-dir=${mesa_noglu.driverLink}/lib/vdpau"
  ];

  buildInputs = [
    xorg.dri2proto
    xorg.libX11
    xorg.libXext
  ];

  preInstall = ''
    installFlagsArray+=("moduledir=$out/lib/vdpau")
  '';

  meta = with stdenv.lib; {
    description = "VDPAU wrapper and trace libraries";
    homepage = http://people.freedesktop.org/~aplattner/vdpau/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
