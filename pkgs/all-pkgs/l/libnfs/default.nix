{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  date = "2018-07-12";
  rev = "322148b0161e5b570ae68af36b9ca7966ce57566";
in
stdenv.mkDerivation rec {
  name = "libnfs-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sahlberg";
    repo = "libnfs";
    inherit rev;
    sha256 = "65eba9fc439f2b833a2b4f9a741647896aefb71059a930717e2e0455739b60ba";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--enable-utils"
    "--disable-examples"
    "--disable-werror"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
