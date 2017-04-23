{ stdenv
, fetchurl
, flex
, lib
}:

let
  release = "20161014";
  version = "2.6";
in
stdenv.mkDerivation rec {
  name = "libsepol-${version}";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/"
      + "files/releases/${release}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "d856d6506054f52abeaa3543ea2f2344595a3dc05d0d873ed7f724f7a16b1874";
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
