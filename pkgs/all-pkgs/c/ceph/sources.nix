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
    fetchVersion = 2;
    version = "11.0.2";
    rev = "refs/tags/v${version}";
    sha256 = "0illa8yfphi95l4ibv9ii6657lny434lwcinm8qdz51y05svpwcb";
  };

  "git" = rec {
    fetchVersion = 2;
    version = "2016-11-04";
    rev = "d95d522846b5ddf8bd4b1a83e4b16818c851c754";
    sha256 = "b044a6c61895956b3f90a6db9706fe834bea10482ffc24646b8e8653b2e969cf";
  };
}
