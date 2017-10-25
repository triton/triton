{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, file
, jansson
, openssl
}:

let
  version = "3.6.3";
in
stdenv.mkDerivation {
  name = "yara-${version}";

  src = fetchFromGitHub {
    version = "2";
    owner = "VirusTotal";
    repo = "yara";
    rev = "v${version}";
    sha256 = "90c8113c2bc17715d02e269518120abb4298b3be8e5f9a5bc83d7213b8d98fac";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    file
    jansson
    openssl
  ];

  configureFlags = [
    "--enable-cuckoo"
    "--enable-magic"
  ];

  # This is broken with their build system
  disableStatic = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
