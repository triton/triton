{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, type ? "full"
}:

let
  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "bzip2-1.0.7";

  src = fetchurl {
    url = "mirror://sourceware/bzip2/${name}.tar.gz";
    sha256 = "e768a87c5b1a79511499beb41500bcc4caf203726fff46a6f5f9ad27fe08ab2b";
  };

  patches = [
    # Fix bzgrep compat with POSIX shells
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.4-POSIX-shell.patch";
      sha256 = "e8826fedfed105ba52c85a2e43589ba37424513cb932072136ceac01ceb0ec99";
    })
    # Fix include path
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.6-mingw.patch";
      sha256 = "8da568f1d7daac4ac6b9d7946dd3b807e062b5a1710a2548029cc4f158e8d717";
    })
    # https://bugs.gentoo.org/show_bug.cgi?id=82192
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.6-progress.patch";
      sha256 = "f93e6b50082a8e880ee8436c7ec6a65a8f01e9282436af77f95bb259b1c7f7f7";
    })
  ];

  postPatch = ''
    sed -i "s,^CC=.*,CC=$CC," Makefile-libbz2_so
    sed -i "s,^CC=.*,CC=$CC," Makefile
    sed -i "s,^AR=.*,AR=$AR," Makefile
    sed -i "s,^RANLIB=.*,RANLIB=$RANLIB," Makefile
    sed -i "/^all:/s, test,," Makefile
  '';

  preBuild = ''
    make -j $NIX_BUILD_CORES -f Makefile-libbz2_so
  '';

  preInstall = ''
    installFlagsArray+=("PREFIX=$bin")
  '';

  postInstall = ''
    mv bzip2-shared "$bin"/bin/bzip2
    rm "$bin"/bin/{bzcat,bunzip2}
    ln -sv bzip2 "$bin"/bin/bzcat
    ln -sv bzip2 "$bin"/bin/bunzip

    mkdir -p "$dev"
    mv "$bin"/{lib,include} "$dev"

    mkdir -p "$lib"/lib
    ln -sv $(basename "$(readlink -f libbz2.so* | head -n 1)") "$lib"/lib/libbz2.so
    mv libbz2.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  preFixup = ''
    mkdir -p "$bin"/share
    mv "$bin"/man "$bin"/share
  '';

  postFixup = ''
    rm -rv "$bin"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ] ++ optionals (type == "full") [
    "man"
  ];

  meta = with lib; {
    description = "high-quality data compression program";
    # upstream http://www.bzip.org
    homepage = http://ftp.suse.com/pub/people/sbrabec/bzip2/;
    license = licenses.free;  # bzip2
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
