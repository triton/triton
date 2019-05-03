{
  "7" = {
    version = "7.0.1";
    srcs = {
      cfe = {
        sha256 = "a45b62dde5d7d5fdcdfa876b0af92f164d434b06e9e89b5d0b1cbc65dfe3f418";
      };
      clang-tools-extra = {
        sha256 = "4c93c7d2bb07923a8b272da3ef7914438080aeb693725f4fc5c19cd0e2613bed";
      };
      compiler-rt = {
        sha256 = "782edfc119ee172f169c91dd79f2c964fb6b248bd9b73523149030ed505bbe18";
      };
      libcxx = {
        sha256 = "020002618b319dc2a8ba1f2cba88b8cc6a209005ed8ad29f9de0c562c6ebb9f1";
      };
      libcxxabi = {
        sha256 = "8168903a157ca7ab8423d3b974eaa497230b1564ceb57260be2bd14412e8ded8";
      };
      libunwind = {
        sha256 = "89c852991dfd9279dbca9d5ac10b53c67ad7d0f54bbab7156e9f057a978b5912";
      };
      lld = {
        sha256 = "8869aab2dd2d8e00d69943352d3166d159d7eae2615f66a684f4a0999fc74031";
      };
      lldb = {
        sha256 = "76b46be75b412a3d22f0d26279306ae7e274fe4d7988a2184c529c38a6a76982";
      };
      llvm = {
        sha256 = "a38dfc4db47102ec79dcc2aa61e93722c5f6f06f0a961073bd84b78fb949419b";
      };
      openmp = {
        sha256 = "bf16b78a678da67d68405214ec7ee59d86a15f599855806192a75dcfca9b0d0c";
      };
      polly = {
        sha256 = "1bf146842a09336b9c88d2d76c2d117484e5fad78786821718653d1a9d57fb71";
      };
    };
    patches = [
      {
        rev = "b178552fe5e7431bfa98025cb8e4fe2e4927bd69";
        file = "l/llvm/fix-llvm-config.patch";
        sha256 = "7cbe2b2d1127c0995cb1af5d7d758e1a9a600ee17045f3a3341a68726ba8f0e8";
      }
    ];
  };
  "8" = {
    version = "8.0.0";
    srcs = {
      cfe = {
        sha256 = "084c115aab0084e63b23eee8c233abb6739c399e29966eaeccfc6e088e0b736b";
      };
      clang-tools-extra = {
        sha256 = "4f00122be408a7482f2004bcf215720d2b88cf8dc78b824abb225da8ad359d4b";
      };
      compiler-rt = {
        sha256 = "b435c7474f459e71b2831f1a4e3f1d21203cb9c0172e94e9d9b69f50354f21b1";
      };
      libcxx = {
        sha256 = "c2902675e7c84324fb2c1e45489220f250ede016cc3117186785d9dc291f9de2";
      };
      libcxxabi = {
        sha256 = "c2d6de9629f7c072ac20ada776374e9e3168142f20a46cdb9d6df973922b07cd";
      };
      libunwind = {
        sha256 = "ff243a669c9cef2e2537e4f697d6fb47764ea91949016f2d643cb5d8286df660";
      };
      lld = {
        sha256 = "9caec8ec922e32ffa130f0fb08e4c5a242d7e68ce757631e425e9eba2e1a6e37";
      };
      lldb = {
        sha256 = "49918b9f09816554a20ac44c5f85a32dc0a7a00759b3259e78064d674eac0373";
      };
      llvm = {
        sha256 = "8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c";
      };
      openmp = {
        sha256 = "f7b1705d2f16c4fc23d6531f67d2dd6fb78a077dd346b02fed64f4b8df65c9d5";
      };
      polly = {
        sha256 = "e3f5a3d6794ef8233af302c45ceb464b74cdc369c1ac735b6b381b21e4d89df4";
      };
    };
    patches = [
      {
        rev = "b178552fe5e7431bfa98025cb8e4fe2e4927bd69";
        file = "l/llvm/fix-llvm-config.patch";
        sha256 = "7cbe2b2d1127c0995cb1af5d7d758e1a9a600ee17045f3a3341a68726ba8f0e8";
      }
    ];
  };
}
