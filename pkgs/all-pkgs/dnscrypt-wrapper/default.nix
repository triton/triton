{ stdenv
, fetchurl

, libevent
, libsodium
}:

let
  version = "0.2.1";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-wrapper-${version}";

  src = fetchurl {
    url = "https://github.com/Cofyc/dnscrypt-wrapper/releases/download/v${version}"
      + "/dnscrypt-wrapper-v${version}.tar.bz2";
    sha256 = "02f52859ec766e85b2825dabdb89a34c8d126c538b5550efe2349ecae2aeb266";
  };

  buildInputs = [
    libevent
    libsodium
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
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
