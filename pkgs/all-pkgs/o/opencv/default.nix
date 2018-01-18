{ stdenv
, cmake
, fetchurl
, lib
, unzip

, atk
, bzip2
, cairo
, ffmpeg
#, gdal
, gdk-pixbuf
, glib
, gtk_2
, gtk_3
#, gtkglext ???
, gst-plugins-base
, gstreamer
#, ipp
, jasper
#, java
, libdc1394
, libgphoto2
, libjpeg
, libpng
, libraw1394
, libtiff
, libwebp
, opengl-dummy
#, nvidia-cuda-toolkit
#, openexr
, pango
, python2Packages
#, qt5
#, tbb
, v4l_lib
#, vtk
#, xine-lib
, zlib

, channel
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolOn
    elem
    platforms;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "opencv-${source.version}";

  src = fetchurl {
    url = "mirror://sourceforge/opencvlibrary/opencv-unix/${source.version}/"
      + "${name}.zip";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    cmake
    unzip
  ];

  buildInputs = [
    atk
    bzip2
    cairo
    ffmpeg
    gdk-pixbuf
    glib
    gtk_2
    gtk_3
    gst-plugins-base
    gstreamer
    jasper
    libdc1394
    libgphoto2
    libjpeg
    libpng
    libraw1394
    libtiff
    libwebp
    #openexr
    opengl-dummy
    pango
    #python2Packages.numpy
    #python2Packages.python
    v4l_lib
    zlib
  ];

  cmakeFlags = [
    # BUILD_CUDA_STUBS
    "-DBUILD_DOCS=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_JASPER=OFF"
    "-DBUILD_JPEG=OFF"
    "-DBUILD_OPENEXR=OFF"
    # BUILD_PACKAGE
    # BUILD_PERF_TESTS
    "-DBUILD_PNG=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_TBB=OFF"
    "-DBUILD_TESTS=OFF"
    "-DBUILD_TIFF=OFF"
    "-DBUILD_WITH_DEBUG_INFO=OFF"
    "-DBUILD_WITH_DYNAMIC_IPP=OFF"
    "-DBUILD_ZLIB=OFF"
    # BUILD_opencv_apps
    "-DENABLE_AVX=OFF"
    "-DENABLE_AVX2=OFF"
    "-DENABLE_COVERAGE=OFF"
    # ENABLE_FAST_MATH
    "-DENABLE_FMA3=OFF"
    # ENABLE_IMPL_COLLECTION
    # ENABLE_NOISY_WARNINGS
    # ENABLE_OMIT_FRAME_POINTER
    # ENABLE_POPCNT
    # ENABLE_PRECOMPILED_HEADERS
    "-DENABLE_PROFILING=OFF"
    # ENABLE_SOLUTION_FOLDERS
    "-DENABLE_SSE=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DENABLE_SSE2=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DENABLE_SSE3=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DENABLE_SSE41=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DENABLE_SSE42=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DENABLE_SSSE3=${boolOn (elem targetSystem platforms.x86-all)}"
    # WITH_1394=${boolOn (libdc1394 != null)}
    # WITH_CLP
    # WITH_CUBLAS
    # WITH_CUDA=${boolOn ( != null)}
    # WITH_CUFFT
    # WITH_EIGEN=${boolOn ( != null)}
    "-DWITH_FFMPEG=${boolOn (ffmpeg != null)}"
    # WITH_GDAL
    # WITH_GIGEAPI
    "-DWITH_GPHOTO2=${boolOn (libgphoto2 != null)}"
    "-DWITH_GSTREAMER=${boolOn (gst-plugins-base != null && gstreamer != null)}"
    "-DWITH_GSTREAMER_0_10=OFF"
    "-DWITH_GTK=${boolOn (gtk_2 != null || gtk_3 != null)}"
    "-DWITH_GTK_2_X=OFF"
    "-DWITH_IPP=OFF"
    "-DWITH_IPP_A=OFF"
    "-DWITH_JASPER=${boolOn (jasper != null)}"
    "-DWITH_JPEG=${boolOn (libjpeg != null)}"
    "-DWITH_LIBV4L=${boolOn (v4l_lib != null)}"
    "-DWITH_MATLAB=OFF"
    # WITH_NVCUVID=${boolOn ( != null)}
    # WITH_OPENCL=${boolOn ( != null)}
    # WITH_OPENCLAMDBLAS
    # WITH_OPENCLAMDFFT
    # WITH_OPENCL_SVM
    #"-DWITH_OPENEXR=${boolOn (openexr != null)}"
    /**/"-DWITH_OPENEXR=OFF"
    "-DWITH_OPENGL=${boolOn (opengl-dummy != null)}"
    # WITH_OPENMP
    # WITH_OPENNI
    # WITH_OPENNI2
    "-DWITH_PNG=${boolOn (libpng != null)}"
    # WITH_PTHREADS_PF
    # WITH_PVAPI
    # WITH_QT
    # WITH_TBB
    "-DWITH_TIFF=${boolOn (libtiff != null)}"
    # WITH_UNICAP
    "-DWITH_V4L=${boolOn (v4l_lib != null)}"
    # WITH_VA
    # WITH_VA_INTEL
    # WITH_MFX
    "-DWITH_VTK=OFF"
    "-DWITH_WEBP=${boolOn (libwebp != null)}"
    #WITH_XIMEA
    #"WITH_XINE=${boolOn (xine-lib != null)}"
    /**/"-DWITH_XINE=OFF"
  ];

  buildDirCheck = false;

  meta = with lib; {
    description = "Algorithms and code for various computer vision problems";
    homepage = http://opencv.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
