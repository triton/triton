{ stdenv
, fetchurl
}:

let
  major = "0.9";
  patch = "10";

  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "mm-common-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/mm-common/${major}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "16c0e2bc196b67fbc145edaecb5dbe5818386504fe5703de27002d77140fa217";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "https://download.gnome.org/sources/mm-common/${major}/${name}.sha256sum";
      inherit (src) urls outputHash outputHashAlgo;
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
