{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchPyPi
, fetchTritonPatch
, isPy2
, isPy3
, lib
, makeWrapper
, pythonPackages
, writeScript

, bash
, bash-completion
, beautifulsoup
, bs1770gain
, discogs-client
, enum34
, flac
, flask
, gobject-introspection
, imagemagick
, itsdangerous
, jellyfish
, jinja2
, mock
, mp3val
, munkres
, musicbrainzngs
, mutagen
, nose
, pyacoustid
, pyechonest
, pylast
, python-mpd2
, pyxdg
, pyyaml
, rarfile
, requests
, responses
, unidecode
, werkzeug

# For use in inline plugin
, pycountry

, channel

# External plugins
, enableAlternatives ? false
#, enableArtistCountry ? true
, enableCopyArtifacts ? true
, enableBeetsMoveAllArtifacts ? true
}:

let
  inherit (lib)
    optional
    optionals;

  sources = {
    "stable" = {
      version = "1.4.5";
      sha256 = "1bea88c5c23137a36d09590856df8c2f4e857ef29890d16c4d14b1170e9202fc";
    };
    "head" = {
      fetchzipversion = 3;
      version = "2017-10-29";
      rev = "7c9ce0da7a25b85846674c27f3618689cf9c2ba2";
      sha256 = "988712027732c67b7b8c08e185061a1afdafa88addedf76da143e29af24233be";
    };
  };
  source = sources."${channel}";
in
buildPythonPackage rec {
  name = "beets-${source.version}";

  src =
    if channel != "head" then
      fetchPyPi {
        package = "beets";
        inherit (source) sha256 version;
      }
    else
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "beetbox";
        repo = "beets";
        inherit (source) rev sha256;
      };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    beautifulsoup
    bs1770gain
    discogs-client
    flac
    flask
    # Needed for hook to set GI_TYPELIB_PATH
    gobject-introspection
    imagemagick
    itsdangerous
    jellyfish
    jinja2
    mock
    mp3val
    munkres
    musicbrainzngs
    mutagen
    nose
    pyacoustid
    pyechonest
    pylast
    python-mpd2
    pyxdg
    pyyaml
    rarfile
    responses
    requests
    unidecode
    werkzeug
  ] ++ optionals isPy2 [
    enum34
  ] ++ [
    pycountry
  ] ++ optional enableAlternatives (
      import ./plugins/beets-alternatives.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          isPy2
          optionals
          pythonPackages;
      }
    )
    # FIXME: Causes other plugins to fail to load
    #  - Needs to use beets logging instead of printing error messages
    #  - Needs musicbrainz fixes
    /*++ optional enableArtistCountry (
      import ./plugins/beets-artistcountry.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          pythonPackages;
      }
    )*/
    /* Provides edit & moveall plugins */
    ++ optional enableBeetsMoveAllArtifacts (
      import ./plugins/beets-moveall-artifacts.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub;
      }
    );

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "beets/beets-1.3-replaygain-default-bs1770gain.patch";
      sha256 = "d864aa643c16d5df9b859b5f186766a94bf2db969d97f255a88f33acf903b5b6";
    })
  ];

  postPatch = /* Fix bash completion path */ ''
    sed -i -e '/^BASH_COMPLETION_PATHS *=/,/^])$/ {
      /^])$/i u"${bash-completion}/share/bash-completion/bash_completion"
    }' beets/ui/commands.py
  '' + /* Fix paths for badfiles plugin */ ''
    sed -i -e '/self\.run_command(\[/ {
      s,"flac","${flac}/bin/flac",
      s,"mp3val","${mp3val}/bin/mp3val",
    }' beetsplug/badfiles.py
  '' + /* Replay gain */ ''
    sed -i -re '
      s!^( *cmd *= *b?['\'''"])(bs1770gain['\'''"])!\1${bs1770gain}/bin/\2!
    ' beetsplug/replaygain.py
    sed -i -e 's/if has_program.*bs1770gain.*:/if True:/' \
      test/test_replaygain.py
  '';

  meta = with lib; {
    description = "Music tagger and library organizer";
    homepage = http://beets.radbox.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
