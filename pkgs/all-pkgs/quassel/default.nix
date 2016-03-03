{ stdenv
, cmake
, fetchurl
, makeWrapper

, dconf
, qt5

, daemon ? false # build Quassel daemon
, client ? false # build Quassel client
, tag ? "" # tag added to the package name
, monolithic ? true # build monolithic Quassel
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  buildClient = monolithic || client;
  buildCore = monolithic || daemon;
in

assert monolithic -> !client && !daemon;
assert client || daemon -> !monolithic;

stdenv.mkDerivation rec {
  name = "quassel${tag}-${version}";
  version = "0.12.3";

  src = fetchurl {
    url = "http://quassel-irc.org/pub/quassel-${version}.tar.bz2";
    sha256 = "0d6lwf6qblj1ia5j9mjy112zrmpbbg9mmxgscbgxiqychldyjgjd";
  };

  #patches = [
  #  # fix build with Qt 5.5
  #  (fetchurl {
  #    url = "https://github.com/quassel/quassel/commit/078477395aaec1edee90922037ebc8a36b072d90.patch";
  #    sha256 = "1njwnay7pjjw0g7m0x5cwvck8xcznc7jbdfyhbrd121nc7jgpbc5";
  #  })
  #];

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    qt5.qtbase
  ] ++ optionals buildCore [
    qt5.qtscript
    qt5.qca-qt5
  ] ++ optionals buildClient [
    qt5.libdbusmenu
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
