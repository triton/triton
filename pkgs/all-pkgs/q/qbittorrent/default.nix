{ stdenv
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
, lib
, makeWrapper
, which

, boost
, dbus
, libtorrent-rasterbar
, qt5
, zlib

, guiSupport ? false
, webuiSupport ? true

, channel ? "stable"
}:

assert guiSupport -> dbus != null;

let
  inherit (lib)
    boolEn
    elemAt
    optionals
    optionalString
    splitString;

  sources = {
    stable = {
      version = "4.0.3";
      sha256 = "9a03b84e6d2ac81a0add84a7946033ff9ea854de49252069e478b9f6efce6bd2";
    };
    head = {
      fetchzipversion = 5;
      version = "2018-01-27";
      rev = "e487b318776b0f564f944e1661e1574779852b51";
      sha256 = "35a50522aa841fa0018891e9a2e2a2163846a60042dfd58326cc521b9f50c450";
    };
  };
  source = sources."${channel}";

  versionSpoofMaj = elemAt (splitString "." sources.stable.version) 0;
  versionSpoofMin = elemAt (splitString "." sources.stable.version) 1;
  versionSpoofPat = elemAt (splitString "." sources.stable.version) 2;
in
stdenv.mkDerivation rec {
  name = "qbittorrent-${source.version}";

  src =
    if channel != "head" then
      fetchurl {
        url = "mirror://sourceforge/qbittorrent/qbittorrent/${name}/${name}.tar.xz";
        hashOutput = false;
        inherit (source) sha256;
      }
    else
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "qbittorrent";
        repo = "qbittorrent";
        inherit (source) rev sha256;
      };

  nativeBuildInputs = [
    makeWrapper
    which
  ];

  buildInputs = [
    boost
    dbus
    libtorrent-rasterbar
    qt5
    zlib
  ];

  postPatch = /* Our lrelease binary is named lrelease, not lrelease-qt5 */ ''
    sed -i qm_gen.pri \
      -e 's/lrelease-qt5/lrelease/'
  '' + /* Use release peer id for head for compatibility with trackers */
    optionalString (channel == "head") ''
    sed -i version.pri \
      -e '/VER_MAJOR/ s/[0-9]\+/${versionSpoofMaj}/' \
      -e '/VER_MINOR/ s/[0-9]\+/${versionSpoofMin}/' \
      -e '/VER_BUGFIX/ s/[0-9]\+/${versionSpoofPat}/' \
      -e '/VER_BUILD/ s/[0-9]\+/0/' \
      -e 's/VER_STATUS = .*/VER_STATUS =/'
  '';

  configureFlags = [
    "--disable-debug"
    "--${boolEn (guiSupport)}-gui"
    "--enable-systemd"
    "--${boolEn webuiSupport}-webui"
    "--${boolEn (dbus != null)}-qt-dbus"
    "--with-qtsingleapplication=shipped"
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    "--with-boost-system"
  ] ++ optionals (channel != "head") [
    "--without-qt4"
    "--with-qjson=system"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "D8F3 DA77 AAC6 7410 5359  9C13 6E4A 2D02 5B7C C9A2";
    };
  };

  meta = with lib; {
    description = "BitTorrent client in C++ and Qt";
    homepage = http://www.qbittorrent.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
