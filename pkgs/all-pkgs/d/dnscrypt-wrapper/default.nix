{ stdenv
, fetchFromGitHub
, lib

, libevent
, libsodium
}:

let
  version = "0.4.0";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-wrapper-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "cofyc";
    repo = "dnscrypt-wrapper";
    rev = "v${version}";
    sha256 = "1ff78deeac40f12d5c5831a6452932cd5af76acc6e0011922168d560b764fe00";
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
