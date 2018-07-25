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
  version = "3.4.0";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/${name}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d27ccd35436d72755c40234cefa081e30fa529e092232a5b4abbff2178c2c22f";
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
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      inherit (src) urls outputHash outputHashAlgo;
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
