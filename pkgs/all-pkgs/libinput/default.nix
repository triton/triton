{ stdenv
, fetchurl

, libevdev
, mtdev
, udev

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
  name = "libinput-1.1.8";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/libinput/${name}.tar.xz";
    sha256 = "0iwpysfkd4gpwn05k17mdm5giy0dz6kax07ibpk1aklwflwrc37y";
  };

  buildInputs = [
    libevdev
    mtdev
    udev
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
