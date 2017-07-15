{
  "3.9" = {
    version = "3.9.1";
    srcs = {
      cfe = {
        sha256 = "e6c4cebb96dee827fa0470af313dff265af391cb6da8d429842ef208c8f25e63";
      };
      clang-tools-extra = {
        sha256 = "29a5b65bdeff7767782d4427c7c64d54c3a8684bc6b217b74a70e575e4813635";
      };
      compiler-rt = {
        sha256 = "d30967b1a5fa51a2503474aacc913e69fd05ae862d37bf310088955bdb13ec99";
      };
      libcxx = {
        sha256 = "25e615e428f60e651ed09ffd79e563864e3f4bc69a9e93ee41505c419d1a7461";
      };
      libcxxabi = {
        sha256 = "920d8be32e6f5574a3fb293f93a31225eeba15086820fcb942155bf50dc029e2";
      };
      libunwind = {
        sha256 = "0b0bc73264d7ab77d384f8a7498729e3c4da8ffee00e1c85ad02a2f85e91f0e6";
      };
      # Currently disabled because it breaks the build
      # TODO: fix building lld
      #lld = {
      #  sha256 = "986e8150ec5f457469a20666628bf634a5ca992a53e157f3b69dbc35056b32d9";
      #};
      lldb = {
        sha256 = "7e3311b2a1f80f4d3426e09f9459d079cab4d698258667e50a46dccbaaa460fc";
      };
      llvm = {
        sha256 = "1fd90354b9cf19232e8f168faf2220e79be555df3aa743242700879e8fd329ee";
      };
      openmp = {
        sha256 = "d23b324e422c0d5f3d64bae5f550ff1132c37a070e43c7ca93991676c86c7766";
      };
      polly = {
        sha256 = "9ba5e61fc7bf8c7435f64e2629e0810c9b1d1b03aa5b5605b780d0e177b4cb46";
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
  "4.0" = {
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
}
