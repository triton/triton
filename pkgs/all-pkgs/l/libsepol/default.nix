{ stdenv
, fetchurl
, flex
, lib
}:

let
  release = "20191204";
  version = "3.0";
in
stdenv.mkDerivation rec {
  name = "libsepol-${version}";

  src = fetchurl {
    url = "https://github.com/SELinuxProject/selinux/releases/download/"
      + "${release}/${name}.tar.gz";
    sha256 = "5b7ae1881909f1048b06f7a0c364c5c8a86ec12e0ec76e740fe9595a6033eb79";
  };

  nativeBuildInputs = [
    flex
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
    "-fcommon"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "SHLIBDIR=$out/lib"
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
