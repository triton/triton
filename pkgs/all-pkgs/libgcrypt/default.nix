{ stdenv
, fetchurl
, libgpg-error
, libcap
, pth
}:

stdenv.mkDerivation rec {
  name = "libgcrypt-1.6.5";

  src = fetchurl {
    url = "mirror://gnupg/libgcrypt/${name}.tar.bz2";
    sha256 = "0959mwfzsxhallxdqlw359xg180ll2skxwyy35qawmfl89cbr7pl";
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
