{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.9";
  version = "${channel}.11";
in
stdenv.mkDerivation rec {
  name = "mm-common-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/mm-common/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "20d1e7466ca4c83c92e29f9e8dfcc8e5721fdf1337f53157bed97be3b73b32a8";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "https://download.gnome.org/sources/mm-common/${channel}/"
        + "${name}.sha256sum";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
