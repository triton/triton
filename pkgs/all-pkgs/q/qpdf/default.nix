{ stdenv
, fetchurl
, perl

, pcre
, zlib

, diffutils
, ghostscript
, libtiff
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals;
in
stdenv.mkDerivation rec {
  name = "qpdf-6.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/qpdf/${name}.tar.gz";
    multihash = "QmYAaPsgvdzYAv3svDDBwaaM2k5JPnkw8ky97T2oNtCi2X";
    sha1Url = "mirror://sourceforge/qpdf/${name}.sha1";
    sha256 = "a9fdc7e94d38fcd3831f37b6e0fe36492bf79aa6d54f8f66062cf7f9c4155233";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    pcre
    zlib
  ] ++ optionals doCheck [
    diffutils
    ghostscript
    libtiff
  ];

  postPatch = ''
    patchShebangs ./qpdf/fix-qdf
  '';

  configureFlags = [
    "--disable-insecure-random"
    "--enable-os-secure-random"
    #"--disable-external-libs"
    "--disable-werror"
    "--${boolEn (
      doCheck
      && ghostscript != null
      && libtiff != null)}-test-compare-images"
    "--${boolEn doCheck}-show-failed-test-output"
    "--disable-doc-maintenance"
    "--disable-html-doc"
    "--disable-pdf-doc"
    "--disable-validate-doc"
  ];

  preCheck = ''
    patchShebangs ./qtest/bin/qtest-driver
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Programs to inspect & manipulate PDF files";
    homepage = http://qpdf.sourceforge.net/;
    license = licenses.artistic2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
