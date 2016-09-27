List of undocumented changes
============================

This is probably missing a lot


* absolute-pkgconfig hook

  + pkg-conf is now part of stdenv
  + patches pkgs-config files to use explicit paths file/lib references,
    which elimates the needs for propagating pkg-config dependencies.
    (propagatation very bad and impure)

* absolute-libtool hook

  + same as absolute-pkgconfig, this hook uses explicit paths in libtool files

* parallel building enabled by default, and enableParallelBuilding is replaced
  by.

   + parallelBuild
   + parallelInstall
   + parallelCheck

* Remove stdenv.system and other broken platform specific functions.  These
  functions only respected the host system, and were not cross compilation
  aware.  stdenv.system is now stdenv.hostSystem & stdenv,targetSystem.

  + Usage

    - lib.elem stdenv.targetSystem lib.platforms.<required platform>

  + Deprecated

    - isLinux
    - isFreeBSD
    - is64bit
    - isi686
    - etc...

* Refactored lib.platforms to be more robust and feature complete.
* Specific platfrom tuples are now used in meta.platforms for most packages
  and they are no referenced by attr instead of strings (for tuples).
* Removed insecure webkit/blink version (webkitgtk-2.4, qt4, qt5(disabled by
  default))
* Added cmake's ninja generator support in cmake hooks

  + Used if ninja is a buildInput.

* Mesa

  + use platform tuple for driver directory instead of platform word size
  + mesa.driverLink -> mesa.driverSearchPath
  + mesaSupported -> mesa_noglu.meta.platforms

* Python

  + all modules are built by default (minus tcl/tk)
  + fix pythonPackage's callPackage scope

* Move vendored patches in the triton repo to triton-patches
* Migrate packages away from a category based heirarchy to subdividing
  based of the first few characters.
* gtk3 and qt5 are now the default where supported.
* gtk2 & qt4 are deprecated

  + non-essential packages and packages supporting newer toolkits are
    not allowed to use gtk2.  Both projects are un-maintained by their
    respective upstreams.

* Remove unnecessary nested attrs

  + gnome3
  + qt5

* Remove Xorg aliases, xorg packages are accessible via xorg.<pkg>
* Fetchurl (and company)

  + added support for ipfs multihashs
  + added support for sha512
  + removed support for md5 & sha1
  + add support for hashs & hash files provided by upstream sources, used
    for verifing hashes.

    - md5Confirm/md5Url (only for verification)
    - sha1Confirm/sha1Url (only for verification)
    - sha256Confirm/sha256Url
    - sha512Confirm/sha512Url

  + Added support for signatures used to sign sources and hash files.
  + failEarly

* Compiler hardening & optimization by default

  + Flags

    - optFlags
    - pie
    - fpic
    - noStrictOverflow
    - fortifySource
    - stackProtector
    - optimize

* Raised minimum supported platforms for all architectures

  + x86 = Westmere
  + Arm = v7 w/ floating point
  + Power = 8

* Compiler toolchain

  + rewrite in progress
  + gcc6 by default, previously gcc5 by default

* Consistent coding style

  + needs documentation, but it's there

* Disable recursion in all-packages.nix

  + This means you can't use `gtk = gtk_3`, these types of alliases do NOT
    pass overrides through aliases causing adverse affects.

* Go Lang

  + package auto updater
  + unvendors vendored dependencies for reuse

* enable /tmp cleanup by default


* Misc Changes

  + gnome, disable all applications by default
  + gdk-pixbuf is now a meta loader package containing gdk-pixbuf-core & librsvg.
    Previously the loaders were combined in the librsvg package and then librsvg
    was used by the gdk-pixbuf hook to set the module path.
  + glib add hook to add gio modules to GIO_EXTRA_MODULES path
  +  removed unversioned gtk{mm} attr
  +  refactored gstreamer 0 & 1, all new attr names
  + refactored nvidia-drivers, long-lived is the default

    - added tests

  + chromium - fetch tarball hash instead of downloading tarball in updater
  + gnome, gtk, cairo - full wayland support
  + x265 multi lib
  + libbluray, enable java by default (required for most all modern blurays)
  + new consistent coding style, needs coding style guide
  + disable all non-required services by default.

     - dhcp
     - ntpd
     - dns
     - ???

  + dbus: remove multiple outputs
  + xorg: disable xterm terminal emulator
  + remove garbage ati build (needs rewrite)
  + enable /tmp cleanup by default
  + disable audit in the kernel by default
  + merge ffmpeg builds (regular & full) & remove pre 2.x versions

