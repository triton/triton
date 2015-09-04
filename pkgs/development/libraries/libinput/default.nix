{ stdenv, fetchurl, pkgconfig
, libevdev, mtdev, udev
, documentationSupport ? false, doxygen ? null, graphviz ? null # Documentation
, eventGUISupport ? false, cairo ? null, glib ? null, gtk3 ? null # GUI event viewer support
, testsSupport ? false, check ? null, valgrind ? null
}:

assert documentationSupport -> doxygen != null && graphviz != null;
assert eventGUISupport -> cairo != null && glib != null && gtk3 != null;
assert testsSupport -> check != null && valgrind != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "libinput-1.0.1";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/libinput/${name}.tar.xz";
    sha256 = "17prgxxq95i2l8a00clwwmvvskbb9xza9fmym1jvlmxl358v6bs8";
  };

  configureFlags = [
    (mkEnable documentationSupport "documentation" null)
    (mkEnable eventGUISupport      "event-gui"     null)
    (mkEnable testsSupport         "tests"         null)
  ];

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ libevdev mtdev udev ]
    ++ optionals eventGUISupport [ cairo glib gtk3 ]
    ++ optionals documentationSupport [ doxygen graphviz ]
    ++ optionals testsSupport [ check valgrind ];

  meta = {
    description = "Handles input devices in Wayland compositors and provides a generic X.Org input driver";
    homepage    = http://www.freedesktop.org/wiki/Software/libinput;
    license     = licenses.mit;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ codyopel wkennington ];
  };
}
