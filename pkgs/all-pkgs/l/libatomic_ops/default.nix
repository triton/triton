{ stdenv
, fetchurl
}:

let
  version = "7.6.0";
in
stdenv.mkDerivation rec {
  name = "libatomic_ops-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/libatomic_ops/releases/download/"
      + "v${version}/${name}.tar.gz";
    sha256 = "8e2c06d1d7a05339aae2ddceff7ac54552854c1cbf2bb34c06eca7974476d40f";
  };

  meta = with stdenv.lib; {
    description = ''A library for semi-portable access to hardware-provided atomic memory update operations'';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
