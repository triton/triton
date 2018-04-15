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
  version = "0.15.2";
in
stdenv.mkDerivation rec {
  name = "sway-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0e800e99f425f51eefff08997c29cc95b7c6907b5e3c9fcdeea472cfbfa27fae";
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
