{ stdenv
, fetchurl
, isPy3
, lib

, glib
, gobject-introspection
, pycairo
, cairo
, libffi
, python

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals
    optionalString
    versionOlder;

  sources = {
    "2.28" = {
      version = "2.28.7";
      sha256 = "bb9d25a3442ca7511385a7c01b057492095c263784ef31231ffe589d83a96a5a";
    };
    "3.28" = {
      version = "3.28.2";
      sha256 = "ac443afd14fcb9ff5744b65d6e2b380e70510278404fb8684a9b9fb089e6f2ca";
    };
  };
  source = sources."${channel}";

  is2x = versionOlder channel "3.0";
in

# Pygobject 2.x is not compatible with Python 3.x
assert is2x -> !isPy3;

stdenv.mkDerivation rec {
  name = "pygobject-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pygobject/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    glib
    gobject-introspection
    libffi
    python
  ] ++ optionals (!is2x) [
    cairo
    pycairo
  ];

  configureFlags = optionals is2x [
    "--disable-maintainer-mode"
  ] ++ [
    "--enable-thread"
  ] ++ optionals is2x [
    "--disable-docs"
  ] ++ [
    "--enable-glibtest"
    "--${boolEn (cairo != null)}-cairo"
  ] ++ optionals is2x [
    "--disable-introspection"  # FIXME
  ] ++ optionals (!is2x) [
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-code-coverage"
    "--with-common"
  ] ++ optionals is2x [
    "--${boolWt (libffi != null)}-ffi"
  ];

  # in a "normal" setup, pygobject and pygtk are installed into the
  # same site-packages: we need a pth file for both. pygtk.py would be
  # used to select a specific version, in our setup it should have no
  # effect, but we leave it in case somebody expects and calls it.
  postInstall = optionalString is2x ''
    mv $out/lib/${python.libPrefix}/site-packages/{pygtk.pth,${name}.pth}
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/pygobject/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Python Bindings for GLib/GObject/GIO/GTK+";
    homepage = https://wiki.gnome.org/action/show/Projects/PyGObject;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
