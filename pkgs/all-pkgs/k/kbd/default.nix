{ stdenv
, autoreconfHook
, fetchurl

, pam
}:

let
  tarballUrls = version: [
    "mirror://kernel/linux/utils/kbd/kbd-${version}.tar"
  ];

  version = "2.0.4";
in
stdenv.mkDerivation rec {
  name = "kbd-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "5fd90af6beb225a9bb9b9fb414c090fba53c9a55793e172f508cd43652e59a88";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    pam
  ];

  configureFlags = [
    "--enable-optional-progs"
    "--enable-libkeymap"
    "--enable-nls"
  ];

  makeFlags = [
    "setowner="
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") (tarballUrls version);
      pgpDecompress = true;
      pgpKeyFingerprint = "7F2A 3D07 2981 49A0 793C  9A4E A45A BA54 4CFF D434";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = ftp://ftp.altlinux.org/pub/people/legion/kbd/;
    description = "Linux keyboard utilities and keyboard maps";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
