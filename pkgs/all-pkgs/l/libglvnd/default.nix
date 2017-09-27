{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
, python2

, glproto
, libx11
, libxext
, xproto
}:

stdenv.mkDerivation rec {
  name = "libglvnd-2017-09-13";

  src = fetchFromGitHub {
    version = 3;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "fe4a384094f59374b752faf2230ce810c02d98c3";
    sha256 = "fc580126c750f7279a65f5f7928997e20242a8c99cdec773d9077a01727d78bf";
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
