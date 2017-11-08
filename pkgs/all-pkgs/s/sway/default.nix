{ stdenv
, asciidoc
, cmake
, docbook-xsl
, fetchFromGitHub
, libxslt
, ninja

, cairo
, dbus
, gdk-pixbuf
, json-c
, libcap
, libinput
, libxkbcommon
, opengl-dummy
, pam
, pango
, pcre
, systemd_lib
, wayland
, wlc
}:

let
  version = "0.15";
in
stdenv.mkDerivation rec {
  name = "sway-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "ba108b2b855327f03b3452ecc86a44f0a042bf3a52afe45010416265414f7b05";
  };

  nativeBuildInputs = [
    asciidoc
    cmake
    docbook-xsl
    libxslt
    ninja
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    json-c
    libcap
    libinput
    libxkbcommon
    opengl-dummy
    pam
    pango
    pcre
    systemd_lib
    wayland
    wlc
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
