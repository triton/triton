{ stdenv
, fetchurl
, lib
}:

let
  version = "20170807";
in
stdenv.mkDerivation rec {
  name = "libuninameslist-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/libuninameslist/releases/download/"
      + "${version}/libuninameslist-dist-${version}.tar.gz";
    sha256 = "0afa78c09468738fe92b83bdfda3f1b4b773a57e67f676f6a5203e64de0d1aa4";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

