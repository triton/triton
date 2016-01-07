{ stdenv
, cmake
, fetchurl

, lcms2
, libpng
, libtiff
, mj2Support ? true # MJ2 executables
, jpwlLibSupport ? true # JPWL library & executables
, jpipLibSupport ? false # JPIP library & executables
, jpipServerSupport ? false # JPIP Server
  , curl ? null
  , fcgi ? null
#, opjViewerSupport ? false # OPJViewer executable
#  , wxGTK ? null
, openjpegJarSupport ? false # Openjpeg jar (Java)
, jp3dSupport ? true # # JP3D comp
, thirdPartySupport ? false # Third party libraries - OFF: only build when found, ON: always build
, testsSupport ? false
, jdk ? null
# Inherit generics
, branch
, sha256
, version
, ...
}:

with {
  inherit (stdenv.lib)
    cmFlag
    optional
    optionals
    optionalString
    versionAtLeast;
};

assert jpipServerSupport -> jpipLibSupport && curl != null && fcgi != null;
#assert opjViewerSupport -> (wxGTK != null);
assert (openjpegJarSupport || jpipLibSupport) -> jdk != null;

stdenv.mkDerivation rec {
  name = "openjpeg-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/openjpeg.mirror/${version}/openjpeg-${version}.tar.gz";
    inherit sha256;
  };

  cmakeFlags = [
    #"-DCMAKE_INSTALL_NAME_DIR=\${CMAKE_INSTALL_PREFIX}/lib"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_CODEC=ON"
    (cmFlag "BUILD_MJ2" mj2Support)
    (cmFlag "BUILD_JPWL" jpwlLibSupport)
    (cmFlag "BUILD_JPIP" jpipLibSupport)
    (cmFlag "BUILD_JPIP_SERVER" jpipServerSupport)
    #(cmFlag "BUILD_VIEWER" opjViewerSupport)
    "-DBUILD_VIEWER=OFF"
    (cmFlag "BUILD_JAVA" openjpegJarSupport)
    (cmFlag "BUILD_JP3D" jp3dSupport)
    (cmFlag "BUILD_THIRDPARTY" thirdPartySupport)
    (cmFlag "BUILD_TESTING" testsSupport)
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    lcms2
    libpng
    libtiff
  ] ++ optionals jpipServerSupport [
    curl
    fcgi
  ] /*++ optional opjViewerSupport wxGTK*/
    ++ optional (openjpegJarSupport || jpipLibSupport) jdk;

  passthru = {
    incDir = "openjpeg-${branch}";
  };

  postInstall = optionalString (versionAtLeast "${branch}" "2.0") ''
    # Fix the pkg-config requires field
    sed -i $out/lib/pkgconfig/libopenjpwl.pc \
      -e '/Requires:/ s,openjp2,libopenjp2,'
  '';

  meta = with stdenv.lib; {
    description = "Open-source JPEG 2000 codec written in C language";
    homepage = http://www.openjpeg.org/;
    license = licenses.bsd2;
    maintainer = with maintainers; [ codyopel ];
    platforms = platforms.all;
  };
}
