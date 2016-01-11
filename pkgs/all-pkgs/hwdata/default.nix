{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "hwdata-0.284";

  src = fetchurl {
    url = "https://git.fedorahosted.org/cgit/hwdata.git/snapshot/${name}.tar.xz";
    sha256 = "0s1mxdwi77cf13ad6rs9rqkgh6jsn1i7abjdrxss82afvn0xxz0f";
  };

  postPatch = ''
    patchShebangs ./configure
  '';

  configureFlags = [
    "--datadir=$(prefix)/data"
  ];

  meta = with stdenv.lib; {
    description = "Hardware Database, including Monitors, pci.ids, usb.ids, and video cards";
    homepage = "https://fedorahosted.org/hwdata/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
