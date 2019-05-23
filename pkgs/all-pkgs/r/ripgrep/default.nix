{ stdenv
, buildCargo
, fetchCrate
, fetchCargoDeps
, rustc

, pcre2_lib
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

  features = [
    "pcre2"
  ];

  buildInputs = [
    pcre2_lib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
