{ stdenv
, fetchurl

, cracklib
, libaudit
, db
}:

stdenv.mkDerivation rec {
  name = "pam-${version}";
  version = "1.2.1";

  src = fetchurl {
    url = "http://www.linux-pam.org/library/Linux-PAM-${version}.tar.bz2";
    sha256 = "1n9lnf9gjs72kbj1g354v1xhi2j27aqaah15vykh7cnkq08i4arl";
  };

  buildInputs = [
    cracklib
    db
    libaudit
  ];

  preConfigure = ''
    configureFlagsArray+=("--includedir=$out/include/security")
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-static-modules"
    "--enable-pie"
    "--disable-prelude"
    "--disable-debug"
    "--disable-pamlocking"
    "--enable-read-both-confs"
    "--enable-lckpwdf"
    "--with-xauth=/run/current-system/sw/bin/xauth"
    "--enable-cracklib"
    "--enable-audit"
    "--enable-db=db"
    "--enable-nis"
    "--disable-selinux"
    "--disable-regenerate-docu"
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

  meta = with stdenv.lib; {
    homepage = http://ftp.kernel.org/pub/linux/libs/pam/;
    description = "Pluggable Authentication Modules, a flexible mechanism for authenticating user";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
