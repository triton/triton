{
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
