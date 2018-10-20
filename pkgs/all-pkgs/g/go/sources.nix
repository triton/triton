{
  "1.10" = {
    version = "1.10.4";
    sha256 = "6fe44965ed453cd968a81988523e9b0e794d3a478f91fd7983c28763d52d5781";
    sha256Bootstrap = {
      "x86_64-linux" = "b5a64335f1490277b585832d1f6c7f8c6c11206cba5cd3f771dcb87b98ad1a33";
    };
    patches = [
      {
        rev = "2426b84827f78c72ffcb9da51d34b889fcb8b056";
        file = "go/remove-tools.patch";
        sha256 = "647282e43513a6d0a71aa406f54a0b13d3331f825bc60fedebaa32d757f0e483";
      }
    ];
  };
  "1.11" = {
    version = "1.11.1";
    sha256 = "558f8c169ae215e25b81421596e8de7572bd3ba824b79add22fba6e284db1117";
    sha256Bootstrap = {
      "x86_64-linux" = "b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499";
    };
    patches = [
     {
      rev = "6f6346b3c5e45e7c9a7491c367c38da65acf34b0";
      file = "g/go/remove-tools.patch";
      sha256 = "829b51c2dd99ae3310e69df095fda7e0fcf578ff678c8ceb819f9e962cf6aa06";
    }
    ];
  };
}
