{
  "1.9" = {
    version = "1.9.3";
    sha256 = "4e3d0ad6e91e02efa77d54e86c8b9e34fbe1cbc2935b6d38784dca93331c47ae";
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
}
