{
  "4" = {
    version = "4.0.1";
    srcs = {
      cfe = {
        sha256 = "61738a735852c23c3bdbe52d035488cdb2083013f384d67c1ba36fabebd8769b";
      };
      clang-tools-extra = {
        sha256 = "35d1e64efc108076acbe7392566a52c35df9ec19778eb9eb12245fc7d8b915b6";
      };
      compiler-rt = {
        sha256 = "a3c87794334887b93b7a766c507244a7cdcce1d48b2e9249fc9a94f2c3beb440";
      };
      libcxx = {
        sha256 = "520a1171f272c9ff82f324d5d89accadcec9bc9f3c78de11f5575cdb99accc4c";
      };
      libcxxabi = {
        sha256 = "8f08178989a06c66cd19e771ff9d8ca526dd4a23d1382d63e416c04ea9fa1b33";
      };
      libunwind = {
        sha256 = "3b072e33b764b4f9b5172698e080886d1f4d606531ab227772a7fc08d6a92555";
      };
      lld = {
        sha256 = "63ce10e533276ca353941ce5ab5cc8e8dcd99dbdd9c4fa49f344a212f29d36ed";
      };
      lldb = {
        sha256 = "8432d2dfd86044a0fc21713e0b5c1d98e1d8aad863cf67562879f47f841ac47b";
      };
      llvm = {
        sha256 = "da783db1f82d516791179fe103c71706046561f7972b18f0049242dee6712b51";
      };
      openmp = {
        sha256 = "ec693b170e0600daa7b372240a06e66341ace790d89eaf4a843e8d56d5f4ada4";
      };
      polly = {
        sha256 = "b443bb9617d776a7d05970e5818aa49aa2adfb2670047be8e9f242f58e84f01a";
      };
    };
    patches = [
      {
        rev = "9bbc7b11d649bbb0c5d8112cdd9a4eb5e437c76d";
        file = "l/llvm/fix-llvm-config.patch";
        sha256 = "45e71e71de3a8e2f41516832f5044e7226b35a273d25afac076e14fc3ae46036";
      }
    ];
  };
  "5" = {
    version = "5.0.1";
    srcs = {
      cfe = {
        sha256 = "135f6c9b0cd2da1aff2250e065946258eb699777888df39ca5a5b4fe5e23d0ff";
      };
      clang-tools-extra = {
        sha256 = "9aada1f9d673226846c3399d13fab6bba4bfd38bcfe8def5ee7b0ec24f8cd225";
      };
      compiler-rt = {
        sha256 = "4edd1417f457a9b3f0eb88082530490edf3cf6a7335cdce8ecbc5d3e16a895da";
      };
      libcxx = {
        sha256 = "fa8f99dd2bde109daa3276d529851a3bce5718d46ce1c5d0806f46caa3e57c00";
      };
      libcxxabi = {
        sha256 = "5a25152cb7f21e3c223ad36a1022faeb8a5ac27c9e75936a5ae2d3ac48f6e854";
      };
      libunwind = {
        sha256 = "6bbfbf6679435b858bd74bdf080386d084a76dfbf233fb6e47b2c28e0872d0fe";
      };
      lld = {
        sha256 = "d5b36c0005824f07ab093616bdff247f3da817cae2c51371e1d1473af717d895";
      };
      lldb = {
        sha256 = "b7c1c9e67975ca219089a3a6a9c77c2d102cead2dc38264f2524aa3326da376a";
      };
      llvm = {
        sha256 = "5fa7489fc0225b11821cab0362f5813a05f2bcf2533e8a4ea9c9c860168807b0";
      };
      openmp = {
        sha256 = "adb635cdd2f9f828351b1e13d892480c657fb12500e69c70e007bddf0fca2653";
      };
      polly = {
        sha256 = "9dd52b17c07054aa8998fc6667d41ae921430ef63fa20ae130037136fdacf36e";
      };
    };
    patches = [
      {
        rev = "9bbc7b11d649bbb0c5d8112cdd9a4eb5e437c76d";
        file = "l/llvm/fix-llvm-config.patch";
        sha256 = "45e71e71de3a8e2f41516832f5044e7226b35a273d25afac076e14fc3ae46036";
      }
    ];
  };
}
