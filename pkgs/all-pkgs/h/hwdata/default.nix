{ stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "hwdata-0.291";

  src = fetchzip {
    version = 1;
    url = "https://git.fedorahosted.org/cgit/hwdata.git/snapshot/${name}.tar.xz";
    multihash = "QmVK9tFW7bpf1uTHLWdRiTrQ1KqVGrjQvsy5NUiZLPGhXm";
    sha256 = "5595cd3ba209c01a51514f5604fcb7f93146a8ea4e7f686b63a157377a021c83";
  };

  postPatch = ''
    patchShebangs ./configure
  '';

  configureFlags = [
    "--datadir=$(prefix)/share"
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
