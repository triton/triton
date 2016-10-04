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
    version = "3.9.0";
    srcs = {
      cfe = {
        sha256 = "7596a7c7d9376d0c89e60028fe1ceb4d3e535e8ea8b89e0eb094e0dcb3183d28";
      };
      clang-tools-extra = {
        sha256 = "5b7aec46ec8e999ec683c87ad744082e1133781ee4b01905b4bdae5d20785f14";
      };
      compiler-rt = {
        sha256 = "e0e5224fcd5740b61e416c549dd3dcda92f10c524216c1edb5e979e42078a59a";
      };
      libcxx = {
        sha256 = "d0b38d51365c6322f5666a2a8105785f2e114430858de4c25a86b49f227f5b06";
      };
      libcxxabi = {
        sha256 = "b037a92717856882e05df57221e087d7d595a2ae9f170f7bc1a23ec7a92c8019";
      };
      libunwind = {
        sha256 = "66675ddec5ba0d36689757da6008cb2596ee1a9067f4f598d89ce5a3b43f4c2b";
      };
      # Currently disabled because it breaks the build
      # TODO: fix building lld
      #lld = {
      #  sha256 = "986e8150ec5f457469a20666628bf634a5ca992a53e157f3b69dbc35056b32d9";
      #};
      lldb = {
        sha256 = "61280e07411e3f2b4cca0067412b39c16b0a9edd19d304d3fc90249899d12384";
      };
      llvm = {
        sha256 = "66c73179da42cee1386371641241f79ded250e117a79f571bbd69e56daa48948";
      };
      openmp = {
        sha256 = "df88f90d7e5b5e9525a35fa2e2b93cbbb83c4882f91df494e87ee3ceddacac91";
      };
      polly = {
        sha256 = "ef0dd25010099baad84597cf150b543c84feac2574d055d6780463d5de8cd97e";
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
