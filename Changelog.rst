List of undocumented changes
============================

This is probably missing a lot

* pkgconfig is now part of stdenv
* absolute-pkgconfig hook
* absolute-libtool hook
* parallel building enabled by default
* enableParallelBuilding is deprecated, use the following instead
   + parallelBuild
   + parallelInstall
   + parallelCheck
* mesaSupported -> mesa_noglu.meta.platforms
* mesa.driverLink -> mesa.driverSearchPath
* gnome, disable all applications by default
* gdk-pixbuf is now a meta loader package containing gdk-pixbuf-core & librsvg.
  Previously the loaders were combined in the librsvg package and then librsvg
  was used by the gdk-pixbuf hook to set the module path.
* glib add hook to add gio modules to GIO_EXTRA_MODULES path
* removed gnome3 attr
* xorg libraries are now only accessible via the xorg attr, e.g. xorg.libX11
* removed unversioned gtk{mm} attr
* refactored gstreamer 0 & 1, all new attr names
* refactored nvidia-drivers, long-lived is the default
* added ninja support to the cmake hook
* move patches to triton/triton-patches repo, added fetchTritonPatch
* deprecate category based package hierarchy in favor of
  pkgs/all-pkgs/<pkg-name>/*.nix
* python is now built with all modules by default
* chromium - fetch tarball hash instead of downloading tarball in updater
* gnome, gtk, cairo - full wayland support
* x265 multi lib
* libbluray, enable java by default
* new consistent coding style, needs coding style guide
* golang package updater
