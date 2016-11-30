{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libdbi-0.9.0";

  src = fetchurl {
    url = "mirror://sourceforge/libdbi/libdbi/${name}/${name}.tar.gz";
    sha256 = "dafb6cdca524c628df832b6dd0bf8fabceb103248edb21762c02d3068fca4503";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
