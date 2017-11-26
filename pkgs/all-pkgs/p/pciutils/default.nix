{ stdenv
, fetchurl
, which

, kmod
, systemd_lib
, zlib
}:

let
  name = "pciutils-3.5.6"; # with database from 2017-11

  tarballUrls = [
    "mirror://kernel/software/utils/pciutils/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "f346eeb90cce0910c05b877fe49eadc760fa084c0455fd313e39d4b2c2d4bb21";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    kmod
    systemd_lib
    zlib
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  makeFlags = [
    "SHARED=yes"
    "ZLIB=yes"
    "DNS=yes"
  ];

  installTargets = [
    "install"
    "install-lib"
  ];

  # Get rid of update-pciids as it won't work.
  postInstall = ''
    rm $out/sbin/update-pciids $out/man/man8/update-pciids.8
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpDecompress = true;
      pgpKeyFingerprint = "5558 F939 9CD7 8368 5055  3C6E C28E 7847 ED70 F82D";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://mj.ucw.cz/pciutils.html;
    description = "A collection of programs for inspecting and manipulating configuration of PCI devices";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

