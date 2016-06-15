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

  version = "1.7.1";
in
stdenv.mkDerivation rec {
  name = "libgcrypt-${version}";

  src = fetchurl {
    url = tarballUrls version;
    allowHashOutput = false;
    sha256 = "450d9cfcbf1611c64dbe3bd04b627b83379ef89f11406d94c8bba305e36d7a95";
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
      urls = tarballUrls "1.7.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6";
      outputHash = "450d9cfcbf1611c64dbe3bd04b627b83379ef89f11406d94c8bba305e36d7a95";
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
