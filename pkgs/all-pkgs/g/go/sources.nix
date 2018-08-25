{
  "1.9" = {
    version = "1.9.7";
    sha256 = "582814fa45e8ecb0859a208e517b48aa0ad951e3b36c7fff203d834e0ef27722";
    sha256Bootstrap = {
      "x86_64-linux" = "d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79";
    };
    patches = [
      {
        rev = "2426b84827f78c72ffcb9da51d34b889fcb8b056";
        file = "go/remove-tools.patch";
        sha256 = "647282e43513a6d0a71aa406f54a0b13d3331f825bc60fedebaa32d757f0e483";
      }
    ];
  };
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
}
