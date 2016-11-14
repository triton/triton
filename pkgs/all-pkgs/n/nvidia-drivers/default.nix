{ stdenv
, fetchTritonPatch
, fetchurl
, makeWrapper
, nukeReferences

, buildConfig ? "all"
, channel

# Kernelspace dependencies
, kernel ? null

# Userspace dependencies
, wayland
, xorg
, zlib

# Just needed for the passthru driver path
, mesa_noglu

, libsOnly ? false
}:

/* NOTICE: ONLY versions 352+ are supported on Triton
 *
 * BETA:        367.xx,   xorg <=1.18.x, linux <=4.7
 * SHORTLIVED:  364.xx,   xorg <=1.18.x, linux <=4.5
 * LONGLIVED:   367.xx,   xorg <=1.18.x, linux <=4.7 (stable) <- default
 * TESLA:       352.xx,   xorg <=1.18.x, linux <=4.5
 * UNSUPPORTED: 340.xx,   xorg <=1.18.x, linux <=4.5
 * UNSUPPORTED: 304.xx,   xorg <=1.18.x, linux <=4.5
 * UNSUPPORTED: 173.14.x, xorg <=1.15.x, linux <=3.13
 * UNSUPPORTED: 96.43.x,  xorg <=1.12.x, linux <=3.7
 * UNSUPPORTED: 71.86.x,  xorg <=?,      linux <=?
 *
 * If your gpu requires a version that is unsupported it is
 * recommended to use the nouveau driver.
 *
 * Information on the GLVND transition: https://goo.gl/4mraRX
 */

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    any
    elem
    makeSearchPath
    optionals
    optionalString
    platforms
    versionAtLeast
    versionOlder;

  source = ((import ./sources.nix { })."${channel}");

  version = "${source.versionMajor}.${source.versionMinor}";
  buildKernelspace = any (n: n == buildConfig) [ "kernelspace" "all" ];
  buildUserspace = any (n: n == buildConfig) [ "userspace" "all" ];
in

assert any (n: n == buildConfig) [
  "kernelspace"
  "userspace"
  "all"
];
assert buildKernelspace -> kernel != null;
assert libsOnly -> !buildKernelspace;
assert channel == "tesla" -> elem targetSystem platforms.x86_64-linux;

# FIXME: remove once drivers are updated upstream to support 4.7+
assert versionOlder source.versionMajor "364" ->
  versionOlder kernel.version "4.7";

assert elem targetSystem platforms.bit32 && !libsOnly ->
  throw "Only libs are supported for 32bit platforms";

