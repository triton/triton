{ stdenv
, fetchurl
, lib
, util-macros

, libxau
}:

stdenv.mkDerivation rec {
  name = "printproto-1.0.5";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "1298316cf43b987365ab7764d61b022a3d7f180b67b423eed3456862d155911a";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libxau
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "X.Org Print protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
