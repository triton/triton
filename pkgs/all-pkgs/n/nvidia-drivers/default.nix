{ stdenv
, elfutils  # FIXME: are any utilities actually used?
, fetchTritonPatch
, fetchurl
, lib
, makeWrapper
, nukeReferences

, buildConfig ? "all"
, channel

# Kernelspace dependencies
, kernel ? null

# Userspace dependencies
, libx11
#, libxau
#, libxcb
#, libxdmcp
, libxext
#, libxrandr
, wayland
#, xorg
, zlib

# Just needed for the passthru driver path
, opengl-dummy

, libsOnly ? false
}:

/* NOTICE: ONLY versions 375+ are supported on Triton
 *
 * If your gpu requires a version that is unsupported it is
 * recommended to use the nouveau driver.
 * http://nvidia.custhelp.com/app/answers/detail/a_id/3142
 * http://www.nvidia.com/object/IO_32667.html
 *
 * Information on the GLVND transition: https://goo.gl/4mraRX
 */

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    any
    elem
    makeSearchPath
    optionals
    optionalString
    platforms
    versionAtLeast
    versionOlder;

  # http://www.nvidia.com/object/unix.html
  # http://www.nvidia.com/object/quadro-branch-history-table.html
  sources = rec {
    tesla = {
      versionMajor = "375";
      versionMinor = "20";
      sha256x86_64 = "d10e40a19dc57ac958567a2b247c2b113e5f1e4186ad48e9a58e70a46d07620b";
      maxLinuxVersion = "4.10";
      maxXorgVersion = "1.19";
    };
    long-lived = {
      versionMajor = "390";
      versionMinor = "67";
      sha256i686   = "6df2ca1a7420b6751bcaf257d321b14f4e5f7ca54d77a43514912a3792ece65a";
      sha256x86_64 = "4d9d4a636d568a93412cd9a2db08c594adef20861707dfdfbd6ae15db3292b26";
      maxLinuxVersion = "4.17";
      maxXorgVersion = "1.19";
    };
    short-lived = {
      versionMajor = "396";
      versionMinor = "24";
      sha256i686   = "2c01f57abd78e9c52d3e76e3cdf688835be54f419a1093bbaa7ab21f375d4399";
      sha256x86_64 = "41b80d2a4519ac78ac17c02fec976256d2ba5c9618640d2a9be9cb70685b2a9c";
      maxLinuxVersion = "4.17";
      maxXorgVersion = "1.20";
    };
    beta = {
      versionMajor = "396";
      versionMinor = "18";
      sha256i686   = "63223406a552fd50808dca0b6864dccbc265dfc614dde89492f1e53afa7cce0b";
      sha256x86_64 = "0d39bd3e1727e5849401db7fa04d667662b6b9a80b2a11a897bb4ba0e7273208";
      maxLinuxVersion = "4.17";
      maxXorgVersion = "1.20";
    };
    # Update to which ever channel has the latest release at the time.
    latest = long-lived;
  };
  source = sources."${channel}";

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

assert buildKernelspace && !(kernel.isCompatibleVersion source.maxLinuxVersion "0") ->
  throw ("The '${channel}' NVIDIA driver channel is only supported on Linux"
    + " kernel channels less than or equal to ${source.maxLinuxVersion}");

# FIXME: enable after xorg-server rewrite
# assert buildKernelspace && ! versionAtLeast source.maxXorgVersion xorg-server.channel ->
#   throw ("The '${channel}' NVIDIA driver channel is only supported on Xorg"
#     + " server channels less than or equal to ${source.maxXorgVersion}");

assert elem targetSystem platforms.bit32 && !libsOnly ->
  throw "Only libs are supported for 32bit platforms";

