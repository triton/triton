{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
, python2

, libx11
, libxext
, xorgproto
}:

let
  date = "2019-02-13";
in
stdenv.mkDerivation rec {
  name = "libglvnd-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "f92208be88dd06a70b6f79a1cb95571e2762a9ec";
    sha256 = "5dbfd00dd84e527df8b1717a112da6f085b9845b11bdbc5cef131fa537db722c";
  };

  nativeBuildInputs = [
    autoreconfHook
    python2
  ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  postPatch = ''
    patchShebangs ./src/generate
  '';

  configureFlags = [
    "--enable-egl"
    "--enable-glx"
    "--enable-gles"
    "--enable-asm"
    "--enable-tls"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-array-bounds"
  ];

  meta = with lib; {
    description = "The GL Vendor-Neutral Dispatch library";
    homepage = https://github.com/NVIDIA/libglvnd;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
