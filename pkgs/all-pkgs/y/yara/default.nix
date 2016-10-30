{ stdenv
, autoreconfHook
, fetchFromGitHub

, file
, jansson
, openssl
}:

let
  version = "3.5.0";
in
stdenv.mkDerivation {
  name = "yara-${version}";

  src = fetchFromGitHub {
    version = "2";
    owner = "VirusTotal";
    repo = "yara";
    rev = "v${version}";
    sha256 = "d414d73a7258bcbba9ffd3ec3011d1a0c1c0728d753052d969f99834d114e460";
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
  dontDisableStatic = true;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
