{ stdenv
, autoreconfHook
, bison
, fetchTritonPatch
, fetchurl
, flex
, gettext
, intltool
, lib
, python2Packages

, elfutils
, expat
, libclc
, libdrm
, libffi
, libglvnd
, libomxil-bellagio
, libpthread-stubs
, libva
, libvdpau
, libx11
, libxcb
, libxdamage
, libxext
, libxfixes
, libxshmfence
, llvm
, lm-sensors
, wayland
, wayland-protocols
, xorg
, xorgproto
, zlib

, buildConfig
}:

/* Packaging design:
 * - The basic mesa ($out) contains headers and libraries (GLU is in mesa_glu
 *   now).  This or the mesa attribute (which also contains GLU) are small
 *   (~2MB, mostly headers) and are designed to be the buildInput of other
 *   packages.
 * - DRI drivers are compiled into $drivers output, which is much bigger and
 *   depends on LLVM. These should be searched at runtime in
 *   "/run/opengl-drivers/${stdenv.targetSystem}/lib/*" and so are kind-of
 *   impure (given by NixOS).  (I suppose on non-NixOS one would create the
 *   appropriate symlinks from there.)
 * - libOSMesa is in $osmesa (~4 MB)
 */

let
  inherit (lib)
    boolEn
    boolWt
    head
    optional
    optionalAttrs
    optionals
    optionalString
    splitString;

  version = "18.1.5";

  # This is the default search path for DRI drivers
  driverSearchPath = "/run/opengl-drivers/${stdenv.targetSystem}";
