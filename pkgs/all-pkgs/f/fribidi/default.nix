{ stdenv
, fetchurl
, lib
, meson
, ninja
}:

let
  version = "1.0.5";
in
stdenv.mkDerivation rec {
  name = "fribidi-${version}";

  src = fetchurl {
    url = "https://github.com/fribidi/fribidi/releases/download/v${version}/${name}.tar.bz2";
    sha256 = "6a64f2a687f5c4f203a46fa659f43dd43d1f8b845df8d723107e8a7e6158e4ce";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  mesonFlags = [
    "-Ddocs=false"
  ];

  meta = with lib; {
    description = "GNU implementation of the Unicode Bidirectional Algorithm";
    homepage = https://github.com/fribidi/fribidi;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
