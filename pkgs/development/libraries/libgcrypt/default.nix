{ stdenv, fetchurl
, libgpgerror

# Optional Dependencies
, libcap ? null, pth ? null
}:

with stdenv;
with stdenv.lib;
let
  optLibcap = shouldUsePkg libcap;
  #optPth = shouldUsePkg pth;
  optPth = null; # Broken as of 1.6.5
in
stdenv.mkDerivation rec {
  name = "libgcrypt-1.6.5";

  src = fetchurl {
    url = "mirror://gnupg/libgcrypt/${name}.tar.bz2";
    sha256 = "0959mwfzsxhallxdqlw359xg180ll2skxwyy35qawmfl89cbr7pl";
  };

  buildInputs = [ libgpgerror optLibcap optPth ];

  configureFlags = [
    (mkWith   (optLibcap != null) "capabilities"  null)
    (mkEnable (optPth != null)    "random-daemon" null)
  ];

  # Make sure includes are fixed for callers who don't use libgpgcrypt-config
  postInstall = ''
    sed -i 's,#include <gpg-error.h>,#include "${libgpgerror}/include/gpg-error.h",g' $out/include/gcrypt.h
  '';

  doCheck = true;

  meta = {
    homepage = https://www.gnu.org/software/libgcrypt/;
    description = "General-pupose cryptographic library";
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
    repositories.git = git://git.gnupg.org/libgcrypt.git;
  };
}
