{ stdenv
, fetchurl
, staticSupport ? false
}:

with {
  inherit (stdenv.lib)
    optional
    optionalString;
};

stdenv.mkDerivation rec {
  name = "gsm-${version}";
  version = "1.0.14";

  src = fetchurl {
    url = "http://www.quut.com/gsm/${name}.tar.gz";
    sha256 = "0b1mx69jq88wva3wk0hi6fcl5a52qhnq2f9p3f3jdh5k61ma252q";
  };

  postPhase =
  /* Fix include directory */ ''
    sed -i Makefile \
      -e 's,$(GSM_INSTALL_ROOT)/inc,$(GSM_INSTALL_ROOT)/include/gsm,'
  '' + optionalString (!staticSupport)
  /* Build ELF shared object */ ''
    sed -i Makefile \
      -e 's,libgsm.a,libgsm.so,' \
      -e 's/$(AR) $(ARFLAGS) $(LIBGSM) $(GSM_OBJECTS)/$(LD) -shared -Wl,-soname,libgsm.so -o $(LIBGSM) $(GSM_OBJECTS) -lc/' \
      -e '/$(RANLIB) $(LIBGSM)/d'
  '';

  makeFlags = [
    "SHELL=${stdenv.shell}"
    "INSTALL_ROOT=$(out)"
  ] ++ optional stdenv.cc.isClang "CC=clang";

  NIX_CFLAGS_COMPILE = optional (!staticSupport) "-fPIC";

  preInstall = "mkdir -pv $out/{bin,lib,man/man1,man/man3,include/gsm}";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Lossy speech compression codec";
    homepage = http://www.quut.com/gsm/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
