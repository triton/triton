{ stdenv
, fetchurl
}:

let
  version = "7.6.8";
in
stdenv.mkDerivation rec {
  name = "libatomic_ops-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/libatomic_ops/releases/download/v${version}/${name}.tar.gz";
    sha256 = "1d6a279edf81767e74d2ad2c9fce09459bc65f12c6525a40b0cb3e53c089f665";
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
