{ stdenv
, fetchurl
, lib
, makeWrapper
, meson
, ninja
, python3Packages

, fuse_3
, glib
, openssh
}:

let
  version = "3.5.0";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/${name}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "c2035332489dea3be88b9328d0e1905f904a34f93eb87fb07cd5380329a3dfe5";
  };

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    python3Packages.docutils
  ];

  buildInputs = [
    fuse_3
    glib
    openssh
  ];

  postPatch = ''
    grep -q "'rst2man'" meson.build
    sed -i "s,'rst2man','rst2man.py',g" meson.build
  '';

  preFixup = ''
    wrapProgram $out/bin/sshfs \
      --prefix 'PATH' : "${fuse_3}/bin"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
