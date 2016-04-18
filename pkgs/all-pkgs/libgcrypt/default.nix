{ stdenv
, fetchurl
, libgpg-error
, libcap
, pth
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgcrypt/libgcrypt-${version}.tar.bz2"
  ];

  version = "1.7.0";
in
stdenv.mkDerivation rec {
  name = "libgcrypt-${version}";

  src = fetchurl {
    url = tarballUrls version;
    allowHashOutput = false;
    sha256 = "b0e67ea74474939913c4d9d9ef4ef5ec378efbe2bebe36389dee319c79bffa92";
  };

  buildInputs = [
    libgpg-error
    #libcap  Breaks application not expecting it
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
    srcVerified = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.7.0";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyId = "4F25E3B6";
      pgpKeyFingerprint = "D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6";
      outputHash = "b0e67ea74474939913c4d9d9ef4ef5ec378efbe2bebe36389dee319c79bffa92";
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
      i686-linux
      ++ x86_64-linux;
  };
}
