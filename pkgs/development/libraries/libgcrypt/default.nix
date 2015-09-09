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
  optPth = null; # Broken as of 1.6.3
in
stdenv.mkDerivation rec {
  name = "libgcrypt-1.6.4";

  src = fetchurl {
    url = "mirror://gnupg/libgcrypt/${name}.tar.bz2";
    sha256 = "09k06gs27gxfha07sa9rpf4xh6mvphj9sky7n09ymx75w9zjrg69";
  };

  buildInputs = [ libgpgerror optLibcap optPth ];

  configureFlags = [
    (mkWith   (optLibcap != null) "capabilities"  null)
    (mkEnable (optPth != null)    "random-daemon" null)
  ];

  # Make sure libraries are correct for .pc and .la files
  # Also make sure includes are fixed for callers who don't use libgpgcrypt-config
  postInstall = ''
    sed -i 's,#include <gpg-error.h>,#include "${libgpgerror}/include/gpg-error.h",g' $out/include/gcrypt.h
  '' + optionalString (!stdenv.isDarwin && optLibcap != null) ''
    sed -i 's,\(-lcap\),-L${optLibcap}/lib \1,' $out/lib/libgcrypt.la
  '';

  # TODO: figure out why this is even necessary and why the missing dylib only crashes
  # random instead of every test
  preCheck = stdenv.lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/lib
    cp src/.libs/libgcrypt.20.dylib $out/lib
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
