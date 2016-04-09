{ stdenv
, fetchurl

, libevent
, libsodium
}:

stdenv.mkDerivation rec {
  name = "dnscrypt-wrapper-${version}";
  version = "0.2";

  src = fetchurl {
    url = "https://github.com/Cofyc/dnscrypt-wrapper/releases/download/v${version}/dnscrypt-wrapper-v${version}.tar.bz2";
    sha256 = "d26f9d6329653b71bed5978885385b45f16596021f219f46e49da60d5813054e";
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
