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

, nvidiasettingsSupport ? true
  , atk
  , gdk-pixbuf-core
  , glib
  , pango
  , gtk2 # <346
  , gtk3 # >346
  , cairo
}:

/* NOTICE: ONLY versions 304+ are supported on Triton
 *
 * BETA:        361.xx,   xorg <=1.18.x, linux <=4.4
 * SHORTLIVED:  358.xx,   xorg <=1.18.x, linux <=4.4
 * LONGLIVED:   352.xx,   xorg <=1.18.x, linux <=4.4 (stable) <- default
 * LEGACY:      340.xx,   xorg <=1.18.x, linux <=4.4
 * LEGACY:      304.xx,   xorg <=1.18.x, linux <=4.4
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
    makeLibraryPath
    optionals
    optionalString
    platforms
    versionAtLeast
    versionOlder;
  inherit (builtins.getAttr channel (import ./sources.nix))
    versionMajor
    versionMinor
    sha256i686
    sha256x86_64;
in

let
  version = "${versionMajor}.${versionMinor}";
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
  "long-lived"
  "short-lived"
  "beta"
];
assert buildKernelspace -> kernel != null;
assert nvidiasettingsSupport -> (
  atk != null
  && gdk-pixbuf-core != null
  && glib != null
  && pango != null
  && (
    if versionAtLeast versionMajor "346" then
      cairo != null
      && gtk3 != null
    else
      gtk2 != null
  )
);
assert libsOnly -> !buildKernelspace;

assert elem targetSystem platforms.bit32 && !libsOnly ->
  throw "Only libs are supported for 32bit platforms";

stdenv.mkDerivation {
  name = "nvidia-drivers-${buildConfig}-${version}"
       + "${optionalString buildKernelspace "-${kernel.version}"}";

  src = fetchurl {
    url =
      if targetSystem == "i686-linux" then
        "http://download.nvidia.com/XFree86/Linux-x86/${version}/"
          + "NVIDIA-Linux-x86-${version}.run"
      else if targetSystem == "x86_64-linux" then
        "http://download.nvidia.com/XFree86/Linux-x86_64/${version}/"
          + "NVIDIA-Linux-x86_64-${version}-no-compat32.run"
      else
        throw "The NVIDIA drivers are not supported for the `${targetSystem}` platform";
    sha256 =
      if targetSystem == "i686-linux" then
        sha256i686
      else if targetSystem == "x86_64-linux" then
        sha256x86_64
      else
        throw "The NVIDIA drivers are not supported for the `${targetSystem}` platform";
  };

  nativeBuildInputs = [
    makeWrapper
    nukeReferences
  ];

  patches =
    optionals (versionAtLeast kernel.version "4.6" && channel == "beta") [
      (fetchTritonPatch {
        rev = "162b8425413b69580d8b145aab7ddbf41d7282a4";
        file = "nvidia-drivers/364.15-kernel-4.6.patch";
        sha256 = "bfe68310290cb000343163c68d1b6f765d08c4355f82bc959970d82782230257";
      })
    ];

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
    nvidiasettingsSupport
    targetSystem
    version
    versionMajor;

  builder = ./builder-generic.sh;

  libXvPath = optionalString (!libsOnly && nvidiasettingsSupport) (
    makeLibraryPath [
      xorg.libXv
    ]
  );
  allLibPath = makeLibraryPath ([
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
  ] ++ optionals (versionOlder versionMajor "305") [
    xorg.libXvMC
  ]);
  gtkPath = optionalString (!libsOnly && nvidiasettingsSupport) (
    makeLibraryPath (
      [
        atk
        gdk-pixbuf-core
        glib
        pango
      ] ++ (
        if versionAtLeast versionMajor "346" then [
          cairo
          gtk3
        ] else [
          gtk2
        ]
      )
    )
  );

  /*preFixup = ''
    ln -fns ${libglvnd}/include/glvnd $out/include
    find "${libglvnd}/lib" -maxdepth 1 -iwholename '*.so*' | while read -r glvndLib ; do
      ln -fns $glvndLib $out/lib
    done
    ln -fns \
      ${libglvnd}/lib/xorg/modules/extensions/x11glvnd.so \
      $out/lib/xorg/modules/extensions
  '';*/

  dontStrip = true;
  optFlags = false;
  fpic = false;

  passthru = {
    inherit
      version
      versionMajor;
    inherit (mesa_noglu)
      driverSearchPath;
    nvenc =
      if versionAtLeast versionMajor "340" then
        true
      else
        false;
    cudaUVM =
      # 340.xx supported UVM for both i686 & x86_64
      if versionAtLeast versionMajor "340"
         && versionOlder versionMajor "346"
         && ((elem targetSystem platforms.i686-linux)
              || (elem targetSystem platforms.x86_64-linux)) then
        true
      # 346.xx+ only supports UVM for x86_64
      else if versionAtLeast versionMajor "346"
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
      i686-linux
      ++ x86_64-linux;
    # Resolves collision w/ xorg-server "lib/xorg/modules/extensions/libglx.so"
    priority = 4;
  };
}
