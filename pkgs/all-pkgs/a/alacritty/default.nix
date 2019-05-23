{ stdenv
, buildCargo
, fetchFromGitHub
, fetchCargoDeps
, rustc

, expat
, fontconfig
, freetype
, libx11
, libxcursor
, libxext
, libxft
, libxi
, libxinerama
, libxmu
, libxrandr
, libxrender
, libxscrnsaver
, libxt
, libxtst
, opengl-dummy
, wayland
, xorg
}:

let
  version = "0.3.2";

  src = fetchFromGitHub {
    version = 6;
    owner = "jwilm";
    repo = "alacritty";
    rev = "v${version}";
    sha256 = "08d99da1c6454cc0d2a28b0da7a49442a7ea8acb30b4c463caafecb3bd7f8db7";
  };

  deps = fetchCargoDeps {
    zipVersion = 6;
    crates-rev = "11ccda754120ad7a1db463751321af50310f3e18";
    crates-hash = "sha256:e4e979c6ee560bc1961df7a2684a96ab2b32f3e4c716e9dd4a6ac0409617042f";
    hash = "sha256:1b768b32910c16d5099978eabad5b7890e040a582b5fc895e0b376242c4cd8b0";
    inherit src;
  };
in
buildCargo {
  name = "alacritty-${version}";

  inherit src;

  CARGO_DEPS = deps;

  buildInputs = [
    expat
    fontconfig
    freetype
    libx11
    libxcursor
    libxext
    libxft
    libxi
    libxinerama
    libxmu
    libxrandr
    libxrender
    libxscrnsaver
    libxt
    libxtst
    xorg.libXxf86vm
    opengl-dummy
    wayland
  ];

  postPatch = ''
    # Disable options we don't support for our release profile
    grep -q 'lto =' Cargo.toml
    sed -i '/\(debug\|lto\) =/d' -i Cargo.toml

    # Fixup absolute path references in generated output
    grep -q 'env!("CARGO_MANIFEST_DIR")' src/renderer/mod.rs
    sed -i 's,env!("CARGO_MANIFEST_DIR"),"../../",' src/renderer/mod.rs
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
