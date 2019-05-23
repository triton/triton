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
      version = "0.36.0";
      src = fetchFromGitHub {
        version = 6;
        owner = "rust-lang";
        repo = "cargo";
        rev = version;
        sha256 = "a3c1cfb9d01367bc928f559596e9e8e8fc4e94cf57451d45ad392854416cae72";
      };
      deps = fetchCargoDeps {
        zipVersion = 6;
        inherit src;
        crates-rev = "7258c5460102c687b5fcb5e867c57870befa1e4d";
        crates-hash = "sha256:25d9e52d3b86281f83e0ac854fdd7288b654ac0ae4d0223506b185d79d785e00";
        hash = "sha256:77db96c3156dee63e00304f87536e3224f44f09d1bc3a18d10a076cbdee4fcf5";
      };
      patches = [
        (fetchTritonPatch {
          rev = "1f558f41670d021a17b85c4308a49d7f9f2ca77b";
          file = "c/cargo/stable/0001-cargo-Add-RUSTFLAGS-for-HOST-builds.patch";
          sha256 = "128683f906f1f9075907b49a2bcc286b4ed07c2725800e66f8a184a665b69e47";
        })
      ];
    };
    nightly = rec {
      version = "2019-05-03";
      src = fetchFromGitHub {
        version = 6;
        owner = "rust-lang";
        repo = "cargo";
        rev = "0f77ed5f615f61896a19fcc789a716fbca0d71be";
        sha256 = "07eba5bce846f1e2caed7f9714f87a08d88c9eb8aa7d21addb4d759d6d02a5b9";
      };
      deps = fetchCargoDeps {
        zipVersion = 6;
        inherit src;
        crates-rev = "759070689729519b07c213feef8461397112bc3f";
        crates-hash = "sha256:2fb232ce81d20feeaf126d41624df5422b250a580d83f62e9d48331afe06eb34";
        hash = "sha256:da4e512c104b0c9197d12f75fbfce43150845bde6ca76ce581ca2c9b93125429";
      };
      patches = [ ];
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
