{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, gettext
, lib
, meson
, ninja
, opengl-dummy
, python3Packages

, egl-headers
, elfutils
, expat
, libclc
, libdrm
, libffi
, libglvnd
#, libomxil-bellagio
, libpthread-stubs
, libselinux
, libva
, libvdpau
, libx11
, libxcb
, libxdamage
, libxext
, libxfixes
, libxrandr
, libxshmfence
, llvm
, lm-sensors
, opengl-headers
, vulkan-headers
, wayland
, wayland-protocols
, xorg
, xorgproto
, zlib
}:

let
  inherit (lib)
    boolString
    boolTf
    head
    optionalAttrs
    optionals
    optionalString
    splitString;

  version = "19.1.1";
in
stdenv.mkDerivation rec {
  name = "mesa-${version}";

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
    #multihash = "QmZ31VE9JqXj1YW6iGcRTxUQJCwUDa8EiVcRmPP8Pc3ypL";
    hashOutput = false;
    sha256 = "72114b16b4a84373b2acda060fe2bb1d45ea2598efab3ef2d44bdeda74f15581";
  };

  nativeBuildInputs = [
    bison
    flex
    gettext
    meson
    ninja
    python3Packages.Mako
    python3Packages.python
  ];

  buildInputs = [
    elfutils
    expat
    libclc
    libdrm
    libffi
    libglvnd
    #libomxil-bellagio  # FIXME
    libpthread-stubs
    libva
    libvdpau
    libselinux
    libx11
    libxcb
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxshmfence
    #xorg.libXvMC
    llvm
    lm-sensors
    xorg.libXxf86vm
    wayland
    wayland-protocols
    xorgproto
    zlib
  ];

  postPatch = ''
    patchShebangs .
  ''
  # FIXME: _EGL_DRIVER_SEARCH_DIR was removed in 17
  # + /* Set runtime driver search path */ ''
  #   sed -i src/egl/main/egldriver.c \
  #     -e 's,_EGL_DRIVER_SEARCH_DIR,"${driverSearchPath}",'
  # ''
   + /* Files are unnecessarily pre-generated for an older LLVM version */ ''
    # https://github.com/mesa3d/mesa/commit/5233eaf9ee85bb551ea38c1e2bbd8ac167754e50
    local gen_builder='src/gallium/drivers/swr/rasterizer/jitter/gen_builder.hpp'
    if [ -f "$gen_builder" ]; then
      rm -v "$gen_builder"
    fi
  '' + ''
    sed -i src/util/disk_cache.c \
      -e '/#ifdef ENABLE_SHADER_CACHE/a #define __STDC_FORMAT_MACROS 1\n#include <inttypes.h>'
    #cat src/util/disk_cache.c; return 1
  '' + /* Unvendor Khronos headers */ ''
    local -a mesa_headers
    mapfile -t mesa_headers < <(
      find \
        '${egl-headers}/include/' \
        '${opengl-headers}/include/' \
        '${vulkan-headers}/include/' \
        -maxdepth 2 \
        -type f \
        -name '*.h'
    )
    if [ -z "''${mesa_headers[*]}" ]; then
      echo 'unvendoring mesa headers failed' >&2
      return 1
    fi
    local mesa_glapidir
    local mesa_header
    for mesa_header in "''${mesa_headers[@]}"; do
      printf 'replacing vendored header: %s\n' "$mesa_header"
      mesa_glapidir=""
      mesa_glapidir="$(basename "$(dirname "$mesa_header")")"
      if [[ "$mesa_glapidir" == +('GLSC'|'GLSC2') ]]; then
        continue
      fi
      install -D -m644 -v "$mesa_header" \
        include/"$mesa_glapidir"/"$(basename "$mesa_header")"
    done
  '' + /**/ ''
    #ls -al src/mapi/glapi/; return 1
    #m -v src/egl/g_egldispatchstubs.{c,h}
    install -D -m644 -v '${egl-headers}/share/egl-registry/egl.xml' \
      src/egl/generate/egl.xml
    #rm -v src/mapi/glapi/{{glapi_mapi_tmp,glprocs,glapitemp,glapitable}.h,glapi_gentable.c}
    install -D -m644 -v '${opengl-headers}/share/opengl-registry/gl.xml' \
      src/mapi/glapi/registry/gl.xml
    install -D -m644 -v '${vulkan-headers}/share/vulkan-registry/vk.xml' \
      src/vulkan/registry/vk.xml
  '' + /* HACK: remove for > 19.1.x
    https://gitlab.freedesktop.org/mesa/mesa/commit/5555db103e5c5a0932ed5f014231f04e129ab9e0 */ ''
    sed -i src/amd/vulkan/radv_cmd_buffer.c \
      -e '/radv_CmdDrawIndirectCountAMD/,+22d' \
      -e '/radv_CmdDrawIndexedIndirectCountAMD/,+23d'
  '' + /* Fix meson searching non-existant pkg-config path. */ ''
    sed -i meson.build \
      -e "s|wayland-scanner', native: true|wayland-scanner'|"
  '';
  # + /* Fix hardcoded OpenCL ICD install path */ ''
  #   sed -i src/gallium/targets/opencl/Makefile.{in,am} \
  #     -e "s,/etc,$out/etc,"
  # '';

  #preConfigure = ''
  #  mesonFlagsArray+=("-Ddri-drivers-path=$dri_drivers/lib/dri")
  #'';

  mesonFlags = [
    "-Dplaforms=drm,surfaceless,x11,wayland"
    "-Ddri3=true"
    # https://wiki.gentoo.org/wiki/Intel#Feature_support
    # https://www.x.org/wiki/RadeonFeature/
    # Not supported: i915,r100,r200,swrast
    # TODO: drop i965 once Intel Broadwell is minimum supported x86 cpu.
    "-Ddri-drivers=i965,nouveau"
    "-Ddri-search-path=${opengl-dummy.driverSearchPath}"
    # Not supported: i915,r300,svga
    "-Dgallium-drivers=iris,nouveau,r600,radeonsi,swrast,swr,virgl"
    # NOTE: kmsro is currently Arm only, but could be added to other arches.
    # Arm: etnaviv,freedreno,kmsro,lima,panfrost,v3d,vc4,tegra
    "-Dgallium-extra-hud=true"
    "-Dgallium-vdpau=true"
    "-Dgallium-xvmc=false"
    "-Dgallium-omx=disabled"  # FIXME: package tizonia
    "-Dgallium-va=true"
    "-Dgallium-xa=true"
    "-Dgallium-nine=true"
    "-Dgallium-opencl=icd"
    "-Dvulkan-drivers=amd,intel"
    #"-Dvulkan-icd-dir="
    "-Dvulkan-overlay-layer=false"  # FIXME: need glslangValidator
    "-Dgles2=true"
    "-Dgbm=true"
    "-Dglx=dri"
    "-Degl=true"
    "-Dglvnd=true"
    "-Dllvm=true"
    "-Dvalgrind=false"
    "-Dlibunwind=false"
    "-Dlmsensors=true"
    "-Dselinux=true"
    "-Dosmesa=gallium"
    #"-Dosmesa-bits="
    # knl = Intel Knights Landing
    # skx = Intel Skylake-X AVX512
    "-Dswr-arches=avx,avx2,skx,knl"
    #"-Dpower8="
    "-Dxlib-lease=true"
  ];

  postInstall = (
    ''
      mkdir -pv "$dri_drivers"/lib/
      mv -v -t "$dri_drivers"/lib/ \
        "$out"/lib/libXvMC* \
        "$out"/lib/d3d \
        "$out"/lib/vdpau \
        "$out"/lib/libxatracker* \
        "$out"/lib/libvulkan_*  # FIXME

      mkdir -pv "$dri_drivers"/lib/dri/
      mv -v "$out"/lib/dri/* "$dri_drivers"/lib/dri/
      rmdir "$out"/lib/dri/

      mkdir -pv {"$osmesa","$dri_drivers"}/lib/pkgconfig
      mv -v "$out"/lib/libOSMesa* "$osmesa"/lib/

      # Vulkan ICD loader files.
      mkdir -pv "$vulkan_drivers"/share/
      mv -v "$out"/share/vulkan/ "$vulkan_drivers"/share/
      sed -i "$vulkan_drivers"/share/vulkan/icd.d/* \
        -e "s,$out,$vulkan_drivers,g"

      mv -v "$out"/lib/pkgconfig/xatracker.pc \
        "$dri_drivers"/lib/pkgconfig/

      mv -v "$out"/lib/pkgconfig/osmesa.pc \
        "$osmesa"/lib/pkgconfig/
    '' + /* work around bug #529, but maybe $drivers should also be patchelf'd */ ''
      find "$dri_drivers"/ "$osmesa"/ -type f -executable -print0 | \
        xargs 1 strip -S || true
    '' + /* add RPATH so the drivers can find the moved libgallium & libdricore9 */ ''
      for lib in "$dri_drivers"/lib/*.so* "$dri_drivers"/lib/*/*.so*; do
        if [[ ! -L "$lib" ]] ; then
          patchelf \
            --set-rpath "$(patchelf --print-rpath "$lib"):$dri_drivers/lib" \
            "$lib"
        fi
      done
    ''
  );

  preFixup = /* Fix path to dri driver dir */ ''
    grep -q '^dridriverdir=' "$out"/lib/pkgconfig/dri.pc
    sed -i "s#^dridriverdir=.*#dridriverdir=${opengl-dummy.driverSearchPath}/lib/dri#" \
      "$out"/lib/pkgconfig/dri.pc
  '';

  outputs = [
    "out"
    "dri_drivers"
    "osmesa"
    "vulkan_drivers"
  ];

  doCheck = false;

  # This breaks driver loading
  bindnow = false;

  passthru = {
    inherit version;

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Dylan Baker
          "71C4 B756 20BC 7570 8B4B  DB25 4C95 FAAB 3EB0 73EC"
          # Juan A. Suarez Romero
          "A5CC 9FEC 93F2 F837 CB04 4912 3369 09B6 B25F ADFA"
          # Emil Velikov
          "8703 B670 0E7E E06D 7A39  B8D6 EDAE 37B0 2CEB 490D"

          "946D 09B5 E4C9 845E 6307  5FF1 D961 C596 A720 3456"
          "E3E8 F480 C52A DD73 B278  EE78 E1EC BE07 D7D7 0895"
        ];
      };
    };
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
