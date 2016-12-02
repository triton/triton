{
  "1.7" = {
    version = "1.7.4";
    sha256 = "4c189111e9ba651a2bb3ee868aa881fab36b2f2da3409e80885ca758a6b614cc";
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
