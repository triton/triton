{ stdenv
, fetchurl
}:

let
  version = "1.4";
in
stdenv.mkDerivation rec {
  name = "rpcsvc-proto-${version}";

  src = fetchurl {
    url = "https://github.com/thkukuk/rpcsvc-proto/releases/download/v${version}/${name}.tar.xz";
    sha256 = "4149d5f05d8f7224a4d207362fdfe72420989dc1b028b28b7b62b6c2efe22345";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
