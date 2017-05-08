{ stdenv
, asciidoc
, cmake
, docbook-xsl
, fetchFromGitHub
, libxslt
, ninja

, cairo
, ewlc
, gdk-pixbuf
, json-c
, libcap
, libinput
, libxkbcommon
, mesa_noglu
, pam
, pango
, pcre
, systemd_lib
, wayland
}:

let
  version = "0.13.0";
in
stdenv.mkDerivation rec {
  name = "sway-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "SirCmpwn";
    repo = "sway";
    rev = version;
    sha256 = "2e331b548a8441864502e482bc796adacfb8253b974fa9ec9d160248ecef2d45";
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
    ewlc
    gdk-pixbuf
    json-c
    libcap
    libinput
    libxkbcommon
    mesa_noglu
    pam
    pango
    pcre
    systemd_lib
    wayland
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
