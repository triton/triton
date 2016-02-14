{ fetchurl
, stdenv

, libpng

, glib
}:

with {
  inherit (stdenv)
    cc
    isArm
    isi686
    isx86_64;
  inherit (stdenv.lib)
    enFlag
    optionals;
};

stdenv.mkDerivation rec {
  name = "pixman-0.34.0";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "184lazwdpv67zrlxxswpxrdap85wminh1gmq1i5lcz6iycw39fir";
  };

  buildInputs = optionals doCheck [
    libpng
  ];

  patches = optionals stdenv.cc.isClang [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "pixman/pixman-fix-clang36.patch";
      sha256 = "4267d50a561ce07a1d8b3c5127ba3428f3470a1ba9ee3c781d0d2323d9a6e5f6";
    })
  ];

  configureFlags = [
    "--enable-openmp"
    "--disable-loongson-mmi" # mips
    (enFlag "mmx" (isi686 || isx86_64) null)
    (enFlag "sse2" (isi686 || isx86_64) null)
    (enFlag "ssse3" (isi686 || isx86_64) null)
    "--disable-vmx"
    (enFlag "arm-simd" isArm null)
    (enFlag "arm-neon" isArm null)
    "--disable-arm-iwmmxt"
    (enFlag "arm-iwmmxt2" isArm null)
    "--disable-mips-dspr2"
    (enFlag "gcc-inline-asm" cc.isGNU null)
    "--disable-static-testprogs"
    "--enable-timers"
    "--disable-gtk"
    (enFlag "libpng" (libpng != null) null)
  ];

  postInstall = glib.flattenInclude;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A low-level library for pixel manipulation";
    homepage = http://pixman.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
