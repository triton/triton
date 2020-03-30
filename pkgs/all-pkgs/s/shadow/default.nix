{ stdenv
, fetchTritonPatch
, fetchurl

, acl
, attr
, audit_lib
, cracklib
, pam
}:

let
  version = "4.8.1";
in
stdenv.mkDerivation rec {
  name = "shadow-${version}";

  src = fetchurl {
    url = "https://github.com/shadow-maint/shadow/releases/download/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a3ad4630bdc41372f02a647278a8c3514844295d36eefe68ece6c3a641c1ae62";
  };

  buildInputs = [
    acl
    attr
    audit_lib
    cracklib
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

  postPatch = ''
    # setuid can't happen in a nixbuild
    grep -q '4755' src/Makefile.in
    sed -i 's,4755,0755,g' src/Makefile.in
  '';

  # Assume System V `setpgrp (void)', which is the default on GNU variants
  # (`AC_FUNC_SETPGRP' is not cross-compilation capable.)
  preConfigure = ''
    export ac_cv_func_setpgrp_void=yes
    export shadow_cv_logdir=/var/log
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-audit"
    "--with-libpam"
    "--with-acl"
    "--with-attr"
    "--with-libcrack"
  ];

  preBuild = ''
    grep -q '/usr/sbin/nscd' lib/nscd.c
    sed -i 's,/usr/sbin/nscd,/run/current-system/sw/bin/nscd,g' lib/nscd.c
    ! grep -r '/usr/sbin/ncsd' .
  '';

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Serge Hallyn
        "F1D0 8DB7 7818 5BF7 8400  2DFF E9FE EA06 A85E 3F9D"
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
