{ stdenv
, fetchurl

, libcap
, libgpg-error
, pth
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgcrypt/libgcrypt-${version}.tar.bz2"
  ];

  version = "1.8.5";
in
stdenv.mkDerivation rec {
  name = "libgcrypt-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "3b4a2a94cb637eff5bdebbcaf46f4d95c4f25206f459809339cdada0eb577ac3";
  };

  buildInputs = [
    #libcap  Breaks application not expecting it
    libgpg-error
    #pth  Currently Broken
  ];

  configureFlags = [
    "--without-capabilities"
    "--disable-random-daemon"
  ];

  postInstall = ''
    # Make sure includes are fixed for callers who don't use libgpgcrypt-config
    sed -i 's,#include <gpg-error.h>,#include "${libgpg-error}/include/gpg-error.h",g' $dev/include/gcrypt.h

    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/*-config "$dev"/bin

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    mkdir -p "$dev"/share2
    mv "$dev"/share/aclocal "$dev"/share2
    rm -rv "$dev"/share
    mv "$dev"/share2 "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.8.5";
      outputHash = "3b4a2a94cb637eff5bdebbcaf46f4d95c4f25206f459809339cdada0eb577ac3";
      inherit (src) outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprints = [
          # Werner Koch
          "D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6"
          # NIIBE Yutaka
          "031E C253 6E58 0D8E A286  A9F2 2071 B08A 33BD 3F06"
        ];
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = https://www.gnu.org/software/libgcrypt/;
    description = "General-pupose cryptographic library";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
