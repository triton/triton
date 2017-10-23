{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  date = "2017-10-14";
  rev = "5bc77e9ea99ca7c3caefc6cd45b7bd43f83fafc3";
in
stdenv.mkDerivation rec {
  name = "libnfs-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sahlberg";
    repo = "libnfs";
    inherit rev;
    sha256 = "a1710405d2fcbd1b028123ee2ff257ba557813060d234a23b332c4229434815d";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--disable-werror"
    "--enable-utils"
    "--disable-examples"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
