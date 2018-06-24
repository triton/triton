{ stdenv
, fetchurl
}:

let
  version = "1.0.3";
in
stdenv.mkDerivation rec {
  name = "libqb-${version}";

  src = fetchurl {
    url = "https://github.com/ClusterLabs/libqb/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a02ba8564ba4bfe9a10bbc03d4f0952c2a73a5e674441b4ac8d19dfe54eaf4f7";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  # Purity fix
  preFixup = ''
    grep -q "$TMPDIR" "$out"/lib/libqb.la
    sed -i "s,\(inherited_linker_flags='\).*,\1'," "$out"/lib/libqb.la
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Christine Caulfield
        "EA78 541A 2D92 4511 06C8  A1F7 B671 57F3 A70D 4537"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://sourceware.org/lvm2/;
    descriptions = "Tools to support Logical Volume Management (LVM) on Linux";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
