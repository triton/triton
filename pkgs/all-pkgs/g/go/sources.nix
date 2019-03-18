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
}
