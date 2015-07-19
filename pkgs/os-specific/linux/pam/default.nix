{ stdenv, fetchurl, pkgconfig

# Optional Depdencies
, cracklib ? null, libaudit ? null, db ? null
}:

with stdenv;
let
  optCracklib = shouldUsePkg cracklib;
  optLibaudit = shouldUsePkg libaudit;
  optDb = shouldUsePkg db;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "linux-pam-${version}";
  version = "1.2.1";

  src = fetchurl {
    url = "http://www.linux-pam.org/library/Linux-PAM-${version}.tar.bz2";
    sha256 = "1n9lnf9gjs72kbj1g354v1xhi2j27aqaah15vykh7cnkq08i4arl";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ optCracklib optLibaudit optDb ];

  configureFlags = [
    (mkOther                        "sysconfdir"      "/etc")
    (mkOther                        "localstatedir"   "/var")
    (mkOther                        "includedir"   "\${out}/include/security")
    (mkEnable false                 "static-modules"  null)
    (mkEnable true                  "pie"             null)
    (mkEnable false                 "prelude"         null)
    (mkEnable false                 "debug"           null)
    (mkEnable false                 "pamlocking"      null)
    (mkEnable true                  "read-both-confs" null)
    (mkEnable true                  "lckpwdf"         null)
    (mkWith   true                  "xauth"           "/run/current-system/sw/bin/xauth")
    (mkEnable (optCracklib != null) "cracklib"        null)
    (mkEnable (optLibaudit != null) "audit"           null)
    (mkEnable (optDb != null)       "db"              "db")
    (mkEnable true                  "nis"             null)  # TODO: Consider tirpc support here
    (mkEnable false                 "selinux"         null)
    (mkEnable false                 "regenerate-docu" null)
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "SCONFIGDIR=\${out}/etc/security"
  ];

  postInstall = ''
    # Prepare unix_chkpwd for setuid wrapping
    mv -v $out/sbin/unix_chkpwd{,.orig}
    ln -sv /var/setuid-wrappers/unix_chkpwd $out/sbin/unix_chkpwd
  '';

  meta = {
    homepage = http://ftp.kernel.org/pub/linux/libs/pam/;
    description = "Pluggable Authentication Modules, a flexible mechanism for authenticating user";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
  };
}
