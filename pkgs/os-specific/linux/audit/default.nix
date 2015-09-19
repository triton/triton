{ stdenv, fetchurl
, libcap_ng, swig

# Optional Dependencies
, openldap ? null, python ? null, python3 ? null, go ? null, libkrb5 ? null, tcp_wrappers ? null

# Extra arguments
, prefix ? ""
}:

with stdenv;
let
  libOnly = prefix == "lib";

  optOpenldap = if libOnly then null else shouldUsePkg openldap;
  optPython = if !libOnly then null else shouldUsePkg python;
  optPython3 = if !libOnly then null else shouldUsePkg python3;
  optGo = if !libOnly then null else shouldUsePkg go;
  optLibkrb5 = if libOnly then null else shouldUsePkg libkrb5;
  optTcp_wrappers = if libOnly then null else shouldUsePkg tcp_wrappers;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "${prefix}audit-${version}";
  version = "2.4.4";

  src = fetchurl {
    url = "http://people.redhat.com/sgrubb/audit/audit-${version}.tar.gz";
    sha256 = "08sfcx8ykcn5jsryil15q8yqm0a8czymyqbb2sqxfc1jbx37zx95";
  };

  nativeBuildInputs = [ optPython ] ++ optional (optPython3 != null) swig;
  buildInputs = [
    libcap_ng optOpenldap optPython optPython3 optGo optLibkrb5 optTcp_wrappers
  ];

  postPatch = ''
    # Get the absolute paths to the needed headers for swig
    echo -e '#include <stdint.h>\n#include <linux/audit.h>' | gcc -M -xc - \
      | tail -n +2 | awk "{print \"-e\ns,[^<\\\\\\\"]*/\"substr(\$1, match(\$1, \"include\"))\",\"\$1\",g\"}" \
      | xargs sed -i bindings/swig/src/auditswig.i
  '';

  configureFlags = [
    (mkWith   (optPython != null)       "python"      null)
    (mkWith   (optPython3 != null)      "python3"     null)
    (mkWith   (optGo != null)           "golang"      null)
    (mkEnable (!libOnly)                "listener"    null)
    (mkEnable (!libOnly)                "zos-remote"  null)
    (mkEnable (optLibkrb5 != null)      "gssapi-krb5" null)
    (mkEnable false                     "systemd"     null)
    (mkWith   false                     "debug"       null)
    (mkWith   false                     "warn"        null)
    (mkWith   false                     "alpha"       null)  # TODO: Support
    (mkWith   false                     "arm"         null)  # TODO: Support
    (mkWith   false                     "aarch64"     null)  # TODO: Support
    (mkWith   (!libOnly)                "apparmor"    null)
    (mkWith   false                     "prelude"     null)
    (mkWith   (optTcp_wrappers != null) "libwrap"     optTcp_wrappers)
  ];

  # For libs only build and install the lib portion
  buildPhase = optionalString libOnly ''
    pushd lib
    make
    popd

    pushd auparse
    make
    popd

    pushd bindings
    make
    popd
  '';

  installPhase = optionalString libOnly ''
    pushd lib
    make install
    popd

    pushd auparse
    make install
    popd

    pushd bindings
    make install
    popd
  '';

  meta = {
    description = "Audit Library";
    homepage = "http://people.redhat.com/sgrubb/audit/";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fuuzetsu wkennington ];
  };
}
