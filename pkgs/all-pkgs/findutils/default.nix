{ stdenv
, fetchurl
, coreutils
}:

stdenv.mkDerivation rec {
  name = "findutils-4.6.0";

  src = fetchurl {
    url = "mirror://gnu/findutils/${name}.tar.gz";
    sha256 = "178nn4dl7wbcw499czikirnkniwnx36argdnqgz4ik9i6zvwkm6y";
  };

  # We don't want to depend on bootstrap-tools
  # This input forces the build system to use our
  # newly built coreutils instead.
  buildInputs = [
    coreutils
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/findutils/;
    description = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
