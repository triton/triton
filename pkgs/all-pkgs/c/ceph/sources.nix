{
  "0.94" = rec {
    fetchVersion = 1;
    version = "0.94.9";
    rev = "refs/tags/v${version}";
    sha256 = "1sbfs3ds2yhizxclhfscnsjxgb02qg3h45g9y5n3nypdlkf8wnnj";
  };

  "9" = rec {
    fetchVersion = 1;
    version = "9.2.1";
    rev = "refs/tags/v${version}";
    sha256 = "09nhvm50sk22pawdq9vf43xigpyqp7wl694la0bx2081dinskj71";
  };

  "10" = rec {
    fetchVersion = 1;
    version = "10.2.3";
    rev = "refs/tags/v${version}";
    sha256 = "0hb16n58pbx67hg15qanzs95vqghi26r4k07bk0fh6b5cw678aa8";
  };

  "dev" = rec {
    version = "11.0.2";
    sha256 = "ed0b4feba9485f4a7e5771c23b429affdce161710b6474861ad4518c337456de";
  };

  "git" = rec {
    version = "2016-11-14";
    sha256 = "fbf2f65c56ce00cd136ba376b0c1f33a50a5283e011ac539c9642bd2aec80418";
  };
}