stdenv.mkDerivation {
  name = "nvidia-drivers-${buildConfig}-${version}"
    + "${optionalString buildKernelspace "-${kernel.version}"}";

  src = fetchurl {
    url =
      if elem targetSystem platforms.i686-linux then
        "mirror://nvidia/XFree86/Linux-x86_64/${version}/"
          + "NVIDIA-Linux-x86_64-${version}.run"
      else if elem targetSystem platforms.x86_64-linux then
        "mirror://nvidia/XFree86/Linux-x86_64/${version}/"
          + "NVIDIA-Linux-x86_64-${version}"
          + "${if channel == "tesla" then "" else "-no-compat32"}.run"
      else
        throw "The NVIDIA drivers are not supported for the "
          + "`${targetSystem}` platform";
    sha256 =
      if elem targetSystem platforms.i686-linux then
        source.sha256i686
      else if elem targetSystem platforms.x86_64-linux then
        source.sha256x86_64
      else
        throw "The NVIDIA drivers are not supported for the "
          + "`${targetSystem}` platform";
  };

  nativeBuildInputs = [
    elfutils
    makeWrapper
    nukeReferences
  ];

  unpackPhase =
    /* This function prints the first 20 lines of the file, then awk's for
       the line with `skip=` which contains the line number where the tarball
       begins, then tails to that line and pipes the tarball to the required
       decompression utility (gzip/xz), which interprets the tarball, and
       finally pipes the output to tar to extract the contents. This is
       exactly what the cli commands in the `.run` file do, but there are
       issues with some versions so it is best to do it manually instead. */ ''
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

      srcRoot="$(pwd)"
      export srcRoot

      runHook 'postUnpack'
    '';

  patches = optionals (
    (versionAtLeast version "378.13" && versionOlder version "381.00")
    && (buildKernelspace && versionAtLeast kernel.version "4.10")) [
    (fetchTritonPatch {
      rev = "9fe9a276f8576135ed00f09f6dbf2776a55c33f4";
      file = "n/nvidia-drivers/nvidia-drivers-378.13-linux-4.10-rc8.patch";
      sha256 = "fab525ba498ee5706cd85b7fe625b572c1a2ff7fee952a63d0e0bddf347579af";
    })
  ] ++ optionals (
    (versionAtLeast version "381.00" && versionOlder version "381.22")
    && (versionAtLeast kernel.version "4.11")) [
    (fetchTritonPatch {
      rev = "073bc882b4e3e5a1f82d4f1ed5e21cd5ae7446f6";
      file = "n/nvidia-drivers/nvidia-drivers-381.09-linux-4.11-rc5.patch";
      sha256 = "969a0c633d04bdad53707fe6818ba09d33cced049304ea94eb14986622c6253e";
    })
  ];

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
    libx11
    #libxau  # nvidia-settings
    #libxcb  # nvidia-settings
    #libxdmcp  # nvidia-settings
    libxext
    #libxrandr  # nvidia-settings
    #xorg.libXv  # nvidia-settings
    wayland
    zlib
  ];

  buildPhase = optionalString buildKernelspace (''
    local kernelBuild
    local kernelSource

    # Create the kernel module
    echo "Building the NVIDIA Linux kernel modules against: $kernel"

    cd "$srcRoot/kernel"

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

    cd "$srcRoot"
  '');

  installPhase = optionalString buildKernelspace (
    #
    ## Kernel modules
    #
    /* NVIDIA kernel module */ ''
      nuke-refs 'kernel/nvidia.ko'
      install -D -m644 -v 'kernel/nvidia.ko' \
        "$out/lib/modules/$kernelVersion/misc/nvidia.ko"
    '' + /* NVIDIA direct rendering manager kernel modesetting (DRM KMS) kernel module */ ''
        nuke-refs 'kernel/nvidia-drm.ko'
        install -D -m644 -v 'kernel/nvidia-drm.ko' \
          "$out/lib/modules/$kernelVersion/misc/nvidia-drm.ko"
    '' + /* NVIDIA modesetting kernel module */ ''
        nuke-refs 'kernel/nvidia-modeset.ko'
        install -D -m644 -v 'kernel/nvidia-modeset.ko' \
          "$out/lib/modules/$kernelVersion/misc/nvidia-modeset.ko"
    '' + /* NVIDIA cuda unified virtual memory kernel module */
      optionalString (targetSystem == "x86_64-linux") (''
      nuke-refs 'kernel/nvidia-uvm.ko'
      install -D -m644 -v 'kernel/nvidia-uvm.ko' \
        "$out/lib/modules/$kernelVersion/misc/nvidia-uvm.ko"
    '')
  ) + optionalString buildUserspace (
    #
    ## Libraries
    #
    /* OpenGL GLX API entry point */ (
      # Triton only supports the NVIDIA vendor libGL implementation
      # for versions that do not support GLVND (<361).
      /* NVIDIA */ ''
        ###nvidia_lib_install 0 360 'libGL' '1'
      '' + /* GLVND */ ''
        nvidia_lib_install 361 389 'libGL' '1' '1.0.0'
        nvidia_lib_install 390 0 'libGL' '1' '1.7.0'
      ''
    ) + /* OpenGL ES API entry point */ ''
      nvidia_lib_install 361 389 'libGLESv1_CM' '-' '1'
      nvidia_lib_install 390 0 'libGLESv1_CM' '-' '1.2.0'
      nvidia_lib_install 361 389 'libGLESv2' '-' '2'
      nvidia_lib_install 390 0 'libGLESv2' '-' '2.1.0'
    '' + /* EGL API entry point */ ''
      nvidia_lib_install 355 389 'libEGL' '-' '1'
      nvidia_lib_install 390 0 'libEGL' '-' '1.1.0'
      nvidia_lib_install 378 0 'libEGL_nvidia' '0'
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
      nvidia_lib_install 364 377 'libnvidia-egl-wayland'  # Renamed in 378.09
    '' + (
      if (versionAtLeast version "378.13") then ''
        nvidia_lib_install 378 384 'libnvidia-egl-wayland' '1' '1.0.1'
      '' else ''
        nvidia_lib_install 378 378 'libnvidia-egl-wayland' '1' '1.0.0'
      ''
    )+ ''
      nvidia_lib_install 387 0 'libnvidia-egl-wayland' '1' '1.0.2'
      nvidia_lib_install 0 0 'libnvidia-eglcore'
      nvidia_lib_install 0 0 'libnvidia-glcore'
      nvidia_lib_install 0 0 'libnvidia-glsi'
    '' + /* NVIDIA OpenGL-based inband frame readback */ ''
      nvidia_lib_install 0 0 'libnvidia-ifr'
    '' + /* Thread local storage libraries for NVIDIA OpenGL libraries */ ''
      nvidia_lib_install 0 0 'libnvidia-tls'
      nvidia_lib_install 0 0 'tls/libnvidia-tls' '-' "${version}" 'tls'
      ###nvidia_lib_install 0 0 'tls_test_dso' '-' '-'  # Not used
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
    '' + /* Linux kernel, userspace driver config library */ ''
      nvidia_lib_install 0 0 'libnvidia-cfg'
    '' + /* Wrapped software rendering library */ optionalString (!libsOnly) ''
      nvidia_lib_install 0 0 'libnvidia-wfb' '-' "${version}" 'xorg/modules'
      # TODO: figure out symlink libwfb -> libnvidia-wfb
    '' + /* Framebuffer capture library */ ''
      nvidia_lib_install 0 0 'libnvidia-fbc'
    '' + /* NVENC video encoding library */ ''
      nvidia_lib_install 0 0 'libnvidia-encode' '1'
    '' + /* NVIDIA Settings GTK+ 2/3 libraries */ ''
      # Provided by nvidia-settings
      ###nvidia_lib_install 0 0 'libnvidia-gtk2'
      ###nvidia_lib_install 0 0 'libnvidia-gtk3'
    '' +
    #
    ## Headers
    #
    /* OpenGL headers */ optionalString (!libsOnly) ''
      nvidia_header_install 0 0 'gl' 'GL'
      nvidia_header_install 0 0 'glext' 'GL'
      nvidia_header_install 0 0 'glx' 'GL'
      nvidia_header_install 0 0 'glxext' 'GL'
    '' +
    #
    ## Executables
    #
    optionalString (!libsOnly) ''
      ###nvidia_bin_install 0 0 'mkprecompiled'  # Not used
      ###nvidia_bin_install 0 0 'nvidia-bug-report.sh'  # Would probably require patching
      nvidia_bin_install 0 0 'nvidia-cuda-mps-control'
      nvidia_bin_install 0 0 'nvidia-cuda-mps-server'
      nvidia_bin_install 0 0 'nvidia-debugdump'
      ###nvidia_bin_install 0 0 'nvidia-installer'  # Not used
      ###nvidia_bin_install 0 0 'nvidia-modprobe'  Not used
      nvidia_bin_install 0 0 'nvidia-persistenced'
      ###nvidia_bin_install 0 0 'nvidia-settings'
      # System Management Interface
      nvidia_bin_install 0 0 'nvidia-smi'
      ###nvidia_bin_install 0 0 'nvidia-xconfig'  # Not used, might still be useful?
      ###nvidia_bin_install 0 0 'tls_test'  # (also tls_test.so)  # Not used
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
        "$out/share/nvidia/nvidia-application-profiles-${version}-key-documentation"
      ln -sv \
        "$out/share/nvidia/nvidia-application-profiles-${version}-key-documentation" \
        "$out/share/nvidia/nvidia-application-profiles-key-documentation"
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

      if [ $channel -ge 378 ] ; then
        # EGL external platform configuration files
        install -D -m644 -v '10_nvidia.json' \
          "$out/share/egl/egl_external_platform.d/10_nvidia.json"
        install -D -m644 -v '10_nvidia_wayland.json' \
          "$out/share/egl/egl_external_platform.d/10_nvidia_wayland.json"
      fi
    ''
    # Provided by nvidia-settings
    ### +
    ### #
    ### ## Desktop Entries
    ### #
    ### /* NVIDIA Settings .desktop entry */ ''
    ###   install -D -m 644 -v 'nvidia-settings.desktop' \
    ###     "$out/share/applications/nvidia-settings.desktop"
    ###   sed -i "$out/share/applications/nvidia-settings.desktop" \
    ### '' +
    ### #
    ### ## Icons
    ### #
    ### /* NVIDIA Settings icon */ ''
    ###   # Provided by the nvidia-settings package
    ###   install -D -m 644 -v 'nvidia-settings.png' \
    ###     "$out/share/pixmaps/nvidia-settings.png"
    ### ''
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

  sourceDateEpochWarn = true;
  fpic = false;
  optFlags = false;
  stackProtector = false;

  passthru = {
    inherit
      version;
    inherit (source)
      versionMajor;
    inherit (opengl-dummy)
      driverSearchPath;
    drm = buildKernelspace;
    kms = buildKernelspace;
    nvenc = buildUserspace;
    uvm = buildKernelspace;

    srcVerification = fetchurl {
      urls = [
        ("https://download.nvidia.com/XFree86/Linux-x86_64/${version}/"
            + "NVIDIA-Linux-x86_64-${version}.run")
        ("https://download.nvidia.com/XFree86/Linux-x86_64/${version}/"
            + "NVIDIA-Linux-x86_64-${version}"
            + "${if channel == "tesla" then "" else "-no-compat32"}.run")
      ];
      # Arbitrary hash to trigger fetchurl to return the correct hash since
      # we cannot enable recursion to use src.sha256 in the nvidia-drivers
      # build.
      sha256 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    };
  };

  meta = with lib; {
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
