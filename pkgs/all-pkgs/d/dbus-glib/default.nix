{ stdenv
, fetchurl
, gettext
, lib

, dbus
, expat
, glib
}:

stdenv.mkDerivation rec {
  name = "dbus-glib-0.110";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-glib/${name}.tar.gz";
    multihash = "QmaZ6RSk5gT5mDk8cTz82XeXxgiA28QPv9eMUrCQ87gT9c";
    hashOutput = false;
    sha256 = "7ce4760cf66c69148f6bd6c92feaabb8812dee30846b24cd0f7395c436d7e825";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    dbus
    expat
    glib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-bash-completition"
    "--disable-checks"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "DA98 F25C 0871 C49A 59EA  FF2C 4DE8 FF2A 63C7 CC90";
    };
  };

  meta = with lib; {
    description = "GLib bindings for D-Bus";
    homepage = http://dbus.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
