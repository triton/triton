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
}
