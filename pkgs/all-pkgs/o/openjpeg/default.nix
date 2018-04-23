{ stdenv
, cmake
, fetchzip
, lib
, ninja

, lcms2
, libpng
, libtiff
, zlib

# MJ2 executables
, mj2Support ? false
# JPWL library & executables
, jpwlLibSupport ? false
# JPIP library & executables
, jpipLibSupport ? false
  , jdk
# JPIP Server
, jpipServerSupport ? false
  , curl
  , fcgi
# OPJViewer executable
, opjViewerSupport ? false
  , wxGTK
# Openjpeg jar (Java)
, openjpegJarSupport ? false
# JP3D comp
, jp3dSupport ? false

, channel ? "2.3"
}:

assert jpipServerSupport ->
  jpipLibSupport
  && curl != null
  && fcgi != null;
assert opjViewerSupport -> wxGTK != null;
assert (openjpegJarSupport || jpipLibSupport) -> jdk != null;

let
  inherit (lib)
    boolOn
    optional
    optionals
    optionalString
    versionAtLeast;

  sources = {
    "2.3" = {
      fetchzipversion = 6;
      version = "2.3.0";
      sha256 = "53f23a4d528caf4cc436c42975d3ab029a422a57ea558689d95984205aa0cea9";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "openjpeg-${source.version}";

  src = fetchzip {
    version = source.fetchzipversion;
    url = "https://github.com/uclouvain/openjpeg/archive/"
      + "v${source.version}.tar.gz";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    lcms2
    libpng
    libtiff
    zlib
  ] ++ optionals jpipServerSupport [
    curl
    fcgi
  ] ++ optional opjViewerSupport [
    wxGTK
  ] ++ optionals (openjpegJarSupport || jpipLibSupport) [
    jdk
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_CODEC=ON"
    "-DBUILD_MJ2=${boolOn mj2Support}"
    "-DBUILD_JPWL=${boolOn jpwlLibSupport}"
    "-DBUILD_JPIP=${boolOn jpipLibSupport}"
    "-DBUILD_JPIP_SERVER=${boolOn jpipServerSupport}"
    "-DBUILD_VIEWER=${boolOn opjViewerSupport}"
    "-DBUILD_VIEWER=OFF"
    "-DBUILD_JAVA=${boolOn openjpegJarSupport}"
    "-DBUILD_JP3D=${boolOn jp3dSupport}"
    "-DBUILD_THIRDPARTY=OFF"
    "-DBUILD_TESTING=OFF"
  ];

  passthru = {
    inherit channel;
  };

  meta = with lib; {
    description = "Open-source JPEG 2000 codec written in C language";
    homepage = http://www.openjpeg.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
