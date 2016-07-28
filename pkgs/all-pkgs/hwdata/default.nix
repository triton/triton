{ stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "hwdata-0.290";

  src = fetchzip {
    url = "https://git.fedorahosted.org/cgit/hwdata.git/snapshot/${name}.tar.xz";
    multihash = "Qmdwi5owxzh4rrcPUvRvnHuEq2WTfPp2ZykxaxWYz83Jm1";
    sha256 = "d48ed0597d43a2b98ae24402cc8408c5aa370341d6eeba1550fe2d92dadc8e29";
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
