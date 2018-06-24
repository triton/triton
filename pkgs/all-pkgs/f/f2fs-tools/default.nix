{ stdenv
, fetchzip
, autoreconfHook

, acl
, libselinux
, util-linux_lib
}:

let
  version = "1.10.0";
in
stdenv.mkDerivation rec {
  name = "f2fs-tools-${version}";

  src = fetchzip {
    version = 6;
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${name}.tar.gz";
    multihash = "QmVkecWQEoxb1p3Gq3v98jtSbK9hRDwkyi7eaKwqGvxxJC";
    sha256 = "67debfc18650528f5a5c28fbd3c8981dc037ac3146ad0a0f62166b7b3f09da06";
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
