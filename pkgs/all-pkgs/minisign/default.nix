{ stdenv
, cmake
, fetchurl
, ninja

, libsodium
}:

let
  genUrls = version: [
    "https://github.com/jedisct1/minisign/archive/${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "minisign-${version}";
  version = "0.6";

  src = fetchurl {
    urls = genUrls version;
    allowHashOutput = false;
    sha256 = "f2267a07bece923d4d174ccacccc56eff9c05b28c4d971e601de896355442f09";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libsodium
  ];

  passthru = rec {
    nextVersion = "0.6";

    srcVerified = fetchurl {
      failEarly = true;
      urls = genUrls version;
      minisignUrl = "https://github.com/jedisct1/minisign/releases/download/${nextVersion}/minisign-${nextVersion}.tar.gz.minisig";
      minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      sha256 = "f2267a07bece923d4d174ccacccc56eff9c05b28c4d971e601de896355442f09";
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
