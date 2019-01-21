{ stdenv
, fetchzip
, autoreconfHook

, acl
, libselinux
, util-linux_lib
}:

let
  version = "1.12.0";
in
stdenv.mkDerivation rec {
  name = "f2fs-tools-${version}";

  src = fetchzip {
    version = 6;
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${name}.tar.gz";
    multihash = "QmfJhPE26EivkqFoEs25dPXXVdrfX1Xio4qFycBrHZKsSC";
    sha256 = "f1477254e7bca199a81b3142741c7c10094cb77741ac5b8958a37abacc2caa32";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    acl
    libselinux
    util-linux_lib
  ];

  meta = with stdenv.lib; {
    description = "Userland tools for the f2fs filesystem";
    homepage = https://git.kernel.org/cgit/linux/kernel/git/jaegeuk/f2fs-tools.git/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
