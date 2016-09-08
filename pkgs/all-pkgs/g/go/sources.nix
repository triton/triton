{
  "1.6" = {
    version = "1.6.3";
    sha256 = "6326aeed5f86cf18f16d6dc831405614f855e2d416a91fd3fdc334f772345b00";
    sha256Bootstrap = {
      "x86_64-linux" = "5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b";
    };
    patches = [
      {
        rev = "e55948eaf64c06f2c147cb6b18522a9d9bf72641";
        file = "go/remove-tools.patch";
        sha256 = "275c4428ce5c0ff45e853f93b8259ed656fd2c53cdb83aeb287a9f305c1f84a7";
      }
    ];
  };

  "1.7" = {
    version = "1.7.1";
    sha256 = "2b843f133b81b7995f26d0cb64bbdbb9d0704b90c44df45f844d28881ad442d3";
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
