{ stdenv
, fetchurl
, lib

, libevent
, libsodium
}:

let
  version = "0.3";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-wrapper-${version}";

  src = fetchurl {
    url = "https://github.com/Cofyc/dnscrypt-wrapper/releases/download/"
      + "v${version}/dnscrypt-wrapper-v${version}.tar.bz2";
    sha256 = "ec5c290ba9b9a05536fa6ee827373ca9b3841508e6d075ae364405152446499c";
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
