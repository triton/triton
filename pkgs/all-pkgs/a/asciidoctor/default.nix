{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, ruby
}:

let
  version = "1.5.8";
in
stdenv.mkDerivation rec {
  name = "asciidoctor-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "asciidoctor";
    repo = "asciidoctor";
    rev = "v${version}";
    sha256 = "2955e10d487e2b5a7b7ede9660fa77597806dbd79daff606c57158f1ee4d3966";
  };

  nativeBuildInputs = [
    makeWrapper
    ruby
  ];

  buildPhase = ''
    gem build asciidoctor.gemspec
  '';

  installPhase = ''
    gem install -i "$out"/${ruby.gemDir} *.gem
    ln -srv "$out"/${ruby.gemDir}/bin "$out"/bin
  '';

  preFixup = ''
    for bin in "$out"/bin/*; do
      wrapProgram "$bin" \
        --set "GEM_PATH" "$out/${ruby.gemDir}"
    done
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
