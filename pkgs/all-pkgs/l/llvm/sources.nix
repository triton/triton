{
  "8" = {
    version = "8.0.1";
    srcs = {
      cfe = {
        sha256 = "70effd69f7a8ab249f66b0a68aba8b08af52aa2ab710dfb8a0fba102685b1646";
      };
      clang-tools-extra = {
        sha256 = "187179b617e4f07bb605cc215da0527e64990b4a7dd5cbcc452a16b64e02c3e1";
      };
      compiler-rt = {
        sha256 = "11828fb4823387d820c6715b25f6b2405e60837d12a7469e7a8882911c721837";
      };
      libcxx = {
        sha256 = "7f0652c86a0307a250b5741ab6e82bb10766fb6f2b5a5602a63f30337e629b78";
      };
      libcxxabi = {
        sha256 = "b75bf3c8dc506e7d950d877eefc8b6120a4651aaa110f5805308861f2cfaf6ef";
      };
      libunwind = {
        sha256 = "1870161dda3172c63e632c1f60624564e1eb0f9233cfa8f040748ca5ff630f6e";
      };
      lld = {
        sha256 = "9fba1e94249bd7913e8a6c3aadcb308b76c8c3d83c5ce36c99c3f34d73873d88";
      };
      lldb = {
        sha256 = "e8a79baa6d11dd0650ab4a1b479f699dfad82af627cbbcd49fa6f2dc14e131d7";
      };
      llvm = {
        sha256 = "44787a6d02f7140f145e2250d56c9f849334e11f9ae379827510ed72f12b75e7";
      };
      openmp = {
        sha256 = "3e85dd3cad41117b7c89a41de72f2e6aa756ea7b4ef63bb10dcddf8561a7722c";
      };
      polly = {
        sha256 = "e8a1f7e8af238b32ce39ab5de1f3317a2e3f7d71a8b1b8bbacbd481ac76fd2d1";
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
