{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
, perl
, python2

, glproto
, libx11
, libxext
, xproto
}:

stdenv.mkDerivation rec {
  name = "libglvnd-2017-08-30";

  src = fetchFromGitHub {
    version = 3;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "5ff90a15681612be60ef712f4aba962267ceaf13";
    sha256 = "087954d8a9d87b9b259a4014819ef1d226883efc8cd138e54f14690a59e394f1";
  };

  nativeBuildInputs = [
    autoreconfHook
    python2
  ];

  buildInputs = [
    glproto
    libx11
    libxext
    xproto
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
