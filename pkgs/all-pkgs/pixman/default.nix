{ fetchurl
, stdenv

, glib
}:

with {
  inherit (stdenv)
    cc;
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

  configureFlags = [
    "--enable-openmp"
    "--disable-loongson-mmi" # mips
    "--enable-mmx"  # X86 Only
    "--enable-sse2"  # X86 Only
    "--enable-ssse3"  # X86 Only
    "--disable-vmx"
    #(enFlag "arm-simd" isArm null)
    #(enFlag "arm-neon" isArm null)
    "--disable-arm-iwmmxt"
    #(enFlag "arm-iwmmxt2" isArm null)
    "--disable-mips-dspr2"
    (enFlag "gcc-inline-asm" cc.isGNU null)
    "--disable-static-testprogs"
    "--enable-timers"
    "--disable-gtk"
    "--disable-libpng"
  ];

  postInstall = glib.flattenInclude;

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
