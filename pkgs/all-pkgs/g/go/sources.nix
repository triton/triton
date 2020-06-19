{
  "1.13" = {
    version = "1.13.11";
    sha256 = "89ed1abce25ad003521c125d6583c93c1280de200ad221f961085200a6c00679";
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
  "1.14" = {
    version = "1.14.3";
    sha256 = "93023778d4d1797b7bc6a53e86c3a9b150c923953225f8a48a2d5fabc971af56";
    sha256Bootstrap = {
      "x86_64-linux" = "08df79b46b0adf498ea9f320a0f23d6ec59e9003660b4c9c1ce8e5e2c6f823ca";
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
