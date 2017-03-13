{ stdenv
, fetchurl
, groff
}:

let
  tarballUrls = version: [
    "mirror://kernel/linux/utils/raid/mdadm/mdadm-${version}.tar"
  ];

  version = "4.0";
in
stdenv.mkDerivation rec {
  name = "mdadm-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "1d6ae7f24ced3a0fa7b5613b32f4a589bb4881e3946a5a2c3724056254ada3a9";
  };

  nativeBuildInputs = [
    groff
  ];

  patches = [
    ./no-self-references.patch
  ];

  postPatch = ''
    sed -e 's@/lib/udev@''${out}/lib/udev@' -e 's@ -Werror @ @' -i Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "INSTALL_BINDIR=$out/sbin"
      "MANDIR=$out/share/man"
    )
  '';

  makeFlags = [
    "NIXOS=1"
    "RUN_DIR=/dev/.mdadm"
    "INSTALL=install"
  ];

  # Attempt removing if building with gcc5 when updating
  #NIX_CFLAGS_COMPILE = [
  #  "-std=gnu89"
  #];

  # This is to avoid self-references, which causes the initrd to explode
  # in size and in turn prevents mdraid systems from booting.
  allowedReferences = [
    stdenv.cc.libc
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.sign") (tarballUrls version);
      pgpKeyFingerprint = "6A86 B80E 1D22 F21D 0B26  BA75 397D 82E0 531A 9C91";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Programs for managing RAID arrays under Linux";
    homepage = http://neil.brown.name/blog/mdadm;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