stdenv.mkDerivation {
  name = "nvidia-drivers-${buildConfig}-${version}"
    + "${optionalString buildKernelspace "-${kernel.version}"}";

  src = fetchurl {
    url =
      if elem targetSystem platforms.i686-linux then
        "mirror://nvidia/XFree86/Linux-x86/${version}/"
          + "NVIDIA-Linux-x86-${version}.run"
      else if elem targetSystem platforms.x86_64-linux then
        "mirror://nvidia/XFree86/Linux-x86_64/${version}/"
          + "NVIDIA-Linux-x86_64-${version}"
          + "${if channel == "tesla" then "" else "-no-compat32"}.run"
      else
        throw "The NVIDIA drivers are not supported for the `${targetSystem}` platform";
    sha256 =
      if elem targetSystem platforms.i686-linux then
        source.sha256i686
      else if elem targetSystem platforms.x86_64-linux then
        source.sha256x86_64
      else
        throw "The NVIDIA drivers are not supported for the `${targetSystem}` platform";
  };

  nativeBuildInputs = [
    makeWrapper
    nukeReferences
  ];

  unpackPhase =
    /* This function prints the first 20 lines of the file, then awk's for
       the line with `skip=` which contains the line number where the tarball
       begins, then tails to that line and pipes the tarball to the required
       decompression utility (gzip/xz), which interprets the tarball, and
       finally pipes the output to tar to extract the contents. This is
       exactly what the cli commands in the `.run` file do, but there is an
       issue with some versions so it is best to do it manually instead. */ ''
      runHook 'preUnpack'

      local skip

      # The line you are looking for `skip=` is within the first 20 lines of
      # the file, make sure that you aren't grepping/awking/sedding the entire
      # 60,000+ line file for 1 line.
      skip="$(awk -F= '{if(NR<=20&&/skip=/){print $2;exit}}' "$src")"
      # Make sure skip is an integer
      skip="''${skip//[^0-9]/}"

      # If the `skip=' value is null, more than likely the hash wasn't updated
      # after bumping the version.
      [ ! -z "$skip" ]

      tail -n +"$skip" "$src" | xz -d | tar xvf -

      sourceRoot="$(pwd)"
      export sourceRoot

      runHook 'postUnpack'
    '';

  postUnpack =
    /* Rather than patching a patch, create a symlink with
       a predictable name. */ ''
      ln -fsv \
        nvidia-application-profiles-${version}-rc \
        nvidia-application-profiles-rc
    '';

  patchFlags = [
    "--follow-symlinks"
  ];

  patches =
    optionals (versionAtLeast source.versionMajor "367") [
      (fetchTritonPatch {
        rev = "daeb3f279f0c923644b352ac318e7f13c8692f0c";
        file = "nvidia-drivers/nvidia-drivers-367.35-fix-application-profiles-typo.patch";
        sha256 = "caae27b1883c5c6b3c4684720d2902421ad16ab49577ee7302a95c964236141d";
      })
    ];

  postPatch =
    # 364+ & Linux 4.7
    optionalString (
      buildKernelspace
      && versionAtLeast kernel.version "4.7"
      && versionAtLeast source.versionMajor "364"
      && versionOlder version "367.44") (
      /* Collision between function added in Linux 4.7 */ ''
        sed -i kernel/nvidia-uvm/uvm_linux.h \
          -i kernel/nvidia-uvm/uvm8_gpu.c \
          -e 's/radix_tree_empty/nvidia_radix_tree_empty/'
      '' + /* Change to drm_gem_object_lookup in Linux 4.7 */ ''
        sed -i kernel/nvidia-drm/nvidia-drm-fb.c \
          -i kernel/nvidia-drm/nvidia-drm-gem.c \
          -i kernel/nvidia-uvm/uvm_linux.h \
          -e 's/drm_gem_object_lookup(dev, file,/drm_gem_object_lookup(file,/'
      ''
    );

  configurePhase = ":";

  kernel =
    if buildKernelspace then
      kernel.dev
    else
      null;

  disallowedReferences =
    if buildKernelspace then
      [ kernel.dev ]
    else
      [ ];

  # Make sure anything that isn't declared within the derivation
  # is inherited so that it is passed to the builder.
  inherit version;
  inherit (source) versionMajor;

  builder = ./builder-generic.sh;

  allLibPath = makeSearchPath "lib" [
    stdenv.cc.cc
    wayland
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXdmcp
    xorg.libXext
    xorg.libXrandr
    xorg.libXv
    zlib
  ];

  buildPhase = optionalString buildKernelspace (''
    local kernelBuild
    local kernelSource

    # Create the kernel module
    echo "Building the NVIDIA Linux kernel modules against: $kernel"

    cd "$sourceRoot/kernel"

    kernelVersion="$(ls "$kernel/lib/modules")"
    [ ! -z "$kernelVersion" ]
    kernelSource="$kernel/lib/modules/$kernelVersion/source"
    kernelBuild="$kernel/lib/modules/$kernelVersion/build"

    # $src is also used by the makefile
    unset src

    make \
      SYSSRC="$kernelSource" \
      SYSOUT="$kernelBuild" \
      -j$NIX_BUILD_CORES \
      -l$NIX_BUILD_CORES \
      module
  '' + optionalString (versionOlder source.versionMajor "355"
                       && targetSystem == "x86_64-linux") ''
    # Versions 355+ combines the make files for all kernel modules. So for
    # older versions make sure to build the Cuda UVM module
    cd "$sourceRoot/kernel/uvm"
    make \
      SYSSRC="$kernelSource" \
      SYSOUT="$kernelBuild" \
      -j$NIX_BUILD_CORES \
      -l$NIX_BUILD_CORES \
      module
  '' + ''
    cd "$sourceRoot"
  '');

  installPhase = optionalString buildKernelspace (
    #
    ## Kernel modules
    #
    /* NVIDIA kernel module */ ''
      nuke-refs 'kernel/nvidia.ko'
      install -D -m644 -v 'kernel/nvidia.ko' \
        "$out/lib/modules/$kernelVersion/misc/nvidia.ko"
    '' + /* NVIDIA direct rendering manager kernel modesetting (DRM KMS) kernel module */
      optionalString (versionAtLeast source.versionMajor "364") ''
        nuke-refs 'kernel/nvidia-drm.ko'
        install -D -m644 -v 'kernel/nvidia-drm.ko' \
          "$out/lib/modules/$kernelVersion/misc/nvidia-drm.ko"
    '' + /* NVIDIA modesetting kernel module */
      optionalString (versionAtLeast source.versionMajor "358") ''
        nuke-refs 'kernel/nvidia-modeset.ko'
        install -D -m644 -v 'kernel/nvidia-modeset.ko' \
          "$out/lib/modules/$kernelVersion/misc/nvidia-modeset.ko"
    '' + /* NVIDIA cuda unified virtual memory kernel module */
      optionalString (targetSystem == "x86_64-linux") (
      # The uvm kernel module build directory changed in 355+
      if versionAtLeast source.versionMajor "355" then ''
        nuke-refs 'kernel/nvidia-uvm.ko'
        install -D -m644 -v 'kernel/nvidia-uvm.ko' \
          "$out/lib/modules/$kernelVersion/misc/nvidia-uvm.ko"
      '' else ''
        nuke-refs 'kernel/uvm/nvidia-uvm.ko'
        install -D -m644 -v 'kernel/uvm/nvidia-uvm.ko' \
          "$out/lib/modules/$kernelVersion/misc/nvidia-uvm.ko"
      ''
    )
  ) + optionalString buildUserspace (
    #
    ## Libraries
    #
    /* OpenGL GLX API entry point */ (
      # Triton only supports the NVIDIA vendor libGL implementation
      # for versions that do not support GLVND (<361).
      if versionOlder source.versionMajor "361" then /* NVIDIA */ ''
        nvidia_lib_install 0 360 'libGL' '1'
      '' else /* GLVND */ ''
        nvidia_lib_install 361 0 'libGL' '1' '1.0.0'
      ''
    ) + /* OpenGL ES API entry point */ ''
      nvidia_lib_install 0 360 'libGLESv1_CM' '1' # Renamed to *.so.1 in 361+
      nvidia_lib_install 361 0 'libGLESv1_CM' '-' '1'
      nvidia_lib_install 0 360 'libGLESv2' '2' # Renamed to *.so.2 in 361+
      nvidia_lib_install 361 0 'libGLESv2' '-' '2'
    '' + /* EGL API entry point */ ''
      nvidia_lib_install 0 354 'libEGL' # Renamed to *.so.1 in 355+
      nvidia_lib_install 355 0 'libEGL' '-' '1'
    '' + /* Vendor neutral graphics libraries */ ''
      nvidia_lib_install 355 0 'libOpenGL' '-' '0'
      nvidia_lib_install 361 0 'libGLX' '-' '0'
      nvidia_lib_install 355 0 'libGLdispatch' '-' '0'
    '' + /* Vendor implementation graphics libraries */ ''
      nvidia_lib_install 361 0 'libGLX_nvidia' '0'
      nvidia_lib_install 361 0 'libEGL_nvidia' '0'
      nvidia_lib_install 361 0 'libGLESv1_CM_nvidia' '1'
      nvidia_lib_install 361 0 'libGLESv2_nvidia' '2'
      nvidia_lib_install 0 0 'libvdpau_nvidia'
    '' + /* GLX indirect support */ ''
      # CVE-2014-8298: http://goo.gl/QTEVwu
      #ln -fsv \
      #  "$out/lib/libGLX_nvidia.${version}" \
      #  "$out/lib/libGLX_indirect.so.0"
    '' + /* Internal driver components */ ''
      nvidia_lib_install 364 0 'libnvidia-egl-wayland'
      nvidia_lib_install 0 0 'libnvidia-eglcore'
      nvidia_lib_install 0 0 'libnvidia-glcore'
      nvidia_lib_install 0 0 'libnvidia-glsi'
    '' + /* NVIDIA OpenGL-based inband frame readback */ ''
      nvidia_lib_install 0 0 'libnvidia-ifr'
    '' + /* Thread local storage libraries for NVIDIA OpenGL libraries */ ''
      nvidia_lib_install 0 0 'libnvidia-tls'
      nvidia_lib_install 0 0 'tls/libnvidia-tls' '-' "${version}" 'tls'
      ###nvidia_lib_install 0 0 'tls_test_dso' '-' '-'
    '' + /* X.Org DDX driver */ optionalString (!libsOnly) ''
      nvidia_lib_install 0 0 'nvidia_drv' '-' '-' 'xorg/modules/drivers'
    '' + /* X.Org GLX extension module */ optionalString (!libsOnly) ''
      nvidia_lib_install 0 0 'libglx' '-' "${version}" 'xorg/modules/extensions'
    '' + /* Managment & Monitoring library */ ''
      nvidia_lib_install 0 0 'libnvidia-ml' '1'
    '' + /* CUDA libraries */ ''
      nvidia_lib_install 0 0 'libcuda' '1'
      nvidia_lib_install 0 0 'libnvidia-compiler'
      # CUDA video decoder library
      nvidia_lib_install 0 0 'libnvcuvid' '1'
      # Fat (multiarchitecture) binary loader
      nvidia_lib_install 361 0 'libnvidia-fatbinaryloader'
      # Parallel Thread Execution JIT Compiler for CUDA
      nvidia_lib_install 361 0 'libnvidia-ptxjitcompiler'
    '' + /* OpenCL libraries */ ''
      # Vendor independent ICD loader
      nvidia_lib_install 0 0 'libOpenCL' '1' '1.0.0'
      # NVIDIA ICD
      nvidia_lib_install 0 0 'libnvidia-opencl'
    '' + /* Linux kernel userspace driver config library */ ''
      nvidia_lib_install 0 0 'libnvidia-cfg'
    '' + /* Wrapped software rendering library */ optionalString (!libsOnly) ''
      nvidia_lib_install 0 0 'libnvidia-wfb' '-' "${version}" 'xorg/modules'
      # TODO: figure out symlink libwfb -> libnvidia-wfb
    '' + /* Framebuffer capture library */ ''
      nvidia_lib_install 0 0 'libnvidia-fbc'
    '' + /* NVENC video encoding library */ ''
      nvidia_lib_install 0 0 'libnvidia-encode' '1'
    '' + /* NVIDIA Settings GTK+ 2/3 libraries */ ''
      ###nvidia_lib_install 0 0 'libnvidia-gtk2'
      ###nvidia_lib_install 0 0 'libnvidia-gtk3'
    '' +
    #
    ## Headers
    #
    /* OpenGL headers */ optionalString (!libsOnly) ''
      ## OpenGL headers
      nvidia_header_install 0 0 'gl' 'GL'
      nvidia_header_install 0 0 'glext' 'GL'
      nvidia_header_install 0 0 'glx' 'GL'
      nvidia_header_install 0 0 'glxext' 'GL'
    '' +
    #
    ## Executables
    #
    optionalString (!libsOnly) ''
      ###nvidia_bin_install 0 0 'mkprecompiled'
      ###nvidia_bin_install 0 0 'nvidia-bug-report.sh'
      nvidia_bin_install 0 0 'nvidia-cuda-mps-control'
      nvidia_bin_install 0 0 'nvidia-cuda-mps-server'
      nvidia_bin_install 0 0 'nvidia-debugdump'
      ###nvidia_bin_install 0 0 'nvidia-installer'
      ###nvidia_bin_install 0 0 'nvidia-modprobe'
      nvidia_bin_install 0 0 'nvidia-persistenced'
      ###nvidia_bin_install 0 0 'nvidia-settings'
      # System Management Interface
      nvidia_bin_install 0 0 'nvidia-smi'
      ###nvidia_bin_install 0 0 'nvidia-xconfig'
      ###nvidia_bin_install 0 0 'tls_test' (also tls_test.so)
    '' +
    #
    ## Manpages
    #
    optionalString (!libsOnly) ''
      nvidia_man_install 0 0 'nvidia-cuda-mps-control'
      ###nvidia_man_install 361 0 'nvidia-gridd'
      ###nvidia_man_install 0 0 'nvidia-installer'
      ###nvidia_man_install 0 0 'nvidia-modprobe'
      nvidia_man_install 0 0 'nvidia-persistenced'
      ###nvidia_man_install 0 0 'nvidia-settings'
      nvidia_man_install 0 0 'nvidia-smi'
      ###nvidia_man_install 0 0 'nvidia-xconfig'
    '' +
    #
    ## Configs
    #
    optionalString (!libsOnly) ''
      # NVIDIA application profiles
      install -D -m644 -v "nvidia-application-profiles-${version}-key-documentation" \
        "$out/etc/nvidia-application-profiles-${version}-key-documentation"
      ln -sv \
        "$out/etc/nvidia-application-profiles-${version}-key-documentation" \
        "$out/etc/nvidia-application-profiles-key-documentation"
      install -D -m644 -v "nvidia-application-profiles-${version}-rc" \
        "$out/share/doc/nvidia-application-profiles-${version}-rc"
      mkdir -pv "$out/etc/nvidia"
      ln -fsv \
        "$out/share/doc/nvidia-application-profiles-${version}-rc" \
        "$out/etc/nvidia/nvidia-application-profiles-rc.d"

      # OpenCL ICD config
      install -D -m644 -v 'nvidia.icd' "$out/etc/OpenCL/vendors/nvidia.icd"

      # X.Org driver configuration file
      install -D -m644 -v 'nvidia-drm-outputclass.conf' \
        "$out/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf"
    '' +
    #
    ## Desktop Entries
    #
    /* NVIDIA Settings .desktop entry */ ''
      # Provided by the nvidia-settings package
      ###install -D -m 644 -v 'nvidia-settings.desktop' \
      ###  "$out/share/applications/nvidia-settings.desktop"
      ###sed -i "$out/share/applications/nvidia-settings.desktop" \
    '' +
    #
    ## Icons
    #
    /* NVIDIA Settings icon */ ''
      # Provided by the nvidia-settings package
      ###install -D -m 644 -v 'nvidia-settings.png' \
      ###  "$out/share/pixmaps/nvidia-settings.png"
    ''
  );

  preFixup = /* Patch RPATH's in libraries and executables */ ''
    local executable
    local patchLib

    find "$out/lib" -name '*.so*' -type f |
    while read -r patchLib ; do
      if [ -f "$patchLib" ] ; then
        echo "patchelf: $patchLib : rpath -> $out/lib:$allLibPath"
        patchelf \
          --set-rpath "$out/lib:$allLibPath" \
          "$patchLib"
      fi
    done

    for executable in $out/bin/* ; do
      if [ -f "$executable" ] ; then
        echo "patchelf: $executable : rpath -> $out/lib:$allLibPath"
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$out/lib:$allLibPath" \
          "$executable"
      fi
    done
  '' /*+ ''
    ln -fns ${libglvnd}/include/glvnd $out/include
    find "${libglvnd}/lib" -maxdepth 1 -iwholename '*.so*' |
    while read -r glvndLib ; do
      ln -fns $glvndLib $out/lib
    done
    ln -fns \
      ${libglvnd}/lib/xorg/modules/extensions/x11glvnd.so \
      $out/lib/xorg/modules/extensions
  ''*/;

  postFixup = /* Run some tests */ ''
    # Fail if libraries contain broken RPATH's
    local TestLib
    find "$out/lib" -name '*.so*' -type f |
    while read -r TestLib ; do
      echo "Testing rpath for: $TestLib"
      if [ -n "$(ldd "$TestLib" 2> /dev/null |
                 grep --only-matching 'not found')" ] ; then
        echo "ERROR: failed to patch RPATH's for:"
        echo "$TestLib"
        ldd $TestLib
        return 1
      fi
      echo "PASSED"
    done

    # Fail if executables contain broken RPATH's
    local executable
    for executable in $out/bin/* ; do
      echo "Testing rpath for: $executable"
      if [ -n "$(ldd "$executable" 2> /dev/null |
                 grep --only-matching 'not found')" ] ; then
        echo "ERROR: failed to patch RPATH's for:"
        echo "$executable"
        ldd $out/bin/$executable
        return 1
      fi
      echo "PASSED"
    done
  '';

  fpic = false;
  optFlags = false;
  stackProtector = false;

  passthru = {
    inherit
      version;
    inherit (source)
      versionMajor;
    inherit (mesa_noglu)
      driverSearchPath;
    drm = buildKernelspace;
    kms = buildKernelspace;
    nvenc = buildUserspace;
    uvm = buildKernelspace;

    srcVerification = fetchurl {
      urls = [
        ("http://us.download.nvidia.com/XFree86/Linux-x86/${version}/"
            + "NVIDIA-Linux-x86-${version}.run")
        ("http://us.download.nvidia.com/XFree86/Linux-x86_64/${version}/"
            + "NVIDIA-Linux-x86_64-${version}"
            + "${if channel == "tesla" then "" else "-no-compat32"}.run")
      ];
      # Arbitrary hash to trigger fetchurl to return the correct hash since
      # we cannot enable recursion to use src.sha256 in the nvidia-drivers
      # build.
      sha256 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
      insecureHashOutput = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Drivers and Linux kernel modules for NVIDIA graphics cards";
    homepage = http://www.nvidia.com/object/unix.html;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
    # Resolves collision w/ xorg-server "lib/xorg/modules/extensions/libglx.so"
    priority = 4;
  };
}
