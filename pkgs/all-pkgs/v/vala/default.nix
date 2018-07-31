{ stdenv
, bison
, fetchurl
, flex
, lib

, glib
, graphviz

, channel
}:

let
  inherit (lib)
    optionalString;

  sources = {
    "0.40" = {
      version = "0.40.8";
      sha256 = "5c35e087a7054e9f0a514a0c1f1d0a0d7cf68d3e43c1dbeb840f9b0d815c0fa5";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "vala-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    "--disable-maintainer-mode"
    "--enable-unversioned"
  ];

  # Currently tests are broken
  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/vala/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
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
