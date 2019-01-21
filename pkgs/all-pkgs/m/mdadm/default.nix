{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://kernel/linux/utils/raid/mdadm/mdadm-${version}.tar"
  ];

  version = "4.1";
in
stdenv.mkDerivation rec {
  name = "mdadm-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "ab7688842908d3583a704d491956f31324c3a5fc9f6a04653cb75d19f1934f4a";
  };

  patches = [
    ./no-self-references.patch
  ];

  postPatch = ''
    sed -e 's@/lib/udev@''${out}/lib/udev@' -e 's@ -Werror @ @' -i Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "INSTALL_BINDIR=$out/bin"
      "MANDIR=$out/share/man"
    )
  '';

  makeFlags = [
    "NIXOS=1"
    "RUN_DIR=/dev/.mdadm"
    "INSTALL=install"
  ];

  # This is to avoid self-references, which causes the initrd to explode
  # in size and in turn prevents mdraid systems from booting.
  allowedReferences = stdenv.cc.runtimeLibcLibs;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpDecompress = true;
        pgpsigUrls = map (n: "${n}.sign") (tarballUrls version);
        pgpKeyFingerprint = "6A86 B80E 1D22 F21D 0B26  BA75 397D 82E0 531A 9C91";
      };
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
