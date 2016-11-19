{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xf86miscproto-0.9.3";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "45b8ec6a4a8ca21066dce117e09dcc88539862e616e60fb391de05b36f63b095";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
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
