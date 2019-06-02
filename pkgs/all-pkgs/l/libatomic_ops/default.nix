{ stdenv
, fetchurl
}:

let
  version = "7.6.10";
in
stdenv.mkDerivation rec {
  name = "libatomic_ops-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/libatomic_ops/releases/download/v${version}/${name}.tar.gz";
    sha256 = "587edf60817f56daf1e1ab38a4b3c729b8e846ff67b4f62a6157183708f099af";
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
