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
  name = "gsm-1.0.18";

  src = fetchurl {
    url = "http://www.quut.com/gsm/${name}.tar.gz";
    multihash = "QmPAYeHsz2KszyKC4baG7Bybh4pW3o4oB2vJnWjjxaqcmC";
    sha256 = "04f68087c3348bf156b78d59f4d8aff545da7f6e14f33be8f47d33f4efae2a10";
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
