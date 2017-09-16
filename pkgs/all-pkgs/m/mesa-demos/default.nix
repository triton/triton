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

  version = "2017-09-01";
in
stdenv.mkDerivation rec {
  name = "mesa-demos-${version}";

  # Release has not been tagged in a long time.
  src = fetchgit {
    version = 3;
    url = "https://anongit.freedesktop.org/git/mesa/demos.git";
    rev = "9966d3af4b68521efe77d52540f5e1ffb8b35225";
    sha256 = "b9bc6e660e1395bdb2b333d94a72b700ed88a6b905904bb6d445d13e2ce02f9c";
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
