{
  "1.7" = {
    version = "1.7.5";
    sha256 = "4e834513a2079f8cbbd357502cccaac9507fd00a1efe672375798858ff291815";
    sha256Bootstrap = {
      "x86_64-linux" = "702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95";
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
