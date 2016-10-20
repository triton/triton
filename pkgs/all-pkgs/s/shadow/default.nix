{ stdenv
, fetchTritonPatch
, fetchurl

, pam
}:

stdenv.mkDerivation rec {
  name = "shadow-4.2.1";

  src = fetchurl {
    url = "https://pkg-shadow.alioth.debian.org/releases/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmUM7xPj9MBJzNdNw2GNHtSJGa8j4wYy7z6qs3TfoLPZbY";
    sha256 = "0h9x1zdbq0pqmygmc1x459jraiqw4gqz8849v268crk78z8r621v";
  };

  buildInputs = [
    pam
  ];

  patches = [
    (fetchTritonPatch {
      rev = "e066c817c4de8c25414ca542ed0f991cb984ac60";
      file = "s/shadow/keep-path.patch";
      sha256 = "2b5a2bd74604be46b02237687e9b8930c866275225ff1f691928f50182060d9b";
    })
    (fetchTritonPatch {
      rev = "e066c817c4de8c25414ca542ed0f991cb984ac60";
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
    grep -r '/usr/sbin/nscd' .
    substituteInPlace lib/nscd.c --replace /usr/sbin/nscd /run/current-system/sw/bin/nscd
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        "96F7 A8CC A87F 0EB8 3497 01B2 5A0A 399A EA7C F5AD"
        "F972 A168 A270 3B34 CC23 E09F D4E5 EDAC C014 3D2D"
        "D5C2 F9BF CA12 8BBA 22A7 7218 872F 702C 4D6E 25A8"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
