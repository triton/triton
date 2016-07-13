{
  version = "3.8.1";

  srcs = {
    cfe = {
      sha256 = "4cd3836dfb4b88b597e075341cae86d61c63ce3963e45c7fe6a8bf59bb382cdf";
    };
    clang-tools-extra = {
      version = "3.8.0";
      sha256 = "1i0yrgj8qrzjjswraz0i55lg92ljpqhvjr619d268vka208aigdg";
    };
    compiler-rt = {
      version = "3.8.0";
      sha256 = "1c2nkp9563873ffz22qmhc0wakgj428pch8rmhym8agjamz3ily8";
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
}
