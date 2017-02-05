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
  version = "0.8.1";
in
stdenv.mkDerivation rec {
  name = "libaacs-${version}";

  src = fetchurl {
    url = "mirror://videolan/libaacs/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "95c344a02c47c9753c50a5386fdfb8313f9e4e95949a5c523a452f0bcb01bbe8";
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
