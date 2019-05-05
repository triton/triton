{ stdenv
, buildCargo
, fetchCargo
, fetchCargoDeps
, rustc
}:

let
  source = builtins.fromJSON (builtins.readFile ./source.json);

  inherit (source)
    package
    version;

  src = fetchCargo source;

  deps = fetchCargoDeps (builtins.fromJSON (builtins.readFile ./deps.json) // {
    inherit src;
  });
in
buildCargo {
  name = "${package}-${version}";

  inherit src;

  CARGO_DEPS = deps;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
