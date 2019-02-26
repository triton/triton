{
  "1.11" = {
    version = "1.11.6";
    sha256 = "a96da1425dcbec094736033a8a416316547f8100ab4b72c31d4824d761d3e133";
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
    version = "1.12.1";
    sha256 = "0be127684df4b842a64e58093154f9d15422f1405f1fcff4b2c36ffc6a15818a";
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