in
stdenv.mkDerivation rec {
  name = "${if buildConfig == "opengl-dummy" then "opengl-dummy" else "mesa-noglu"}-${version}";

  src =  fetchurl {
    urls = [
      "https://mesa.freedesktop.org/archive/mesa-${version}.tar.xz"
      "https://mesa.freedesktop.org/archive/${version}/mesa-${version}.tar.xz"
      "ftp://ftp.freedesktop.org/pub/mesa/${version}/mesa-${version}.tar.xz"
      # Tarballs for old releases are moved to another directory
      ("https://mesa.freedesktop.org/archive/older-versions/"
        + head (splitString "." version)
        + ".x/${version}/mesa-${version}.tar.xz")
    ];
    multihash = "QmW9sPT8zJvUqJrRaNFLE6Z5CNexUbKfvR82ovbkudppEj";
    hashOutput = false;  # Provided by upstream directly
    sha256 = "69dbe6f1a6660386f5beb85d4fcf003ee23023ed7b9a603de84e9a37e8d98dea";
  };

  nativeBuildInputs = [
    autoreconfHook
    python2Packages.python
  ] ++ optionals (buildConfig != "opengl-dummy") [
    bison
    flex
    gettext
    intltool
    python2Packages.Mako
    xorg.makedepend
  ];

  buildInputs = [
    expat
    libdrm
    libx11
    libxcb
    libxdamage
    libxext
    libxfixes
    libxshmfence
    xorg.libXxf86vm
    wayland
    wayland-protocols
    xorgproto
    zlib
  ] ++ optionals (buildConfig != "opengl-dummy") [
    elfutils
    libclc
    libffi
    libglvnd
    libpthread-stubs
    libomxil-bellagio
    libva
    libvdpau
    llvm
    lm-sensors
    xorg.libXvMC
  ];

  patches = [
    # fix for grsecurity/PaX
    (fetchTritonPatch {
      rev = "02cecd54589d7a77a38e4c183c24ffd30efdc9a7";
      file = "mesa/glx_ro_text_segm.patch";
      sha256 = "3f91c181307f7275f3c53ec172450b3b51129d796bacbca92f91e45acbbc861e";
    })
  ];

  postPatch = ''
    patchShebangs .
  ''
  # FIXME: _EGL_DRIVER_SEARCH_DIR was removed in 17
  # + /* Set runtime driver search path */ ''
  #   sed -i src/egl/main/egldriver.c \
  #     -e 's,_EGL_DRIVER_SEARCH_DIR,"${driverSearchPath}",'
  # ''
  + /* Upstream incorrectly specifies PYTHONPATH explicitly, overriding
       the build environments PYTHONPATH */ ''
    sed -e 's,PYTHONPATH=,PYTHONPATH=$(PYTHONPATH):,g' \
      -i src/mesa/drivers/dri/i965/Makefile.am \
      -i src/gallium/drivers/freedreno/Makefile.am
  '' + /* Files are unnecessarily pre-generated for an older LLVM version */ ''
    # https://github.com/mesa3d/mesa/commit/5233eaf9ee85bb551ea38c1e2bbd8ac167754e50
    rm src/gallium/drivers/swr/rasterizer/jitter/gen_builder.hpp
  '' + /* Install glvnd files in the current prefix */ ''
    sed -i src/egl/Makefile.am \
      -e 's/LIBGLVND_DATADIR/DATADIR/'
  '';
  # + /* Fix hardcoded OpenCL ICD install path */ ''
  #   sed -i src/gallium/targets/opencl/Makefile.{in,am} \
  #     -e "s,/etc,$out/etc,"
  # '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-largefile"
    "--disable-glx-rts"  # grsec
    "--disable-debug"
    "--disable-profile"
    "--${boolEn (buildConfig != "opengl-dummy" && libglvnd != null)}-libglvnd"
    "--disable-mangling"
    "--disable-libunwind"
    "--enable-texture-float"
    "--enable-asm"
    # TODO: selinux support
    "--disable-selinux"
    "--${boolEn (buildConfig != "opengl-dummy")}-llvm-shared-libs"
    "--enable-opengl"
    "--enable-gles1"
    "--enable-gles2"
    "--enable-dri"
    "--${boolEn (buildConfig != "opengl-dummy")}-gallium-extra-hud"
    "--${boolEn (buildConfig != "opengl-dummy")}-lmsensors"
    "--enable-dri3"
    "--enable-glx=dri"
    "--disable-osmesa"
    "--${boolEn (buildConfig != "opengl-dummy")}-gallium-osmesa"
    "--enable-egl"
    "--${boolEn (buildConfig != "opengl-dummy")}-xa" # used in vmware driver
    "--enable-gbm"
    "--${boolEn (buildConfig != "opengl-dummy")}-nine" # Direct3D in Wine
    "--${boolEn (buildConfig != "opengl-dummy")}-xvmc"
    "--${boolEn (buildConfig != "opengl-dummy")}-vdpau"
    "--${boolEn (buildConfig != "opengl-dummy")}-omx-bellagio"
    #"--${boolEn (buildConfig != "opengl-dummy")}-omx-tizonia"
    "--${boolEn (buildConfig != "opengl-dummy")}-va"
    # TODO: Figure out how to enable opencl without having a
    #       runtime dependency on clang
    "--disable-opencl"
    "--disable-opencl-icd"
    "--disable-gallium-tests"
    "--enable-shared-glapi"
    "--enable-driglx-direct"
    "--enable-glx-tls"
    "--disable-glx-read-only-text"
    "--${boolEn (buildConfig != "opengl-dummy")}-llvm"
    "--disable-valgrind"

    "--${boolWt (buildConfig != "opengl-dummy")}-gallium-drivers${if (buildConfig != "opengl-dummy") then "=svga,i915,nouveau,r300,r600,radeonsi,swrast,swr,virgl" else ""}"
    "--${boolWt (buildConfig != "opengl-dummy")}-dri-driverdir${if (buildConfig != "opengl-dummy") then "=$(drivers)/lib/dri" else ""}"
    "--with-dri-searchpath=${driverSearchPath}/lib/dri"
    "--${boolWt (buildConfig != "opengl-dummy")}-dri-drivers${if (buildConfig != "opengl-dummy") then "=i915,i965,nouveau,radeon,r200,swrast" else ""}"
    "--${boolWt (buildConfig != "opengl-dummy")}-vulkan-drivers${if (buildConfig != "opengl-dummy") then "=intel,radeon" else ""}"
    #"--with-vulkan-icddir=DIR"
    #osmesa-bits=8
    #"--with-clang-libdir=${llvm}/lib"
    "--with-platforms=x11,wayland,drm"
    #llvm-prefix
    #xvmc-libdir
    #vdpau-libdir
    #omx-libdir
    #va-libdir
    #d3d-libdir
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  # move gallium-related stuff to $drivers, so $out doesn't depend on LLVM;
  #   also move libOSMesa to $osmesa, as it's relatively big
  # TODO: probably not all .la files are completely fixed, but it shouldn't matter
  postInstall = optionalString (buildConfig != "opengl-dummy") (
      /* Remove vendored Vulkan headers */ ''
      rm -fv $out/include/vulkan/vk_platform.h
      rm -fv $out/include/vulkan/vulkan.h
    '' + ''
      mv -t "$drivers/lib/" \
        $out/lib/libXvMC* \
        $out/lib/d3d \
        $out/lib/vdpau \
        $out/lib/bellagio \
        $out/lib/libxatracker* \
        $out/lib/libvulkan_*

      mv $out/lib/dri/* $drivers/lib/dri
      rmdir "$out/lib/dri"

      mkdir -p {$osmesa,$drivers}/lib/pkgconfig
      mv -t $osmesa/lib/ $out/lib/libOSMesa*

      # share/vulkan/icd.d/
      mv $out/share/ $drivers/
      sed "s,$out,$drivers,g" -i $drivers/share/vulkan/icd.d/*

      mv -t $drivers/lib/pkgconfig/ \
        $out/lib/pkgconfig/xatracker.pc

      mv -t $osmesa/lib/pkgconfig/ \
        $out/lib/pkgconfig/osmesa.pc
    '' + /* fix references in .la files */ ''
      sed "/^libdir=/s,$out,$osmesa," -i \
        $osmesa/lib/libOSMesa*.la
    '' + /* work around bug #529, but maybe $drivers should also be patchelf'd */ ''
      find $drivers/ $osmesa/ -type f -executable -print0 | \
        xargs -0 strip -S || true
    '' + /* add RPATH so the drivers can find the moved libgallium & libdricore9 */ ''
      for lib in $drivers/lib/*.so* $drivers/lib/*/*.so*; do
        if [[ ! -L "$lib" ]] ; then
          patchelf \
            --set-rpath "$(patchelf --print-rpath $lib):$drivers/lib" \
            "$lib"
        fi
      done
    ''
  );

  preFixup = /* Fix path to dri driver dir */ ''
    grep -q '^dridriverdir=' "$out"/lib/pkgconfig/dri.pc
    sed -i "s#^dridriverdir=.*#dridriverdir=${driverSearchPath}/lib/dri#" \
      "$out"/lib/pkgconfig/dri.pc
  '';

  outputs = [
    "out"
  ] ++ optionals (buildConfig != "opengl-dummy") [
    "drivers"
    "osmesa"
  ];

  doCheck = false;

  # This breaks driver loading
  bindnow = false;

  passthru = {
    # FIXME: convert references to mesa-noglu.driverSearchPath -> opengl-dummy.driverSearchPath
    inherit driverSearchPath version;

    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        "8703 B670 0E7E E06D 7A39  B8D6 EDAE 37B0 2CEB 490D"
        "946D 09B5 E4C9 845E 6307  5FF1 D961 C596 A720 3456"
        "E3E8 F480 C52A DD73 B278  EE78 E1EC BE07 D7D7 0895"
        "71C4 B756 20BC 7570 8B4B  DB25 4C95 FAAB 3EB0 73EC"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  } // optionalAttrs (buildConfig == "opengl-dummy") {
    # opengl-dummy
    # XXX: this establishes interfaces for future use
    egl = true;
    egl-streams = true;  # To soon to tell where this will lead
    gbm = true;
    glesv1 = true;
    glesv2 = true;
    glx = true;
  };

  meta = with lib; {
    description = "An open source implementation of OpenGL";
    homepage = http://www.mesa3d.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
