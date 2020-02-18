{ stdenv
, fetchurl
, lib
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "sysfsutils-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/linux-diag/sysfsutils/${version}/${name}.tar.gz";
    sha256 = "e865de2c1f559fff0d3fc936e660c0efaf7afe662064f2fb97ccad1ec28d208a";
  };

  preConfigure = ''
    patchShebangs configure
  '';

  meta = with lib; {
    homepage = http://linux-diag.sourceforge.net/Sysfsutils.html;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
