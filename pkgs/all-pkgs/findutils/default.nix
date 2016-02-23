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

  doCheck = true;

  # Remove any references to the bootstrap tools
  preFixup = ''
    sed -i "s,$NIX_STORE.*/sort,${coreutils}/bin/sort,g" $out/bin/updatedb
  '';

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/findutils/;
    description = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = platforms.all;
  };
}
