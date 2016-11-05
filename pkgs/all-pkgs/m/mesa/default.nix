{ stdenv
, autoreconfHook
, bison
, fetchTritonPatch
, fetchurl
, flex
, gettext
, intltool
, python2Packages

, expat
#, file
, libclc
, libdrm
, libelf
, libffi
, libglvnd
, libomxil-bellagio
#, libva
, libvdpau
, llvm
, lm-sensors
, openssl
, wayland
, xorg

, grsecEnabled
# Texture floats are patented, see docs/patents.txt
, enableTextureFloats ? false
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

# FIXME: Wayland scanner

let
  inherit (stdenv.lib)
    boolEn
    head
    optional
    optionals
    optionalString
    splitString;

  version = "13.0.0";

  # this is the default search path for DRI drivers
  driverSearchPath = "/run/opengl-driver-${stdenv.targetSystem}";
in
stdenv.mkDerivation rec {
  name = "mesa-noglu-${version}";

  src =  fetchurl {
    urls = [
      "https://mesa.freedesktop.org/archive/${version}/mesa-${version}.tar.xz"
      "ftp://ftp.freedesktop.org/pub/mesa/${version}/mesa-${version}.tar.xz"
      # Tarballs for old releases are moved to another directory
      ("https://mesa.freedesktop.org/archive/older-versions/"
        + head (splitString "." version)
        + ".x/${version}/mesa-${version}.tar.xz")
    ];
    multihash = "QmVqR8KfVh8V5PN6R8gNHZd9hhaGZAKpTAr86XSrHDanyt";
    hashOutput = false;  # Provided by upstream directly
    sha256 = "94edb4ebff82066a68be79d9c2627f15995e1fe10f67ab3fc63deb842027d727";
  };

  nativeBuildInputs = [
    autoreconfHook
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
    libclc
    libdrm
    libelf
    libffi
    libglvnd
    libomxil-bellagio
    # FIXME: recursive dependency
    #libva
    libvdpau
    llvm
    lm-sensors
    openssl
    wayland
    xorg.dri2proto
    xorg.dri3proto
    xorg.glproto
    xorg.libpthreadstubs
    xorg.libX11
    xorg.libxcb
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libxshmfence
    xorg.libXt
    xorg.libXvMC
    xorg.libXxf86vm
    xorg.presentproto
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
  '' + /* Set runtime driver search path */ ''
    sed -i src/egl/main/egldriver.c \
      -e 's,_EGL_DRIVER_SEARCH_DIR,"${driverSearchPath}",'
  '' + /* Upstream incorrectly specifies PYTHONPATH explicitly, overriding
          the build environments PYTHONPATH */ ''
    sed -e 's,PYTHONPATH=,PYTHONPATH=$(PYTHONPATH):,g' \
      -i src/mesa/drivers/dri/i965/Makefile.am \
      -i src/gallium/drivers/freedreno/Makefile.am
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
    "--${boolEn (libglvnd != null)}-libglvnd"
    "--disable-mangling"
    "--${boolEn enableTextureFloats}-texture-float"
    "--enable-asm"
    # TODO: selinux support
    "--disable-selinux"
    "--enable-opengl"
    "--enable-gles1"
    "--enable-gles2"
    "--enable-dri"
    "--enable-gallium-extra-hud"
    "--enable-lmsensors"
    "--enable-dri3"
    "--enable-glx"
    "--disable-osmesa"
    "--enable-gallium-osmesa"
    "--enable-egl"
    "--enable-xa" # used in vmware driver
    "--enable-gbm"
    "--enable-nine" # Direct3D in Wine
    "--enable-xvmc"
    "--enable-vdpau"
    "--enable-omx"
    # FIXME: We use mesa as libgl at build time and libva depends on libgl
    #"--enable-va"
    # TODO: Figure out how to enable opencl without having a
    #       runtime dependency on clang
    "--disable-opencl"
    "--disable-opencl-icd"
    "--disable-gallium-tests"
    "--enable-shared-glapi"
    "--enable-shader-cache"
    "--enable-driglx-direct"
    "--enable-glx-tls"
    "--disable-glx-read-only-text"
    "--enable-gallium-llvm"
    "--disable-llvm-shared-libs"
    "--disable-valgrind"

    #gl-lib-name=GL
    #osmesa-libname=OSMesa
    "--with-gallium-drivers=svga,i915,ilo,r300,r600,radeonsi,nouveau,freedreno,swrast"
    "--with-sha1=libcrypto"
    "--with-dri-driverdir=$(drivers)/lib/dri"
    "--with-dri-searchpath=${driverSearchPath}/lib/dri"
    "--with-dri-drivers=i915,i965,nouveau,radeon,r200,swrast"
    "--with-vulkan-drivers=intel,radeon"
    #"--with-vulkan-icddir=DIR"
    #osmesa-bits=8
    #"--with-clang-libdir=${llvm}/lib"
    "--with-egl-platforms=x11,wayland,drm"
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
  # ToDo: probably not all .la files are completely fixed, but it shouldn't matter
  postInstall = /* Remove vendored Vulkan headers */ ''
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
  '' + /* add RPATH so the drivers can find the moved libgallium and libdricore9 */ ''
    for lib in $drivers/lib/*.so* $drivers/lib/*/*.so*; do
      if [[ ! -L "$lib" ]] ; then
        patchelf \
          --set-rpath "$(patchelf \
          --print-rpath $lib):$drivers/lib" \
          "$lib"
      fi
    done
  '' + /* set the default search path for DRI drivers; used e.g. by X server */ ''
    sed -i "$out/lib/pkgconfig/dri.pc" \
      -e 's,$(drivers),${driverSearchPath},'
  '';

  outputs = [
    "out"
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
      pgpKeyFingerprint = "8703 B670 0E7E E06D 7A39  B8D6 EDAE 37B0 2CEB 490D";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
