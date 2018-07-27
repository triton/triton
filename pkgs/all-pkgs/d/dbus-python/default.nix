{ stdenv
, buildPythonPackage
, fetchurl
, lib
, python

, dbus
, dbus-glib
, glib
}:

let
  version = "1.2.8";
in
stdenv.mkDerivation rec {
  name = "dbus-python-${version}";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-python/${name}.tar.gz";
    multihash = "QmYhvL6Cw5uTNTM1qgf5cxzTyEr59EcpwHtnrXrVLDFBbn";
    sha256 = "abf12bbb765e300bf8e2a1b2f32f85949eab06998dbda127952c31cb63957b6f";
  };

  buildInputs = [
    dbus
    glib
    python
  ];

  configureFlags = [
    "PYTHON=${python.interpreter}"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Simon McVittie
        "DA98 F25C 0871 C49A 59EA  FF2C 4DE8 FF2A 63C7 CC90"
        "3C86 72A0 F496 37FE 064A  C30F 52A4 3A1E 4B77 B059"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
