{ stdenv
, fetchurl

, libraw1394
}:

stdenv.mkDerivation rec {
  name = "libavc1394-0.5.4";

  src = fetchurl {
    url = "mirror://sourceforge/libavc1394/${name}.tar.gz";
    sha256 = "0lsv46jdqvdx5hx92v0z2cz3yh6212pz9gk0k3513sbaa04zzcbw";
  };

  buildInputs = [
    libraw1394
  ];

  meta = with stdenv.lib; {
    description = "Programming interface for the 1394 Trade Association AV/C (Audio/Video Control) Digital Interface Command Set";
    homepage = http://sourceforge.net/projects/libavc1394/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
