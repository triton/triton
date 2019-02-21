{ stdenv
, fetchurl
, lib
, swig

, audit_lib
, libcap-ng
, krb5_lib
, openldap
, python2
, python3
, tcp-wrappers
}:

let
  inherit (audit_lib)
    src
    version;
in
stdenv.mkDerivation rec {
  name = "audit-${version}";

  inherit src;

  nativeBuildInputs = [
    swig
  ];

  buildInputs = [
    libcap-ng
    krb5_lib
    python2
    python3
    tcp-wrappers
    openldap
  ];

  configureFlags = [
    "--with-python"
    "--with-python3"
    "--without-golang"
    "--enable-listener"
    "--enable-zos-remote"
    "--enable-gssapi-krb5"
    "--disable-systemd"
    "--without-debug"
    "--without-warn"
    "--without-alpha"  # TODO: Support
    "--without-arm"  # TODO: Support
    "--without-aarch64"  # TODO: Support
    "--enable-apparmor"
    "--without-prelude"
  ];

  meta = with lib; {
    description = "Audit Library";
    homepage = "http://people.redhat.com/sgrubb/audit/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
