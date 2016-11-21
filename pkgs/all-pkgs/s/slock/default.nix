{ stdenv
, fetchurl
, xorg
}:

stdenv.mkDerivation rec {
  name = "slock-1.4";

  src = fetchurl {
    url = "http://dl.suckless.org/tools/${name}.tar.gz";
    multihash = "QmV5qxQGYjmqECgphJfaYYAxHBfuSGXU2KqHtTi4Kt9hxF";
    sha256 = "b53849dbc60109a987d7a49b8da197305c29307fd74c12dc18af0d3044392e6a";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXrandr
    xorg.libXrender
    xorg.randrproto
    xorg.renderproto
    xorg.xproto
  ];

  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    homepage = http://tools.suckless.org/slock;
    description = "Simple X display locker";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
