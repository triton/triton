{
  "10" = {
    version = "10.0.0";
    srcs = {
      clang = {
        sha256 = "885b062b00e903df72631c5f98b9579ed1ed2790f74e5646b4234fa084eacb21";
      };
      clang-tools-extra = {
        sha256 = "acdf8cf6574b40e6b1dabc93e76debb84a9feb6f22970126b04d4ba18b92911c";
      };
      compiler-rt = {
        sha256 = "6a7da64d3a0a7320577b68b9ca4933bdcab676e898b759850e827333c3282c75";
      };
      libcxx = {
        sha256 = "270f8a3f176f1981b0f6ab8aa556720988872ec2b48ed3b605d0ced8d09156c7";
      };
      libcxxabi = {
        sha256 = "e71bac75a88c9dde455ad3f2a2b449bf745eafd41d2d8432253b2964e0ca14e1";
      };
      libunwind = {
        sha256 = "09dc5ecc4714809ecf62908ae8fe8635ab476880455287036a2730966833c626";
      };
      lld = {
        sha256 = "b9a0d7c576eeef05bc06d6e954938a01c5396cee1d1e985891e0b1cf16e3d708";
      };
      lldb = {
        sha256 = "dd1ffcb42ed033f5167089ec4c6ebe84fbca1db4a9eaebf5c614af09d89eb135";
      };
      llvm = {
        sha256 = "df83a44b3a9a71029049ec101fb0077ecbbdf5fe41e395215025779099a98fdf";
      };
      openmp = {
        sha256 = "3b9ff29a45d0509a1e9667a0feb43538ef402ea8cfc7df3758a01f20df08adfa";
      };
      polly = {
        sha256 = "35fba6ed628896fe529be4c10407f1b1c8a7264d40c76bced212180e701b4d97";
      };
    };
    patches = [
      (../../../../../triton-patches/l/llvm/fix-llvm-config.patch)
    ];
  };
}
