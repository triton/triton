{ stdenv
, fetchzip
, autoreconfHook

, libselinux
, util-linux_lib
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "f2fs-tools-${version}";

  src = fetchzip {
    version = 2;
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${name}.tar.gz";
    multihash = "QmYtAxnwEbn5QNz7G7knx1AeBnQDvhgUhEkTMyhdUmyEVA";
    sha256 = "b198db1b6bfd7aeb42ab9454bc4c3a1b571e11968ba6f512ad924727c3398465";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
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
