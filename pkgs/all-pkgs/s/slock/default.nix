{ stdenv
, fetchurl
, lib

, libx11
, libxext
, libxrandr
, libxrender
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "slock-1.4";

  src = fetchurl {
    url = "http://dl.suckless.org/tools/${name}.tar.gz";
    multihash = "QmV5qxQGYjmqECgphJfaYYAxHBfuSGXU2KqHtTi4Kt9hxF";
    sha256 = "b53849dbc60109a987d7a49b8da197305c29307fd74c12dc18af0d3044392e6a";
  };

  buildInputs = [
    libx11
    libxext
    libxrandr
    libxrender
    xorgproto
  ];

  # Don't setuid as nixbuild doesn't allow this
  postPatch = ''
    sed -i '/chmod u+s/d' Makefile
  '';

  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
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
