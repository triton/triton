{ lib
, buildCargo
, fetchFromGitHub
, fetchCargoDeps
, fetchTritonPatch

, curl
, libgit2
, openssl

, channel
}:

let
  channels = {
    stable = rec {
      version = "2019-07-06";
      src = fetchFromGitHub {
        version = 6;
        owner = "rust-lang";
        repo = "cargo";
        rev = "644c8089f33baafe5dc8022ab7af8951291a7669";
        sha256 = "7c95a4ae0d91be1f0ec272520078871929d26251df3e2f4772967ec82c1dbf59";
      };
      deps = fetchCargoDeps {
        zipVersion = 6;
        inherit src;
        crates-rev = "53ed7d36910de8cc02c7b31d48cbca6907bfe745";
        crates-hash = "sha256:9bfdde0f096079238b4e19361217999ebea6d3f25730ad2bd5fde8723b5b4177";
        hash = "sha256:d633d466d47aa684c78f240d622e269197a1c83b87b7e4b53c13f74f17dfab70";
      };
      patches = [
        (fetchTritonPatch {
          rev = "f69f451a442f21443033342b2c04a7e5a9a07c86";
          file = "c/cargo/stable/0001-cargo-Add-RUSTFLAGS-for-HOST-builds.patch";
          sha256 = "25d6644aeefed1b7f19bb4d8043a6144317ce4db22c000c9bca5d8c93957b9c5";
        })
      ];
    };
    nightly = rec {
      version = "2019-07-06";
      src = fetchFromGitHub {
        version = 6;
        owner = "rust-lang";
        repo = "cargo";
        rev = "644c8089f33baafe5dc8022ab7af8951291a7669";
        sha256 = "7c95a4ae0d91be1f0ec272520078871929d26251df3e2f4772967ec82c1dbf59";
      };
      deps = fetchCargoDeps {
        zipVersion = 6;
        inherit src;
        crates-rev = "53ed7d36910de8cc02c7b31d48cbca6907bfe745";
        crates-hash = "sha256:9bfdde0f096079238b4e19361217999ebea6d3f25730ad2bd5fde8723b5b4177";
        hash = "sha256:d633d466d47aa684c78f240d622e269197a1c83b87b7e4b53c13f74f17dfab70";
      };
      patches = [
        (fetchTritonPatch {
          rev = "f69f451a442f21443033342b2c04a7e5a9a07c86";
          file = "c/cargo/stable/0001-cargo-Add-RUSTFLAGS-for-HOST-builds.patch";
          sha256 = "25d6644aeefed1b7f19bb4d8043a6144317ce4db22c000c9bca5d8c93957b9c5";
        })
      ];
    };
  };

  inherit (channels."${channel}")
    version
    src
    patches
    deps;
in
buildCargo {
  name = "cargo-${version}";

  inherit src patches;

  CARGO_DEPS = deps;

  buildInputs = [
    curl
    libgit2
    openssl
  ];

  LIBGIT2_SYS_USE_PKG_CONFIG = true;

  setupHook = ./setup-hook.sh;

  passthru = {
    inherit version;
    supportsHostFlags = true;
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
