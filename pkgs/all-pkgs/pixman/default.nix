{ stdenv
, fetchurl

, libpng
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    platforms;
in
stdenv.mkDerivation rec {
  name = "pixman-0.34.0";

  src = fetchurl rec {
    url = "https://www.cairographics.org/releases/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "21b6b249b51c6800dc9553b65106e1e37d0e25df942c90531d4c3997aa20a88e";
  };

  buildInputs = [
    libpng
  ];

  configureFlags = [
    "--enable-openmp"
    (enFlag "loongson-mmi" (elem targetSystem platforms.mips-all) null)
    (enFlag "mmx" (elem targetSystem platforms.x86-all) null)
    (enFlag "sse2" (elem targetSystem platforms.x86-all) null)
    (enFlag "ssse3" (elem targetSystem platforms.x86-all) null)
    "--disable-vmx"
    # FIXME: check what should be enabled on Arm
    (enFlag "arm-simd" (elem targetSystem platforms.arm-all) null)
    (enFlag "arm-neon" (elem targetSystem platforms.arm-all) null)
    (enFlag "arm-iwmmxt" (elem targetSystem platforms.arm-all) null)
    (enFlag "arm-iwmmxt2" (elem targetSystem platforms.arm-all) null)
    # FIXME: check what should be enabled on Mips
    (enFlag "mips-dspr2" (elem targetSystem platforms.mips-all) null)
    "--enable-gcc-inline-asm"
    "--disable-static-testprogs"
    "--disable-timers"
    "--disable-gtk"
    (enFlag "libpng" (libpng != null) null)
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      sha1Urls = map (n: "${n}.sha1.asc") src.urls;
      pgpKeyFingerprint = "ED31 1BA0 0042 EF52 DCB4  12C5 651D 4DB8 AB5A E780";
    };
  };

  meta = with stdenv.lib; {
    description = "Low-level software library for pixel manipulation";
    homepage = https://www.cairographics.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
