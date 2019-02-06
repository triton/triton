{ stdenv
, bison
, fetchurl
, flex
, lib

, glib
, graphviz
}:

let
  inherit (lib)
    optionalString;

  channel = "0.42";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "vala-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "8c33b4abc0573d364781bbfe54a1668ed34956902e471191a31cf05dc87c6e12";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    glib
    graphviz
  ];

  setupHook = ./setup-hook.sh;

  postPatch = optionalString (doCheck) ''
    patchShebangs tests/testrunner.sh
    patchShebangs valadoc/tests/testrunner.sh

    # We can't run dbus tests
    grep -q 'dbus-run-session' tests/testrunner.sh
    sed -i 's,dbus-run-session,true,' tests/testrunner.sh
  '';

  configureFlags = [
    "--enable-unversioned"
  ];

  # Currently tests are broken
  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/vala/${channel}/"
          + "${name}.sha256sum";
      };
    };
  };

  meta = with lib; {
    description = "Compiler for GObject type system";
    homepage = http://live.gnome.org/Vala;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
