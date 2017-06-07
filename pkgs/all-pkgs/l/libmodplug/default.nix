{ stdenv
, fetchurl
}:

let
  version = "0.8.9.0";
in
stdenv.mkDerivation rec {
  name = "libmodplug-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/modplug-xmms/libmodplug/${version}/${name}.tar.gz";
    sha256 = "457ca5a6c179656d66c01505c0d95fafaead4329b9dbaa0f997d00a3508ad9de";
  };

  meta = with stdenv.lib; {
    description = "MOD playing library";
    homepage = "http://modplug-xmms.sourceforge.net/";
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
