{ stdenv
, buildCargo
, lib
, rustc
}:

let
  target = rustc.targets."${stdenv.targetSystem}";
in
buildCargo {
  name = "std";

  inherit (rustc)
    src;

  features = [
    "backtrace"
    "panic_unwind"
  ];

  preConfigure = ''
    cd src/libstd
  '';

  RUSTC_BOOTSTRAP = true;

  outputs = [
    "dev"
    "lib"
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
