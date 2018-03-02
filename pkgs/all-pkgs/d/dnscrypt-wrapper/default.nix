{ stdenv
, fetchFromGitHub
, lib

, libevent
, libsodium
}:

let
  version = "0.4.1";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-wrapper-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "cofyc";
    repo = "dnscrypt-wrapper";
    rev = "v${version}";
    sha256 = "db85e635ba8a96502ada7e9611bd8935226e07842c315d2f87144598fc4b6b79";
  };

  buildInputs = [
    libevent
    libsodium
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    desciption = "Wrapper helps to add dnscrypt support to any name resolver";
    homepage = https://github.com/Cofyc/dnscrypt-wrapper;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
