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

, dri2proto
, dri3proto
, expat
, glproto
, libclc
, libdrm
, libelf
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
, libxt
, llvm
, lm-sensors
, presentproto
, wayland
, wayland-protocols
, xorg
, zlib

, grsecEnabled ? false
# Texture floats are patented, see docs/patents.txt
, enableTextureFloats ? false

, buildConfig
}:

/* Packaging design:
 * - The basic mesa ($out) contains headers and libraries (GLU is in mesa_glu
 *   now).  This or the mesa attribute (which also contains GLU) are small
 *   (~2MB, mostly headers) and are designed to be the buildInput of other
 *   packages.
 * - DRI drivers are compiled into $drivers output, which is much bigger and
 *   depends on LLVM. These should be searched at runtime in
 *   "/run/opengl-driver-${stdenv.targetSystem}/lib/*" and so are kind-of
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

  version = "17.2.0";

  # this is the default search path for DRI drivers
  driverSearchPath = "/run/opengl-driver-${stdenv.targetSystem}";
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
    multihash = "QmdWLohBTfFY77G1zHczwWxZX1yhg4pv1nj1EgKWNs6L6D";
    hashOutput = false;  # Provided by upstream directly
    sha256 = "3123448f770eae58bc73e15480e78909defb892f10ab777e9116c9b218094943";
  };

  nativeBuildInputs = [
    autoreconfHook
  ]++ optionals (buildConfig != "opengl-dummy") [
    bison
    flex
    gettext
    intltool
    python2Packages.python
    python2Packages.Mako
    xorg.makedepend
  ];

  buildInputs = [
    expat
    glproto
    libdrm
    libx11
    libxcb
    libxdamage
    libxext
    libxfixes
    xorg.libxshmfence
    wayland
    wayland-protocols
    zlib
  ] ++ optionals (buildConfig != "opengl-dummy") [
    dri2proto
    dri3proto
    libclc
    libelf
    libffi
    libglvnd
    libpthread-stubs
    libomxil-bellagio
    libva
    libvdpau
    libxt
    llvm
    lm-sensors
    presentproto
    xorg.libXvMC
    xorg.libXxf86vm
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
    rm src/gallium/drivers/swr/rasterizer/jitter/gen_builder{,_x86}.hpp
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
    # slight performance degradation, enable only for grsec
    "--${boolEn grsecEnabled}-glx-rts"
    "--disable-debug"
    "--disable-profile"
    "--${boolEn (buildConfig != "opengl-dummy" && libglvnd != null)}-libglvnd"
    "--disable-mangling"
    "--disable-libunwind"
    "--${boolEn enableTextureFloats}-texture-float"
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
    "--enable-glx"  # dri|xlib|gallium-xlib
    "--disable-osmesa"
    "--${boolEn (buildConfig != "opengl-dummy")}-gallium-osmesa"
    "--enable-egl"
    "--${boolEn (buildConfig != "opengl-dummy")}-xa" # used in vmware driver
    "--enable-gbm"
    "--${boolEn (buildConfig != "opengl-dummy")}-nine" # Direct3D in Wine
    "--${boolEn (buildConfig != "opengl-dummy")}-xvmc"
    "--${boolEn (buildConfig != "opengl-dummy")}-vdpau"
    "--${boolEn (buildConfig != "opengl-dummy")}-omx"
    "--${boolEn (buildConfig != "opengl-dummy")}-va"
    # TODO: Figure out how to enable opencl without having a
    #       runtime dependency on clang
    "--disable-opencl"
    "--disable-opencl-icd"
    "--disable-gallium-tests"
    "--enable-shared-glapi"
    "--${boolEn (buildConfig != "opengl-dummy")}-driglx-direct"
    "--enable-glx-tls"
    "--disable-glx-read-only-text"
    "--${boolEn (buildConfig != "opengl-dummy")}-llvm"
    "--disable-valgrind"

    #gl-lib-name=GL
    #osmesa-libname=OSMesa
    "--${boolWt (buildConfig != "opengl-dummy")}-gallium-drivers${if (buildConfig != "opengl-dummy") then "=svga,i915,nouveau,r300,r600,radeonsi,freedreno,swrast,swr,virgl" else ""}"
    "--${boolWt (buildConfig != "opengl-dummy")}-dri-driverdir${if (buildConfig != "opengl-dummy") then "=$(drivers)/lib/dri" else ""}"
    "--${boolWt (buildConfig != "opengl-dummy")}-dri-searchpath${if (buildConfig != "opengl-dummy") then "=${driverSearchPath}/lib/dri" else ""}"
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
        $out/lib/libxatracker*

      mkdir -p {$osmesa,$drivers}/lib/pkgconfig
      mv -t $osmesa/lib/ \
        $out/lib/libOSMesa*

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
    '' + /* set the default search path for DRI drivers */ ''
      sed -i "$out/lib/pkgconfig/dri.pc" \
        -e 's,$(drivers),${driverSearchPath},'
    ''
  );

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
    inherit driverSearchPath version;

    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        "8703 B670 0E7E E06D 7A39  B8D6 EDAE 37B0 2CEB 490D"
        "946D 09B5 E4C9 845E 6307  5FF1 D961 C596 A720 3456"
        "E3E8 F480 C52A DD73 B278  EE78 E1EC BE07 D7D7 0895"
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
