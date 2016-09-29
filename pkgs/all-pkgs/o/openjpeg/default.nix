{ stdenv
, cmake
, fetchzip
, ninja

, lcms2
, libpng
, libtiff

# MJ2 executables
, mj2Support ? true
# JPWL library & executables
, jpwlLibSupport ? true
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
, jp3dSupport ? true

, channel
}:

assert jpipServerSupport ->
  jpipLibSupport
  && curl != null
  && fcgi != null;
assert opjViewerSupport -> wxGTK != null;
assert (openjpegJarSupport || jpipLibSupport) -> jdk != null;

let
  inherit (stdenv.lib)
    boolOn
    optional
    optionals
    optionalString
    versionAtLeast;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "openjpeg-${source.version}";

  src = fetchzip {
    version = source.fetchzipversion;
    url = "https://github.com/uclouvain/openjpeg/archive/"
      + "${if versionAtLeast channel "2.1" then "v" else "version."}"
      + "${source.version}.tar.gz";
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
    incDir = "openjpeg-${channel}";
  };

  postInstall = /* Fix the pkg-config requires field */
    optionalString ("${channel}" == "2.0") ''
    sed -i $out/lib/pkgconfig/libopenjpwl.pc \
      -e '/Requires:/ s,openjp2,libopenjp2,'
  '';

  meta = with stdenv.lib; {
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
