{ stdenv
, fetchurl
, lib

, audit_lib
, cracklib
, db
, libtirpc
}:

let
  version = "1.3.1";
in
stdenv.mkDerivation rec {
  name = "pam-${version}";

  src = fetchurl {
    url = "https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1.tar.xz";
    hashOutput = false;
    sha256 = "eff47a4ecd833fbf18de9686632a70ee8d0794b79aecb217ebd0ce11db4cd0db";
  };

  buildInputs = [
    audit_lib
    cracklib
    db
    libtirpc
  ];

  preConfigure = ''
    configureFlagsArray+=("--includedir=$out/include/security")
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-prelude"
    "--enable-read-both-confs"
    "--disable-selinux"
    "--disable-regenerate-docu"
    "--with-xauth=/run/current-system/sw/bin/xauth"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "SCONFIGDIR=$out/etc/security"
    )
  '';

  postInstall = ''
    # Prepare unix_chkpwd for setuid wrapping
    mv -v $out/sbin/unix_chkpwd{,.orig}
    ln -sv /var/setuid-wrappers/unix_chkpwd $out/sbin/unix_chkpwd
  '';

  meta = with lib; {
    homepage = http://ftp.kernel.org/pub/linux/libs/pam/;
    description = "Pluggable Authentication Modules, a flexible mechanism for authenticating user";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
