{ stdenv
, fetchurl
, lib
, meson
, ninja

, libevdev
, libwacom
, mtdev
, systemd_lib

, documentationSupport ? false
  , doxygen
  , graphviz
 # GUI debug viewer support
, debugGUISupport ? false
  , cairo
  , glib
  , gtk3
, testsSupport ? false
  , check
  , valgrind
}:

let
  inherit (lib)
    boolTf
    optionals;
in

assert documentationSupport ->
  doxygen != null
  && graphviz != null;
assert debugGUISupport ->
  cairo != null
  && glib != null
  && gtk3 != null;
assert testsSupport ->
  check != null
  && valgrind != null;

stdenv.mkDerivation rec {
  name = "libinput-1.9.4";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libinput/${name}.tar.xz";
    multihash = "QmUyQ9Z5pQLYP6xRuKEVn84LpA3Cp188NxELCYyYVRCY6W";
    hashOutput = false;
    sha256 = "0bcdbd4c4e3c2a2db322fbdf2ef3284f2e6d6fb7be3af80e6d8de7783f675190";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    libevdev
    libwacom
    mtdev
    systemd_lib
  ] ++ optionals debugGUISupport [
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

  mesonFlags = [
    #"-Dudev-dir"
    "-Dlibwacom=${boolTf (libwacom != null)}"
    "-Ddebug-gui=${boolTf debugGUISupport}"
    "-Dtests=${boolTf testsSupport}"
    "-Ddocumentation=${boolTf documentationSupport}"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = false;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Library to handle input devices";
    homepage = http://www.freedesktop.org/wiki/Software/libinput;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
