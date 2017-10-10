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
  version = "0.15-rc1";
in
stdenv.mkDerivation rec {
  name = "sway-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "66eff2f5786b57b96b6a6be666b67c000dd6dfaa59f318dd04d64fe7c2d14c9a";
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
