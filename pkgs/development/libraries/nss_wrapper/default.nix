{ stdenv, fetchurl, cmake, pkgconfig }:

stdenv.mkDerivation rec {
  name = "nss_wrapper-1.1.2";

  src = fetchurl {
    url = "mirror://samba/cwrap/${name}.tar.gz";
    sha256 = "1hk14lqzbm6z6dlwrzvkabmkclbfkikqaz0k664klp67y4my4r8f";
  };

  buildInputs = [ cmake pkgconfig ];

  meta = with stdenv.lib; {
    description = "A wrapper for the user, group and hosts NSS API";
    homepage = "https://git.samba.org/?p=nss_wrapper.git;a=summary";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wkennington ];
    platforms = platforms.all;
  };
}
