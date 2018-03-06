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
  version = "1.0.0";
in
stdenv.mkDerivation rec {
  name = "libglvnd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "v${version}";
    sha256 = "c0b07535b14c622f64f4ba05d4c31f9d7a19790b6ec18c2d7241c48536bd7870";
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
