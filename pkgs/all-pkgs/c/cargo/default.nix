{ stdenv
, buildRustPackage
, cargo_bootstrap
, fetchCargo
}:

let
  version = "0.10.0";
in
buildRustPackage {
  name = "cargo-${version}";

  src = fetchCargo {
    package = "cargo";
    inherit version;
    sha256 = "02cc30ce96b2a4d6903f47bcc8a06e51daa90552bf570d3af94f798e8f2cc84f";
  };

  passthru = {
    bootstrap = cargo_bootstrap;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
