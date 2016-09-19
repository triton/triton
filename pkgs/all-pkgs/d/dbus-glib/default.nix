{ stdenv
, fetchurl
, gettext

, dbus
, expat
, glib
}:

stdenv.mkDerivation rec {
  name = "dbus-glib-0.108";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-glib/${name}.tar.gz";
    multihash = "QmSJoCBLa7mMCHW5JXZBrt8tE4nurAJ7mECH9FBFVu559T";
    hashOutput = false;
    sha256 = "9f340c7e2352e9cdf113893ca77ca9075d9f8d5e81476bf2bf361099383c602c";
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
    "--disable-tests"
    "--disable-ansi"
    "--disable-gcov"
    "--enable-bash-completition"
    "--disable-asserts"
    "--disable-checks"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
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

  meta = with stdenv.lib; {
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
