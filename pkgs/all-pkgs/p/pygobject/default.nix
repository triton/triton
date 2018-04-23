{ stdenv
, autoreconfHook
, fetchFromGitHub
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
      version = "2.28";
      date = "2013-02-19";
      # Latest commit from pygobject-2-28 branch
      rev = "9456ba70fdb98b3a4eb7ee2f630182387a54ca00";
      sha256 = "bf61ddfa54b9af5ff4ed4321ac2a8f613da334e88f481a53a634dd7d08509327";
      fetchzipversion = 2;
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
  name = "pygobject-${source.version}${optionalString is2x "-${source.date}"}";

  src =
    if is2x then
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "GNOME";
        repo = "pygobject";
        inherit (source) rev sha256;
      }
    else
      fetchurl {
        url = "mirror://gnome/sources/pygobject/${channel}/${name}.tar.xz";
        hashOutput = false;
        inherit (source) sha256;
      };

  nativeBuildInputs = optionals is2x [
    autoreconfHook
  ];

  buildInputs = [
    cairo
    glib
    gobject-introspection
    libffi
    pycairo
    python
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
