{ stdenv, fetchTritonPatch, fetchurl, pam }:

stdenv.mkDerivation rec {
  name = "shadow-4.2.1";

  src = fetchurl {
    url = "http://pkg-shadow.alioth.debian.org/releases/${name}.tar.xz";
    sha256 = "0h9x1zdbq0pqmygmc1x459jraiqw4gqz8849v268crk78z8r621v";
  };

  buildInputs = [
    pam
  ];

  patches = [
    ./keep-path.patch
    (fetchTritonPatch {
      rev = "b3c3a622bd5f15c2e2d8087534e8ebe1790cb264";
      file = "s/shadow/shadow-4.1.3-dots-in-usernames.patch";
      sha256 = "2299ffaec204d20e00d791bf5b982571c9261a74c7a7b865a9f7cad1cdcb43ba";
    })
  ];

  # Assume System V `setpgrp (void)', which is the default on GNU variants
  # (`AC_FUNC_SETPGRP' is not cross-compilation capable.)
  preConfigure = ''
    export ac_cv_func_setpgrp_void=yes
    export shadow_cv_logdir=/var/log
  '';

  preBuild = ''
    substituteInPlace lib/nscd.c --replace /usr/sbin/nscd /run/current-system/sw/bin/nscd
  '';

  meta = with stdenv.lib; {
    homepage = http://pkg-shadow.alioth.debian.org/;
    description = "Suite containing authentication-related tools such as passwd and su";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
