{ lib
, buildCargo
, fetchCrate
, fetchFromGitHub
, fetchCargoDeps
, fetchTritonPatch

, openssl

, channel
}:

let
  channels = {
    stable = rec {
      version = "0.35.0";
      src = fetchCrate {
        package = "cargo";
        inherit version;
        sha256 = "801ebbedec420595b232cdf6395b2a1f7fb2360c7e59d5022766f64bc64ea387";
      };
      deps = fetchCargoDeps {
        zipVersion = 6;
        inherit src;
        crates-rev = "56071d1171fcf58219345225423dfa5bb90fc30c";
        crates-hash = "sha256:591574f7b761d12103727bfe03c1cfcfd800ac25498141603cd0bf54f74a76c0";
        hash = "sha256:0f38e26c74b39aec2553c9e44386255b94cae4461fad55039949a4ccd23cc902";
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
    openssl
  ];

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
