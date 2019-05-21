{ stdenv
, buildCargo
, lib
, rustc
}:

let
  target = rustc.targets."${stdenv.targetSystem}";
in
buildCargo {
  name = "proc-macro";

  inherit (rustc)
    src;

  preConfigure = ''
    cd src/libproc_macro
  '';

  preBuild = ''
    export RUSTC_BOOTSTRAP=1
  '';

  installPhase = ''
    mkdir -p "$dev"
    rm "$CARGO_TARGET_DIR"/'${target}'/release/deps/*.d
    mv "$CARGO_TARGET_DIR"/'${target}'/release/deps "$dev"/lib
    test -z "$(echo "$CARGO_TARGET_DIR"/'${target}'/release/deps/*.so)"
  '';

  outputs = [
    "dev"
  ];

  passthru = {
    inherit target;
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
