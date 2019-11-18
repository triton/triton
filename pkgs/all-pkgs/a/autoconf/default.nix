{ stdenv
, fetchurl
, gnum4
, lib
, perl

, channel ? "latest"
}:

let
  sources = {
    "latest" = {
      version = "2.69";
      compression = "xz";
      sha256 = "113nlmidxy9kjr45kg9x3ngar4951mvag1js2a3j8nxcz34wxsv4";
    };
    "2.1x" = {
      version = "2.13";
      compression = "gz";
      sha256 = "f0611136bee505811e9ca11ca7ac188ef5323a8e2ef19cffd3edb3cf08fd791e";
    };
  };

  inherit (sources."${channel}")
    compression
    version
    sha256;
in
stdenv.mkDerivation rec {
  name = "autoconf-${version}";

  src = fetchurl {
    url = "mirror://gnu/autoconf/${name}.tar.${compression}";
    inherit sha256;
  };

  buildInputs = [
    gnum4.bin
    perl
  ];

  postFixup = ''
    rm -rv "$bin"/share/info
  '';

  outputs = [
    "bin"
    "man"
  ];

  meta = with lib; {
    description = "Part of the GNU Build System";
    homepage = http://www.gnu.org/software/autoconf/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
