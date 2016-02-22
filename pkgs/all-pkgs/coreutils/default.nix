{ stdenv
, fetchurl
, perl

, gmp
, aclSupport ? true, acl
, selinuxSupport? false, libselinux, libsepol
}:

stdenv.mkDerivation rec {
  name = "coreutils-8.25";

  src = fetchurl {
    url = "mirror://gnu/coreutils/${name}.tar.xz";
    sha256 = "11yfrnb94xzmvi4lhclkcmkqsbhww64wf234ya1aacjvg82prrii";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    gmp
  ] ++ stdenv.lib.optional aclSupport acl;

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/coreutils/;
    description = "The basic file, shell and text manipulation utilities of the GNU operating system";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
