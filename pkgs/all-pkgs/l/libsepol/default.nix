{ stdenv
, fetchurl
, flex
, lib
}:

let
  release = "20190315";
  version = "2.9";
in
stdenv.mkDerivation rec {
  name = "libsepol-${version}";

  src = fetchurl {
    url = "https://github.com/SELinuxProject/selinux/releases/download/"
      + "${release}/${name}.tar.gz";
    sha256 = "a34b12b038d121e3e459b1cbaca3c9202e983137819c16baf63658390e3f1d5d";
  };

  nativeBuildInputs = [
    flex
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
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
