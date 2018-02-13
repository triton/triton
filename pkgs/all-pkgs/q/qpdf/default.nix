{ stdenv
, fetchurl
, lib
, perl

, libjpeg
, pcre
, zlib

, diffutils
, ghostscript
, libtiff
}:

let
  inherit (lib)
    boolEn
    optionals;

  version = "7.1.1";
in
stdenv.mkDerivation rec {
  name = "qpdf-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/qpdf/qpdf/${version}/${name}.tar.gz";
    #sha512Url = "mirror://sourceforge/qpdf/qpdf/${version}/${name}.sha512";
    sha256 = "8a0dbfa000a5c257abbc03721c7be277920fe0fcff08202b61c9c2464eedf2fa";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libjpeg
    pcre
    zlib
  ] ++ optionals doCheck [
    diffutils
    ghostscript
    libtiff
  ];

  postPatch = ''
    patchShebangs qpdf/fix-qdf
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
    patchShebangs qtest/bin/qtest-driver
  '';

  doCheck = false;

  meta = with lib; {
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
