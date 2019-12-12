{
  "1.12" = {
    version = "1.12.14";
    sha256 = "39dbf05f7e2ffcb19b08f07d53dcc96feadeb1987fef9e279e7ff0c598213064";
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
  "1.13" = {
    version = "1.13";
    sha256 = "3fc0b8b6101d42efd7da1da3029c0a13f22079c0c37ef9730209d8ec665bf122";
    sha256Bootstrap = {
      "x86_64-linux" = "68a2297eb099d1a76097905a2ce334e3155004ec08cdea85f24527be3c48e856";
    };
    patches = [
      {
        rev = "acec67beb6e4d812072b1ce84ebd667be48845d4";
        file = "g/go/0001-Get-TOOLDIR-from-the-environment.patch";
        sha256 = "72695d3dbe3ce401f8c69a3e433ebea7f5fb207a8d3ed1e8f65c58aea3906148";
      }
    ];
  };
}
