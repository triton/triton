{
  "6" = {
    version = "6.0.1";
    srcs = {
      cfe = {
        sha256 = "7c243f1485bddfdfedada3cd402ff4792ea82362ff91fbdac2dae67c6026b667";
      };
      clang-tools-extra = {
        sha256 = "0d2e3727786437574835b75135f9e36f861932a958d8547ced7e13ebdda115f1";
      };
      compiler-rt = {
        sha256 = "f4cd1e15e7d5cb708f9931d4844524e4904867240c306b06a4287b22ac1c99b9";
      };
      libcxx = {
        sha256 = "7654fbc810a03860e6f01a54c2297a0b9efb04c0b9aa0409251d9bdb3726fc67";
      };
      libcxxabi = {
        sha256 = "209f2ec244a8945c891f722e9eda7c54a5a7048401abd62c62199f3064db385f";
      };
      libunwind = {
        sha256 = "a8186c76a16298a0b7b051004d0162032b9b111b857fbd939d71b0930fd91b96";
      };
      lld = {
        sha256 = "e706745806921cea5c45700e13ebe16d834b5e3c0b7ad83bf6da1f28b0634e11";
      };
      lldb = {
        sha256 = "6b8573841f2f7b60ffab9715c55dceff4f2a44e5a6d590ac189d20e8e7472714";
      };
      llvm = {
        sha256 = "b6d6c324f9c71494c0ccaf3dac1f16236d970002b42bb24a6c9e1634f7d0f4e2";
      };
      openmp = {
        sha256 = "66afca2b308351b180136cf899a3b22865af1a775efaf74dc8a10c96d4721c5a";
      };
      polly = {
        sha256 = "e7765fdf6c8c102b9996dbb46e8b3abc41396032ae2315550610cf5a1ecf4ecc";
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
