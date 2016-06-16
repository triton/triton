{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "npth-1.2";

  src = fetchurl {
    url = "mirror://gnupg/npth/${name}.tar.bz2";
    sha256 = "12n0nvhw4fzwp0k7gjv3rc6pdml0qiinbbfiz4ilg6pl5kdxvnvd";
  };

  meta = with stdenv.lib; {
    description = "The New GNU Portable Threads Library";
    homepage = http://www.gnupg.org;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
