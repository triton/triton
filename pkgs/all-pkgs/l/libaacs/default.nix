{ stdenv
, bison
, fetchurl
, flex
, lib

, libgcrypt
, libgpg-error
}:

# Info on how to use / obtain aacs keys:
# http://vlc-bluray.whoknowsmy.name/
# https://wiki.archlinux.org/index.php/BluRay

let
  version = "0.9.0";
in
stdenv.mkDerivation rec {
  name = "libaacs-${version}";

  src = fetchurl {
    url = "mirror://videolan/libaacs/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "47e0bdc9c9f0f6146ed7b4cc78ed1527a04a537012cf540cf5211e06a248bace";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    libgcrypt
    libgpg-error
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha512Url = map (n: "${n}.sha512") src.urls;
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library to access AACS protected Blu-Ray disks";
    homepage = https://www.videolan.org/developers/libaacs.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
