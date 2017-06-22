{ stdenv
, fetchurl
, lib
, util-macros

, libpthread-stubs
, libxau
, libxdmcp
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "libxcb-1.12";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    sha256 = "4adfb1b7c67e99bc9c2ccb110b2f175686576d2f792c8a71b9c8b19014057b5b";
  };

  nativeBuildInputs = [
    pythonPackages.python
    util-macros
  ];

  buildInputs = [
    libpthread-stubs
    libxau
    libxdmcp
    pythonPackages.xcb-proto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-devel-docs"
    "--enable-composite"
    "--enable-damage"
    "--enable-dpms"
    "--enable-dri2"
    "--enable-dri3"
    "--enable-glx"
    "--enable-present"
    "--enable-randr"
    "--enable-record"
    "--enable-render"
    "--enable-resource"
    "--enable-screensaver"
    "--enable-shape"
    "--enable-shm"
    "--enable-sync"
    "--enable-xevie"
    "--enable-xfixes"
    "--enable-xfree86-dri"
    "--enable-xinerama"
    "--enable-xinput"
    "--enable-xkb"
    "--enable-xprint"
    "--enable-selinux"
    "--enable-xtest"
    "--enable-xv"
    "--enable-xvmc"
    "--without-doxygen"
    "--without-launchd"
    "--without-serverside-support"
  ];

  meta = with lib; {
    description = "The X C Binding (XCB) library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
