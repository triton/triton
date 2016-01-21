{ stdenv, fetchurl, openssl, python, zlib, libuv, v8, utillinux, http-parser
, pkgconfig, runCommand, which, libtool
}:

let
  version = "5.5.0";

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
    sha256 = "0cmlk13skwag9gn1198h0ql64rv1jwwqbysq911kb6k94361i6yn";
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
