{ stdenv
, fetchFromGitHub
, lib

, libevent
, libsodium
}:

let
  version = "0.4.2";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-wrapper-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cofyc";
    repo = "dnscrypt-wrapper";
    rev = "v${version}";
    sha256 = "b3e5470eb2db64ef98e875ed933de7ebf29014ad05c21a9c2862a20710558ad8";
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
