{
  "7" = {
    version = "7.0.0";
    srcs = {
      cfe = {
        sha256 = "550212711c752697d2f82c648714a7221b1207fd9441543ff4aa9e3be45bba55";
      };
      clang-tools-extra = {
        sha256 = "937c5a8c8c43bc185e4805144744799e524059cac877a44d9063926cd7a19dbe";
      };
      compiler-rt = {
        sha256 = "bdec7fe3cf2c85f55656c07dfb0bd93ae46f2b3dd8f33ff3ad6e7586f4c670d6";
      };
      libcxx = {
        sha256 = "9b342625ba2f4e65b52764ab2061e116c0337db2179c6bce7f9a0d70c52134f0";
      };
      libcxxabi = {
        sha256 = "9b45c759ff397512eae4d938ff82827b1bd7ccba49920777e5b5e460baeb245f";
      };
      libunwind = {
        sha256 = "50aee87717421e70450f1e093c6cd9a27f2b111025e1e08d64d5ace36e338a9c";
      };
      lld = {
        sha256 = "fbcf47c5e543f4cdac6bb9bbbc6327ff24217cd7eafc5571549ad6d237287f9c";
      };
      lldb = {
        sha256 = "7ff6d8fee49977d25b3b69be7d22937b92592c7609cf283ed0dcf9e5cd80aa32";
      };
      llvm = {
        sha256 = "8bc1f844e6cbde1b652c19c1edebc1864456fd9c78b8c1bea038e51b363fe222";
      };
      openmp = {
        sha256 = "30662b632f5556c59ee9215c1309f61de50b3ea8e89dcc28ba9a9494bba238ff";
      };
      polly = {
        sha256 = "919810d3249f4ae79d084746b9527367df18412f30fe039addbf941861c8534b";
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
        rev = "b178552fe5e7431bfa98025cb8e4fe2e4927bd69";
        file = "l/llvm/fix-llvm-config.patch";
        sha256 = "7cbe2b2d1127c0995cb1af5d7d758e1a9a600ee17045f3a3341a68726ba8f0e8";
      }
    ];
  };
}
