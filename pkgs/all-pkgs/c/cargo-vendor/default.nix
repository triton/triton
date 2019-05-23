{ stdenv
, buildCargo
, fetchCrate
, fetchCargoDeps

, curl
, libgit2
, openssl
}:

let
  source = builtins.fromJSON (builtins.readFile ./source.json);

  inherit (source)
    package
    version;

  src = fetchCrate source;

  deps = fetchCargoDeps (builtins.fromJSON (builtins.readFile ./deps.json) // {
    inherit src;
  });
in
buildCargo {
  name = "${package}-${version}";

  inherit src;

  CARGO_DEPS = deps;

  buildInputs = [
    curl
    libgit2
    openssl
  ];

  LIBGIT2_SYS_USE_PKG_CONFIG = true;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
