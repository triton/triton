{
  "6" = {
    version = "6.0.0";
    srcs = {
      cfe = {
        sha256 = "e07d6dd8d9ef196cfc8e8bb131cbd6a2ed0b1caf1715f9d05b0f0eeaddb6df32";
      };
      clang-tools-extra = {
        sha256 = "053b424a4cd34c9335d8918734dd802a8da612d13a26bbb88fcdf524b2d989d2";
      };
      compiler-rt = {
        sha256 = "d0cc1342cf57e9a8d52f5498da47a3b28d24ac0d39cbc92308781b3ee0cea79a";
      };
      libcxx = {
        sha256 = "70931a87bde9d358af6cb7869e7535ec6b015f7e6df64def6d2ecdd954040dd9";
      };
      libcxxabi = {
        sha256 = "91c6d9c5426306ce28d0627d6a4448e7d164d6a3f64b01cb1d196003b16d641b";
      };
      libunwind = {
        sha256 = "256c4ed971191bde42208386c8d39e5143fa4afd098e03bd2c140c878c63f1d6";
      };
      lld = {
        sha256 = "6b8c4a833cf30230c0213d78dbac01af21387b298225de90ab56032ca79c0e0b";
      };
      lldb = {
        sha256 = "46f54c1d7adcd047d87c0179f7b6fa751614f339f4f87e60abceaa45f414d454";
      };
      llvm = {
        sha256 = "1ff53c915b4e761ef400b803f07261ade637b0c269d99569f18040f3dcee4408";
      };
      openmp = {
        sha256 = "7c0e050d5f7da3b057579fb3ea79ed7dc657c765011b402eb5bbe5663a7c38fc";
      };
      polly = {
        sha256 = "47e493a799dca35bc68ca2ceaeed27c5ca09b12241f87f7220b5f5882194f59c";
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
