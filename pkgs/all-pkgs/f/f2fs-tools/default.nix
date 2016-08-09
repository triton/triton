{ stdenv
, fetchurl
, autoreconfHook

, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "f2fs-tools-${version}";
  version = "1.6.1";

  src = fetchurl {
    url = "http://git.kernel.org/cgit/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${name}.tar.gz";
    sha256 = "1fkq1iqr5kxs6ihhbmjk4i19q395azcl60mnslqwfrlbrd3p40gm";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    util-linux_lib
  ];

  meta = with stdenv.lib; {
    description = "Userland tools for the f2fs filesystem";
    homepage = "http://git.kernel.org/cgit/linux/kernel/git/jaegeuk/f2fs-tools.git/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
