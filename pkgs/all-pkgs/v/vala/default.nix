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
    "0.42" = {
      version = "0.42.2";
      sha256 = "9e89aa42152b1cef551568f827aa2deea2a9b5487d78c91474c8617b618e5f07";
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
