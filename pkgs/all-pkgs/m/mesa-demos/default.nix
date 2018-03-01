{ stdenv
, autoreconfHook
, fetchgit
, lib

, freetype
, glew
, glu
, libx11
, libxext
, opengl-dummy
, wayland
}:

let
  inherit (lib)
    boolEn;

  version = "2018-02-23";
in
stdenv.mkDerivation rec {
  name = "mesa-demos-${version}";

  src = fetchgit {
    version = 5;
    url = "https://anongit.freedesktop.org/git/mesa/demos.git";
    rev = "317f67fe5e75c685330d536f158acf6260b473d1";
    sha256 = "1536e9ee7baf145838f09b7a976d6855621d87d3c54ac247b228f2fae687ceeb";
  };

  configureFlags = [
    "--${boolEn opengl-dummy.egl}-egl"
    "--${boolEn opengl-dummy.glesv1}-gles1"
    "--${boolEn opengl-dummy.glesv2}-gles2"
    "--disable-vg"
    "--disable-osmesa"
    "--enable-libdrm"
    "--${boolEn opengl-dummy.glx}-x11"
    "--enable-wayland"
    "--${boolEn opengl-dummy.gbm}-gbm"
    "--enable-freetype2"
    #"--enable-rbug"
    #"--with-glut="
    #"--with-mesa-source="
    #"--with-system-data-files"
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    freetype
    glew
    glu
    libx11
    libxext
    opengl-dummy
    wayland
  ];

  # passthru = {
  #   srcVerification = fetchurl {
  #     inherit (src)
  #       urls
  #       outputHash
  #       outputHashAlgo;
  #     pgpsigUrls = map (n: "${n}.sig") src.urls;
  #     pgpKeyFingerprints = [
  #     ];
  #     failEarly = true;
  #   };
  # };

  meta = with lib; {
    description = "A collection of OpenGL / Mesa demos and test programs";
    homepage = https://cgit.freedesktop.org/mesa/demos/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
