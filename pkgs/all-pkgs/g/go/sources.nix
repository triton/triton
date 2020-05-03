{
  "1.13" = {
    version = "1.13.10";
    sha256 = "eb9ccc8bf59ed068e7eff73e154e4f5ee7eec0a47a610fb864e3332a2fdc8b8c";
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
    version = "1.14.2";
    sha256 = "98de84e69726a66da7b4e58eac41b99cbe274d7e8906eeb8a5b7eb0aadee7f7c";
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
