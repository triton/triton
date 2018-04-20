{ stdenv
, fetchurl
, flex
, lib
}:

let
  release = "20180419";
  version = "2.8-rc1";
in
stdenv.mkDerivation rec {
  name = "libsepol-${version}";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/"
      + "files/releases/${release}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "57e8fad435055938dbc52b1ff4a0f6b943aad4a01cc7604a881805e84632d861";
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
