{
  "3.9" = {
    version = "3.9.1";
    srcs = {
      cfe = {
        sha256 = "e6c4cebb96dee827fa0470af313dff265af391cb6da8d429842ef208c8f25e63";
      };
      clang-tools-extra = {
        sha256 = "29a5b65bdeff7767782d4427c7c64d54c3a8684bc6b217b74a70e575e4813635";
      };
      compiler-rt = {
        sha256 = "d30967b1a5fa51a2503474aacc913e69fd05ae862d37bf310088955bdb13ec99";
      };
      libcxx = {
        sha256 = "25e615e428f60e651ed09ffd79e563864e3f4bc69a9e93ee41505c419d1a7461";
      };
      libcxxabi = {
        sha256 = "920d8be32e6f5574a3fb293f93a31225eeba15086820fcb942155bf50dc029e2";
      };
      libunwind = {
        sha256 = "0b0bc73264d7ab77d384f8a7498729e3c4da8ffee00e1c85ad02a2f85e91f0e6";
      };
      # Currently disabled because it breaks the build
      # TODO: fix building lld
      #lld = {
      #  sha256 = "986e8150ec5f457469a20666628bf634a5ca992a53e157f3b69dbc35056b32d9";
      #};
      lldb = {
        sha256 = "7e3311b2a1f80f4d3426e09f9459d079cab4d698258667e50a46dccbaaa460fc";
      };
      llvm = {
        sha256 = "1fd90354b9cf19232e8f168faf2220e79be555df3aa743242700879e8fd329ee";
      };
      openmp = {
        sha256 = "d23b324e422c0d5f3d64bae5f550ff1132c37a070e43c7ca93991676c86c7766";
      };
      polly = {
        sha256 = "9ba5e61fc7bf8c7435f64e2629e0810c9b1d1b03aa5b5605b780d0e177b4cb46";
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
  "4.0" = {
    version = "4.0.0";
    srcs = {
      cfe = {
        sha256 = "cea5f88ebddb30e296ca89130c83b9d46c2d833685e2912303c828054c4dc98a";
      };
      clang-tools-extra = {
        sha256 = "41b7d37eb128fd362ab3431be5244cf50325bb3bb153895735c5bacede647c99";
      };
      compiler-rt = {
        sha256 = "d3f25b23bef24c305137e6b44f7e81c51bbec764c119e01512a9bd2330be3115";
      };
      libcxx = {
        sha256 = "4f4d33c4ad69bf9e360eebe6b29b7b19486948b1a41decf89d4adec12473cf96";
      };
      libcxxabi = {
        sha256 = "dca9cb619662ad2d3a0d685c4366078345247218c3702dd35bcaaa23f63481d8";
      };
      libunwind = {
        sha256 = "0755efa9f969373d4d543123bbed4b3f9a835f6302875c1379c5745857725973";
      };
      lld = {
        sha256 = "33e06457b9ce0563c89b11ccc7ccabf9cff71b83571985a5bf8684c9150e7502";
      };
      lldb = {
        sha256 = "2dbd8f05c662c1c9f11270fc9d0c63b419ddc988095e0ad107ed911cf882033d";
      };
      llvm = {
        sha256 = "8d10511df96e73b8ff9e7abbfb4d4d432edbdbe965f1f4f07afaf370b8a533be";
      };
      openmp = {
        sha256 = "db55d85a7bb289804dc42fc5c8e35ca24dfc3885782261b675a194fd7e206e26";
      };
      polly = {
        sha256 = "27a5dbf95e8aa9e0bbe3d6c5d1e83c92414d734357aa0d6c16020a65dc4dcd97";
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
