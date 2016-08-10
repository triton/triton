{ stdenv
, cmake
, fetchFromGitHub

, glib
, zlib
}:

let
  version = "0.4.13";
in
stdenv.mkDerivation rec {
  name = "libproxy-${version}";

  src = fetchFromGitHub {
    owner = "libproxy";
    repo = "libproxy";
    rev = version;
    sha256 = "eecc5f5fb1d897b5e73417223edb08001f38e8182dba6cf3c508d2568cf11dab";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    glib
    zlib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
