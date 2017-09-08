{
  "4" = {
    version = "4.0.1";
    srcs = {
      cfe = {
        sha256 = "61738a735852c23c3bdbe52d035488cdb2083013f384d67c1ba36fabebd8769b";
      };
      clang-tools-extra = {
        sha256 = "35d1e64efc108076acbe7392566a52c35df9ec19778eb9eb12245fc7d8b915b6";
      };
      compiler-rt = {
        sha256 = "a3c87794334887b93b7a766c507244a7cdcce1d48b2e9249fc9a94f2c3beb440";
      };
      libcxx = {
        sha256 = "520a1171f272c9ff82f324d5d89accadcec9bc9f3c78de11f5575cdb99accc4c";
      };
      libcxxabi = {
        sha256 = "8f08178989a06c66cd19e771ff9d8ca526dd4a23d1382d63e416c04ea9fa1b33";
      };
      libunwind = {
        sha256 = "3b072e33b764b4f9b5172698e080886d1f4d606531ab227772a7fc08d6a92555";
      };
      lld = {
        sha256 = "63ce10e533276ca353941ce5ab5cc8e8dcd99dbdd9c4fa49f344a212f29d36ed";
      };
      lldb = {
        sha256 = "8432d2dfd86044a0fc21713e0b5c1d98e1d8aad863cf67562879f47f841ac47b";
      };
      llvm = {
        sha256 = "da783db1f82d516791179fe103c71706046561f7972b18f0049242dee6712b51";
      };
      openmp = {
        sha256 = "ec693b170e0600daa7b372240a06e66341ace790d89eaf4a843e8d56d5f4ada4";
      };
      polly = {
        sha256 = "b443bb9617d776a7d05970e5818aa49aa2adfb2670047be8e9f242f58e84f01a";
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
  "5" = {
    version = "5.0.0";
    srcs = {
      cfe = {
        sha256 = "019f23c2192df793ac746595e94a403908749f8e0c484b403476d2611dd20970";
      };
      clang-tools-extra = {
        sha256 = "87d078b959c4a6e5ff9fd137c2f477cadb1245f93812512996f73986a6d973c6";
      };
      compiler-rt = {
        sha256 = "d5ad5266462134a482b381f1f8115b6cad3473741b3bb7d1acc7f69fd0f0c0b3";
      };
      libcxx = {
        sha256 = "eae5981e9a21ef0decfcac80a1af584ddb064a32805f95a57c7c83a5eb28c9b1";
      };
      libcxxabi = {
        sha256 = "176918c7eb22245c3a5c56ef055e4d69f5345b4a98833e0e8cb1a19cab6b8911";
      };
      libunwind = {
        sha256 = "9a70e2333d54f97760623d89512c4831d6af29e78b77a33d824413ce98587f6f";
      };
      lld = {
        sha256 = "399a7920a5278d42c46a7bf7e4191820ec2301457a7d0d4fcc9a4ac05dd53897";
      };
      lldb = {
        sha256 = "c0a0ca32105e9881d86b7ca886220147e686edc97fdb9f3657c6659dc6568b7d";
      };
      llvm = {
        sha256 = "e35dcbae6084adcf4abb32514127c5eabd7d63b733852ccdb31e06f1373136da";
      };
      openmp = {
        sha256 = "c0ef081b05e0725a04e8711d9ecea2e90d6c3fbb1622845336d3d095d0a3f7c5";
      };
      polly = {
        sha256 = "44694254a2b105cec13ce0560f207e8552e6116c181b8d21bda728559cf67042";
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
