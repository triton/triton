{
  "3.8" = {
    version = "3.8.1";
    srcs = {
      cfe = {
        sha256 = "4cd3836dfb4b88b597e075341cae86d61c63ce3963e45c7fe6a8bf59bb382cdf";
      };
      clang-tools-extra = {
        sha256 = "664a5c60220de9c290bf2a5b03d902ab731a4f95fe73a00856175ead494ec396";
      };
      compiler-rt = {
        sha256 = "0df011dae14d8700499dfc961602ee0a9572fef926202ade5dcdfe7858411e5c";
      };
      libcxx = {
        sha256 = "77d7f3784c88096d785bd705fa1bab7031ce184cd91ba8a7008abf55264eeecc";
      };
      libcxxabi = {
        sha256 = "e1b55f7be3fad746bdd3025f43e42d429fb6194aac5919c2be17c4a06314dae1";
      };
      libunwind = {
        sha256 = "21e58ce09a5982255ecf86b86359179ddb0be4f8f284a95be14201df90e48453";
      };
      lld = {
        sha256 = "2bd9be8bb18d82f7f59e31ea33b4e58387dbdef0bc11d5c9fcd5ce9a4b16dc00";
      };
      lldb = {
        sha256 = "349148116a47e39dcb5d5042f10d8a6357d2c865034563283ca512f81cdce8a3";
      };
      llvm = {
        sha256 = "6e82ce4adb54ff3afc18053d6981b6aed1406751b8742582ed50f04b5ab475f9";
      };
      openmp = {
        sha256 = "68fcde6ef34e0275884a2de3450a31e931caf1d6fda8606ef14f89c4123617dc";
      };
      polly = {
        sha256 = "453c27e1581614bb3b6351bf5a2da2939563ea9d1de99c420f85ca8d87b928a2";
      };
    };
    patches = [
      {
        rev = "1a001778aab424ecd36774befa1f546b0004c5fc";
        file = "llvm/fix-llvm-config.patch";
        sha256 = "059655c0e6ea5dd248785ffc1b2e6402eeb66544ffe36ff15d76543dd7abb413";
      }
    ];
  };
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
}
