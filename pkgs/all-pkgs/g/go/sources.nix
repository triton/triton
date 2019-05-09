{
  "1.12" = {
    version = "1.12.5";
    sha256 = "2aa5f088cbb332e73fc3def546800616b38d3bfe6b8713b8a6404060f22503e8";
    sha256Bootstrap = {
      "x86_64-linux" = "750a07fef8579ae4839458701f4df690e0b20b8bcce33b437e4df89c451b6f13";
    };
    patches = [
      {
        rev = "acec67beb6e4d812072b1ce84ebd667be48845d4";
        file = "g/go/0001-Get-TOOLDIR-from-the-environment.patch";
        sha256 = "72695d3dbe3ce401f8c69a3e433ebea7f5fb207a8d3ed1e8f65c58aea3906148";
      }
      {
        rev = "04f84dd74a9b337749b74795024be9cebbd262fc";
        file = "g/go/0001-cmd-internal-objabi-expand-trimpath-syntax.patch";
        sha256 = "6665db24b0280bc009b155c899bcb6e3d82349a64f4e96803e8a2263e4fc3dd8";
      }
      {
        rev = "04f84dd74a9b337749b74795024be9cebbd262fc";
        file = "g/go/0002-cmd-go-add-trimpath-build-flag.patch";
        sha256 = "c02ded43dd30a240ab44ca977131ddc8b2ccdc9704d3b3a7c82da64d8da02e24";
      }
    ];
  };
}
