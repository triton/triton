{ stdenv
, fetchurl
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
    "--${if libOnly then "disable" else "enable"}-listener"
    "--${if libOnly then "disable" else "enable"}-zos-remote"
    "--${if libOnly then "disable" else "enable"}-gssapi-krb5"
    "--disable-systemd"
    "--without-debug"
    "--without-warn"
    "--without-alpha"  # TODO: Support
    "--without-arm"  # TODO: Support
    "--without-aarch64"  # TODO: Support
    "--${if libOnly then "without" else "with"}-apparmor"
    "--without-prelude"
  ];

  meta = with stdenv.lib; {
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
