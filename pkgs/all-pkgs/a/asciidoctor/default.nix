{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, ruby
}:

let
  version = "2.0.1";
in
stdenv.mkDerivation rec {
  name = "asciidoctor-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "asciidoctor";
    repo = "asciidoctor";
    rev = "v${version}";
    sha256 = "54a516c3fa7f54b81572e324c54afc47456cea49c34e06e532c10652a8f68ea2";
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
