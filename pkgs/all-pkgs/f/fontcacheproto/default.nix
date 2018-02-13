{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "fontcacheproto-0.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "1dcaa659d416272ff68e567d1910ccc1e369768f13b983cffcccd6c563dbe3cb";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "X.Org Fontcache protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
