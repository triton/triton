{ stdenv
, fetchurl
, autoreconfHook

, libselinux
, util-linux_lib
}:

let
  version = "1.7.0";
in
stdenv.mkDerivation rec {
  name = "f2fs-tools-${version}";

  src = fetchurl {
    url = "https://git.kernel.org/cgit/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${name}.tar.gz";
    sha256 = "33d454c2e95aabef5659949c4fff15f6c9877b48349e64411de502bc62b0cbd4";
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
