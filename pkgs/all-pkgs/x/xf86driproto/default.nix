{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xf86driproto-2.1.1";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "9c4b8d7221cb6dc4309269ccc008a22753698ae9245a398a59df35f1404d661f";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
