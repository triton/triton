{ stdenv
, cmake
, fetchurl
, makeWrapper

, dconf
, qca
, qt5
, zlib

, daemon ? false # build Quassel daemon
, client ? false # build Quassel client
, tag ? "" # tag added to the package name
, monolithic ? true # build monolithic Quassel
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

let
  buildClient = monolithic || client;
  buildCore = monolithic || daemon;
in

assert monolithic -> !client && !daemon;
assert client || daemon -> !monolithic;

stdenv.mkDerivation rec {
  name = "quassel${tag}-${version}";
  version = "0.12.4";

  src = fetchurl {
    url = "http://quassel-irc.org/pub/quassel-${version}.tar.bz2";
    sha256 = "0ka456fb8ha3w7g74xlzfg6w4azxjjxgrhl4aqpbwg3lnd6fbr4k";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    qt5
    zlib
  ] ++ optionals buildCore [
    qca
  ];

  # Prevent ``undefined reference to `qt_version_tag''' in SSL check
  NIX_CFLAGS_COMPILE = [
    "-DQT_NO_VERSION_TAGGING=1"
  ];

  cmakeFlags = [
    "-DEMBED_DATA=OFF"
    "-DSTATIC=OFF"
    "-DUSE_QT5=ON"
    "-DWANT_MONO=${if monolithic then "ON" else "OFF"}"
    "-DWANT_CORE=${if daemon then "ON" else "OFF"}"
    "-DWANT_QTCLIENT=${if client then "ON" else "OFF"}"
    "-DWITH_KDE=OFF"
  ];

  preFixup = optionalString buildClient ''
    wrapProgram "$out/bin/quassel${optionalString client "client"}" \
      --prefix GIO_EXTRA_MODULES : "${dconf}/lib/gio/modules"
  '';

  meta = with stdenv.lib; {
    description = "Qt/KDE distributed IRC client suppporting a remote daemon";
    homepage = http://quassel-irc.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
