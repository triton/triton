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

let
  inherit (stdenv.lib)
    enFlag
    optionals;
in

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
  name = "libinput-1.5.3";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libinput/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmV4RdZL63iWcUU8iQz5zJfPWeFDeLJLBBJJnyA5xxN3pq";
    sha256 = "91206c523b4e7aeecf296d0b94276c61bea90b9260d198c8ee3a91eced10a6e3";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = false;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
