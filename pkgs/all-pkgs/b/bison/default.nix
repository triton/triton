{ stdenv
, cc
, fetchurl
, lib
, gnum4

, type ? "full"
}:

let
  inherit (lib)
    boolEn
    optionals;

  tarballUrls = version: [
    "mirror://gnu/bison/bison-${version}.tar.xz"
  ];

  version = "3.5";
in
stdenv.mkDerivation rec {
  name = "bison-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "55e4a023b1b4ad19095a5f8279f0dc048fa29f970759cea83224a6d5e7a3a641";
  };

  nativeBuildInputs = [
    cc
    gnum4.bin
  ];

  # We need this for bison to work correctly when being
  # used during the build process
  propagatedBuildInputs = [
    gnum4.bin
  ];

  # Don't generate examples
  postPatch = ''
    sed -i '/\$(nodist_examples.*_SOURCES)/d' Makefile.in
  '';

  configureFlags = [
    "--${boolEn (type != "bootstrap")}-threads"
    "--${boolEn (type != "bootstrap")}-assert"
    "--${boolEn (type != "bootstrap")}-nls"
    # We don't actually need perl for building bison
    "ac_cv_path_PERL=perl"
  ];

  postFixup = ''
    mkdir -p "$bin"/share2
    mv "$bin"/share/{aclocal,bison} "$bin"/share2
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
    rm -rv "$bin"/lib
  '';

  outputs = [
    "bin"
  ] ++ optionals (type == "full") [
    "man"
  ];

  patchShebangsIgnore = [
    "${placeholder "bin"}/bin/yacc"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.5";
      inherit (src) outputHashAlgo;
      outputHash = "55e4a023b1b4ad19095a5f8279f0dc048fa29f970759cea83224a6d5e7a3a641";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "7DF8 4374 B1EE 1F97 64BB  E25D 0DDC AA32 78D5 264E";
      };
    };
  };

  meta = with lib; {
    description = "Yacc-compatible parser generator";
    homepage = "http://www.gnu.org/software/bison/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
