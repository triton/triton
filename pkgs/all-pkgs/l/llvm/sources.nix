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
    version = "3.9.0-rc2";
    srcs = {
      cfe = {
        sha256 = "2d2d7aad5c7b67dd2bd324d0ce10435a797a85b04fa06e4944a6143dfefb4b89";
      };
      clang-tools-extra = {
        sha256 = "0d027a895b1f2036395aab470fdb94d4c49d75ed55ca4808cf981f29379f41a1";
      };
      compiler-rt = {
        sha256 = "6ff0db5660508c84d7107d5f34419ce83b885f5f34bc2f3b66f713694c3de723";
      };
      libcxx = {
        sha256 = "3bda7b35226efaa7616cfc3dd23f147c89a7b6565553e9fc9907d434aa013560";
      };
      libcxxabi = {
        sha256 = "bb7eaed3749744345f0a6dc006fd2d84573626973b72a02747e3393742a42f09";
      };
      libunwind = {
        sha256 = "40fe8f781c0e5f82a035f2f0d1398c0fe2dc35a844aedb90d71a39c61e33448e";
      };
      lld = {
        sha256 = "4524ada47c4d392cda9f3de3e7132aac9d704bc3ef613d5589059a1563b47c1e";
      };
      lldb = {
        sha256 = "b8e1a8ea68d1c34f8dcccdd827734f1032f702c44caf31238e3f37ab5d72a84f";
      };
      llvm = {
        sha256 = "d7516c9887f6a6ba0ac40fa394f0fd09a65e0b5721468fc85db8a13b47d1dc69";
      };
      openmp = {
        sha256 = "84db3e5bb11adb42ffd9c0d5c95b51b9e93093a792db35ddd4fc5e57fae0c17e";
      };
      polly = {
        sha256 = "6944fc6a445953c421cb020011cf45752794067c5c93153b7e16c4d5a7334ef8";
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
