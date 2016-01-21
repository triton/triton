{ stdenv, fetchurl, openssl, python, zlib, libuv, v8, utillinux, http-parser
, pkgconfig, runCommand, which, libtool
}:

let
  version = "5.4.1";

  deps = {
    inherit openssl zlib libuv;
  };

  sharedConfigureFlags = name: [
    "--shared-${name}"
    "--shared-${name}-includes=${builtins.getAttr name deps}/include"
    "--shared-${name}-libpath=${builtins.getAttr name deps}/lib"
  ];

  inherit (stdenv.lib) concatMap optional optionals maintainers licenses platforms;
in stdenv.mkDerivation {
  name = "nodejs-${version}";

  src = fetchurl {
    url = "http://nodejs.org/dist/v${version}/node-v${version}.tar.gz";
    sha256 = "032ylpjrnjpc4cjqkrax3slli40025kw74yk2dynp86ywgr5wibq";
  };

  configureFlags = concatMap sharedConfigureFlags (builtins.attrNames deps);

  dontDisableStatic = true;

  prePatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ python which ];
  buildInputs = stdenv.lib.attrValues deps;
  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  meta = {
    description = "Event-driven I/O framework for the V8 JavaScript engine";
    homepage = http://nodejs.org;
    license = licenses.mit;
    maintainers = [ maintainers.goibhniu maintainers.havvy ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
