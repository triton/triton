{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hwdata-0.290";

  src = fetchurl {
    url = "https://git.fedorahosted.org/cgit/hwdata.git/snapshot/${name}.tar.xz";
    sha256 = "b7c693b93f248e0ce8bba60f0003a4d0aac8da868e2669db4d955418854d92e9";
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
