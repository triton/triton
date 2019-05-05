{ stdenv
, buildRustPackage
, fetchCargo
}:

let
  version = "0.35.0";
in
buildRustPackage {
  name = "cargo-${version}";

  src = fetchCargo {
    version = 6;
    package = "cargo";
    packageVersion = version;
    sha256 = "1ak55xb89v8liar7aqa8f7074ic9h4bklfbx16qhhcbl9bjs8p2s";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
