{ stdenv
, fetchurl
}:

let
  version = "7.6.6";
in
stdenv.mkDerivation rec {
  name = "libatomic_ops-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/libatomic_ops/releases/download/v${version}/${name}.tar.gz";
    sha256 = "99feabc5f54877f314db4fadeb109f0b3e1d1a54afb6b4b3dfba1e707e38e074";
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
