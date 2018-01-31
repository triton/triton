{ stdenv
, buildPythonPackage
, fetchurl
, lib

, dbus
, dbus-glib
}:

let
  version = "1.2.6";
in
buildPythonPackage rec {
  name = "dbus-python-${version}";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-python/${name}.tar.gz";
    multihash = "QmUzysEv7fQZwPgLiK61CdzwkGKvYdkqvHr3T5HfNwy988";
    sha256 = "32f29c17172cdb9cb61c68b1f1a71dfe7351506fc830869029c47449bd04faeb";
  };

  buildInputs = [
    dbus
    dbus-glib
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
