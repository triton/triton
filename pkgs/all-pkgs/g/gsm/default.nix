{ stdenv
, fetchurl
, lib

, staticSupport ? false
}:

let
  inherit (stdenv.lib)
    optional
    optionalString;
in

stdenv.mkDerivation rec {
  name = "gsm-1.0.16";

  src = fetchurl {
    url = "http://www.quut.com/gsm/${name}.tar.gz";
    multihash = "QmRfJYdFiqexpN9ob1CScLZFE2mQit1JaTvR3VSPr31iqj";
    sha256 = "725a3768a1e23ab8648b4df9d470aed38eb1635af3cbc8d0b64fef077236f4ce";
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

  makeFlags = [
    "SHELL=${stdenv.shell}"
    "INSTALL_ROOT=$(out)"
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
