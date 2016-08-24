{ stdenv
, fetchTritonPatch
, fetchurl
, makeWrapper
, nukeReferences

, buildConfig ? "all"
, channel ? null

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

/* NOTICE: ONLY versions 304+ are supported on Triton
 *
 * BETA:        367.xx,   xorg <=1.18.x, linux <=4.7
 * SHORTLIVED:  364.xx,   xorg <=1.18.x, linux <=4.5
 * LONGLIVED:   367.xx,   xorg <=1.18.x, linux <=4.7 (stable) <- default
 * TESLA:       352.xx,   xorg <=1.18.x, linux <=4.5
 * LEGACY:      340.xx,   xorg <=1.18.x, linux <=4.5
 * LEGACY:      304.xx,   xorg <=1.18.x, linux <=4.5
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
in

let
  version = "${source.versionMajor}.${source.versionMinor}";
  buildKernelspace = any (n: n == buildConfig) [ "kernelspace" "all" ];
  buildUserspace = any (n: n == buildConfig) [ "userspace" "all" ];
in

assert any (n: n == buildConfig) [
  "kernelspace"
  "userspace"
  "all"
];
assert any (n: n == channel) [
  "legacy304"
  "legacy340"
  "tesla"
  "long-lived"
  "short-lived"
  "beta"
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
    optionals (versionAtLeast kernel.version "4.6" && channel == "short-lived") [
      (fetchTritonPatch {
        rev = "0a60fa7b87fd06185cc0369edd5212344c4da97d";
        file = "nvidia-drivers/364.19-kernel-4.6.patch";
        sha256 = "a40489322dcab39acbef8f30d9e0adb742b123f9da771e9a5fff1f493bd19335";
      })
    ] ++ optionals (versionAtLeast source.versionMajor "367") [
      (fetchTritonPatch {
        rev = "daeb3f279f0c923644b352ac318e7f13c8692f0c";
        file = "nvidia-drivers/nvidia-drivers-367.35-fix-application-profiles-typo.patch";
        sha256 = "caae27b1883c5c6b3c4684720d2902421ad16ab49577ee7302a95c964236141d";
      })
    ];

  postPatch =
    # 364+ & Linux 4.7
    optionalString (
      versionAtLeast kernel.version "4.7"
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
  inherit
    buildKernelspace
    buildUserspace
    libsOnly
    targetSystem
    version;
  inherit (source)
    versionMajor;

  builder = ./builder-generic.sh;

  allLibPath = makeSearchPath "lib" ([
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
  ] ++ optionals (versionOlder source.versionMajor "305") [
    xorg.libXvMC
  ]);

  /*preFixup = ''
    ln -fns ${libglvnd}/include/glvnd $out/include
    find "${libglvnd}/lib" -maxdepth 1 -iwholename '*.so*' | while read -r glvndLib ; do
      ln -fns $glvndLib $out/lib
    done
    ln -fns \
      ${libglvnd}/lib/xorg/modules/extensions/x11glvnd.so \
      $out/lib/xorg/modules/extensions
  '';*/

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
    drm =
      if versionAtLeast version "346.16" then
        true
      else
        false;
    kms =
      if versionAtLeast version "346.16" then
        true
      else
        false;
    nvenc =
      if versionAtLeast source.versionMajor "340" then
        true
      else
        false;
    uvm =
      # 340.xx supported UVM for both i686 & x86_64
      if versionAtLeast source.versionMajor "340"
         && versionOlder source.versionMajor "346"
         && ((elem targetSystem platforms.i686-linux)
              || (elem targetSystem platforms.x86_64-linux)) then
        true
      # 346.xx+ only supports UVM for x86_64
      else if versionAtLeast source.versionMajor "346"
              && (elem targetSystem platforms.x86_64) then
        true
      else
        false;
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
