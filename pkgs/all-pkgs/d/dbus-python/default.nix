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
  version = "1.2.16";
in
stdenv.mkDerivation rec {
  name = "dbus-python-${version}";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-python/${name}.tar.gz";
    multihash = "QmTfPTt1weDR4GxELA3xRyt2ae2skMr7Gsk4RBtV1eygWi";
    sha256 = "11238f1d86c995d8aed2e22f04a1e3779f0d70e587caffeab4857f3c662ed5a4";
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
