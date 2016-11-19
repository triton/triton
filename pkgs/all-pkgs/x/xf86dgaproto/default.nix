{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xf86dgaproto-2.1";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "ac5ef65108e1f2146286e53080975683dae49fc94680042e04bd1e2010e99050";
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
