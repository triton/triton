{ stdenv
, fetchurl
, perl

, acl
, gmp
, selinuxSupport? false
  , libselinux
  , libsepol
}:

let
  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "coreutils-8.26";

  src = fetchurl {
    url = "mirror://gnu/coreutils/${name}.tar.xz";
    sha256 = "155e94d748f8e2bc327c66e0cbebdb8d6ab265d2f37c3c928f7bf6c3beba9a8e";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    acl
    gmp
  ] ++ optionals selinuxSupport [
    libselinux
    libsepol
  ];

  meta = with stdenv.lib; {
    description = "Basic file, shell & text manipulation utilities of the GNU operating system";
    homepage = http://www.gnu.org/software/coreutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    priority = -9;  # This should have a higher priority than everything
  };
}
