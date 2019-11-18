{ stdenv
, fetchurl
, lib

, pcregrep ? false
  , bzip2
  , zlib
}:

let
  inherit (lib)
    boolEn
    optionals;

  tarballUrls = version: [
    "https://ftp.pcre.org/pub/pcre/pcre-${version}.tar.bz2"
    "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${version}.tar.bz2"
    "mirror://sourceforge/pcre/pcre/${version}/pcre-${version}.tar.bz2"
  ];

  version = "8.43";
in
stdenv.mkDerivation rec {
  name = "pcre-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "91e762520003013834ac1adb4a938d53b22a216341c061b0cf05603b290faf6b";
  };

  buildInputs = optionals pcregrep [
    bzip2
    zlib
  ];

  configureFlags = [
    "--enable-pcre8"
    "--enable-pcre16"
    "--enable-pcre32"
    "--enable-cpp"
    "--enable-jit"
    "--${boolEn pcregrep}-pcregrep-jit"
    "--enable-utf"
    "--enable-unicode-properties"
    "--${boolEn (pcregrep && zlib != null)}-pcregrep-libz"
    "--${boolEn (pcregrep && bzip2 != null)}-pcregrep-libbz2"
    "--disable-pcretest-libedit"
    "--disable-pcretest-libreadline"
    "--disable-valgrind"
    "--disable-coverage"
  ];

  postInstall = ''
    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv "$bin"/bin/pcre-config "$dev"/bin

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
  '';

  postFixup = ''
    ln -sv "$lib"/lib/* "$dev"/lib
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "8.43";
      inherit (src)
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "45F6 8D54 BBE2 3FB3 039B  46E5 9766 E084 FB0F 43D8";
      };
    };
  };

  meta = with lib; {
    description = "Perl Compatible Regular Expressions";
    homepage = "http://www.pcre.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
