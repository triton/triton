{ stdenv
, fetchurl
, flex
, lib
}:

let
  release = "20160223";
  version = "2.5";
in
stdenv.mkDerivation rec {
  name = "libsepol-${version}";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/"
      + "files/releases/${release}/${name}.tar.gz";
    sha256 = "2bdeec56d0a08b082b93b40703b4b3329cc5562152f7254d8f6ef6b56afe850a";
  };

  nativeBuildInputs = [
    flex
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "DESTDIR=$out"
      "PREFIX=$out"
    )
  '';

  meta = with lib; {
    description = "SELinux binary policy representation library";
    homepage = http://userspace.selinuxproject.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
