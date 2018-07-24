{ stdenv
, fetchzip
, autoreconfHook

, acl
, libselinux
, util-linux_lib
}:

let
  version = "1.11.0";
in
stdenv.mkDerivation rec {
  name = "f2fs-tools-${version}";

  src = fetchzip {
    version = 6;
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${name}.tar.gz";
    multihash = "QmdNM9PrUT2dcmrd6vDfZteTayBArxXTXRDhAQMfyU6dfw";
    sha256 = "a9a82b9b7a83974388a34116a5fb870b09219c1b4a60fa176aec363c54546e8e";
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
