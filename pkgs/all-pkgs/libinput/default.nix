{ stdenv
, fetchurl

, libevdev
, libwacom
, mtdev
, systemd_lib

, documentationSupport ? false
  , doxygen ? null
  , graphviz ? null
 # GUI event viewer support
, eventGUISupport ? false
  , cairo ? null
  , glib ? null
  , gtk3 ? null
, testsSupport ? false
  , check ? null
  , valgrind ? null
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

assert documentationSupport ->
  doxygen != null
  && graphviz != null;
assert eventGUISupport ->
  cairo != null
  && glib != null
  && gtk3 != null;
assert testsSupport ->
  check != null
  && valgrind != null;

stdenv.mkDerivation rec {
  name = "libinput-1.2.1";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/libinput/${name}.tar.xz";
    sha256 = "1hy1h0a4zx5wj23sah4kms2z0285yl0kcn4fqlrrp1gqax9qrnz2";
  };

  buildInputs = [
    libevdev
    libwacom
    mtdev
    systemd_lib
  ] ++ optionals eventGUISupport [
    cairo
    glib
    gtk3
  ] ++ optionals documentationSupport [
    doxygen
    graphviz
  ] ++ optionals testsSupport [
    check
    valgrind
  ];

  configureFlags = [
    (enFlag "documentation" documentationSupport null)
    (enFlag "event-gui" eventGUISupport null)
    (enFlag "tests" testsSupport null)
  ];

  meta = with stdenv.lib; {
    description = "Library to handle input devices";
    homepage = http://www.freedesktop.org/wiki/Software/libinput;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
