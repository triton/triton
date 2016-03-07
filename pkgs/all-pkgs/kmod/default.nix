{ stdenv
, fetchurl
, libxslt

, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "kmod-22";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/kernel/kmod/${name}.tar.xz";
    sha256 = "10lzfkmnpq6a43a3gkx7x633njh216w0bjwz31rv8a1jlgg1sfxs";
  };

  nativeBuildInputs = [
    libxslt
  ];

  buildInputs = [
    xz
    zlib
  ];

  patches = [
    ./module-dir.patch
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-xz"
    "--with-zlib"
  ];

  # Use symlinks instead of hard-links or copies
  postInstall = ''
    ln -s kmod $out/bin/lsmod
    mkdir -p $out/sbin
    for prog in rmmod insmod modinfo modprobe depmod; do
      ln -sv $out/bin/kmod $out/sbin/$prog
    done
  '';

  meta = with stdenv.lib; {
    homepage = http://www.kernel.org/pub/linux/utils/kernel/kmod/;
    description = "Tools for loading and managing Linux kernel modules";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
