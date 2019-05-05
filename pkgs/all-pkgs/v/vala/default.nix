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

  channel = "0.44";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "vala-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "8553b422484af88be1685d8b47f7b0df36ae4477c3e77e89ab22276ffed1eae9";
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
