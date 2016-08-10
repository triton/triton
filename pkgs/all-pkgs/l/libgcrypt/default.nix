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

  version = "1.7.2";
in
stdenv.mkDerivation rec {
  name = "libgcrypt-${version}";

  src = fetchurl {
    url = tarballUrls version;
    allowHashOutput = false;
    sha256 = "3d35df906d6eab354504c05d749a9b021944cb29ff5f65c8ef9c3dd5f7b6689f";
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

  # Make sure includes are fixed for callers who don't use libgpgcrypt-config
  postInstall = ''
    sed -i 's,#include <gpg-error.h>,#include "${libgpg-error}/include/gpg-error.h",g' $out/include/gcrypt.h
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.7.2";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6";
      outputHash = "3d35df906d6eab354504c05d749a9b021944cb29ff5f65c8ef9c3dd5f7b6689f";
      inherit (src) outputHashAlgo;
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
