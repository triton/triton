{ stdenv
, fetchurl
, lib

, staticSupport ? false
}:

let
  inherit (lib)
    optional
    optionalString;
in
stdenv.mkDerivation rec {
  name = "gsm-1.0.17";

  src = fetchurl {
    url = "http://www.quut.com/gsm/${name}.tar.gz";
    multihash = "QmTadgEVTjVcrV1qAbQRNUWgQiusqTT1csF4ueXTw5ov4F";
    sha256 = "855a57d1694941ddf3c73cb79b8d0b3891e9c9e7870b4981613b734e1ad07601";
  };

  postPatch = /* Fix include directory */ ''
    sed -i Makefile \
      -e 's,$(GSM_INSTALL_ROOT)/inc,$(GSM_INSTALL_ROOT)/include/gsm,'
  '' + optionalString (!staticSupport) /* Build ELF shared object */ ''
    sed -i Makefile \
      -e 's,libgsm.a,libgsm.so,' \
      -e 's/$(AR) $(ARFLAGS) $(LIBGSM) $(GSM_OBJECTS)/$(LD) -shared -Wl,-soname,libgsm.so -o $(LIBGSM) $(GSM_OBJECTS) -lc/' \
      -e '/$(RANLIB) $(LIBGSM)/d'
  '';

  preBuild = ''
    makeFlagsArray+=("INSTALL_ROOT=$out")
  '';

  makeFlags = [
    "SHELL=${stdenv.shell}"
  ] ++ optional stdenv.cc.isClang "CC=clang";

  NIX_CFLAGS_COMPILE = optional (!staticSupport) "-fPIC";

  preInstall = ''
    mkdir -pv "$out"/{bin,lib,man/man1,man/man3,include/gsm}
  '';

  meta = with lib; {
    description = "Lossy speech compression codec";
    homepage = http://www.quut.com/gsm/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
