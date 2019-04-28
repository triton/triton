{
  "1.11" = {
    version = "1.11.9";
    sha256 = "ee80684b352f8d6b49d804d4e615f015ae92da41c4096cfee89ed4783b2498e3";
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
  "1.12" = {
    version = "1.12.4";
    sha256 = "4affc3e610cd8182c47abbc5b0c0e4e3c6a2b945b55aaa2ba952964ad9df1467";
    sha256Bootstrap = {
      "x86_64-linux" = "750a07fef8579ae4839458701f4df690e0b20b8bcce33b437e4df89c451b6f13";
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
