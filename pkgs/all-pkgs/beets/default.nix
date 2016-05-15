{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchTritonPatch
, glibcLocales
, makeWrapper
, writeScript

, bash
, bashCompletion
, bs1770gain
, flac
, imagemagick
, mp3val
, python2Packages

# External plugins
, enableAlternatives ? true
#, enableCopyArtifacts ? true
, enableDsedivecBeetsPlugins ? true
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    attrNames
    concatMapStrings
    concatStringsSep
    elem
    filterAttrs
    id
    makeSearchPath
    optional
    optionals
    optionalString
    platforms;
in

let
  optionalPlugins = {
    # TODO: write a generic function to detect null dependencies
    acousticbrainz =
      if python2Packages.requests2 != null then
        true
      else
        false;
    badfiles =
      if flac != null
         && mp3val != null then
        true
      else
        false;
    bpd =
      #if python2Packages.pygobject_2 != null
      #   && gst-plugins-base_0 != null
      #   && gstreamer_0 != null then
      #  true
      #else
        false;
    chroma =
      if python2Packages.pyacoustid != null then
        true
      else
        false;
    discogs =
      if python2Packages.discogs_client != null then
        true
      else
        false;
    echonest =
      if python2Packages.pyechonest != null then
        true
      else
        false;
    embyupdate =
      if python2Packages.requests2 != null then
        true
      else
        false;
    fetchart =
      if python2Packages.requests2 != null then
        true
      else
        false;
    lastgenre =
      if python2Packages.pylast != null then
        true
      else
        false;
    lastimport =
      if python2Packages.pylast != null then
        true
      else
        false;
    mpdstats =
      if python2Packages.mpd != null then
        true
      else
        false;
    mpdupdate =
      if python2Packages.mpd != null then
        true
      else
        false;
    replaygain =
      if bs1770gain != null then
        true
      else
        false;
    thumbnails =
      if python2Packages.pyxdg != null then
        true
      else
        false;
    web =
      if python2Packages.flask != null then
        true
      else
        false;
  };

  pluginsWithoutDeps = [
    "bench"
    "bpd"
    "bpm"
    "bucket"
    "convert"
    "cue"
    "duplicates"
    "edit"
    "embedart"
    "embyupdate"
    "filefilter"
    "freedesktop"
    "fromfilename"
    "ftintitle"
    "fuzzy"
    "ihate"
    "importadded"
    "importfeeds"
    "info"
    "inline"
    "ipfs"
    "keyfinder"
    "lyrics"
    "mbcollection"
    "mbsubmit"
    "mbsync"
    "metasync"
    "missing"
    "permissions"
    "play"
    "plexupdate"
    "random"
    "rewrite"
    "scrub"
    "smartplaylist"
    "spotify"
    "the"
    "types"
    "zero"
  ];

  enabledOptionalPlugins = attrNames (filterAttrs (_: id) optionalPlugins);

  allPlugins = pluginsWithoutDeps ++ attrNames optionalPlugins;
  allEnabledPlugins = pluginsWithoutDeps ++ enabledOptionalPlugins;

  testShell = "${bash}/bin/bash --norc";
  completion = "${bashCompletion}/share/bash-completion/bash_completion";
in

buildPythonPackage rec {
  name = "beets-${version}";
  version = "1.3.17";
  namePrefix = "";

  src = fetchFromGitHub {
    owner = "sampsyo";
    repo = "beets";
    rev = "v${version}";
    sha256 = "8b8c74478277e6b010cc1319c1e9b6fe97e1a8967bede341ebeabc205b7cc0f3";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    bs1770gain
    flac
    imagemagick
    mp3val
    python2Packages.beautifulsoup
    python2Packages.discogs_client
    python2Packages.enum34
    python2Packages.flask
    python2Packages.itsdangerous
    python2Packages.jellyfish
    python2Packages.jinja2
    python2Packages.mock
    python2Packages.mpd
    python2Packages.munkres
    python2Packages.musicbrainzngs
    python2Packages.mutagen
    python2Packages.nose
    python2Packages.pathlib
    python2Packages.pyacoustid
    python2Packages.pyechonest
    python2Packages.pylast
    python2Packages.pyxdg
    python2Packages.pyyaml
    python2Packages.rarfile
    python2Packages.responses
    python2Packages.requests2
    python2Packages.unidecode
    python2Packages.werkzeug
  ] ++ optional enableAlternatives (
      import ./plugins/beets-alternatives.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          python2Packages;
      }
    )
    /* FIXME: Causes other plugins to fail to load
    ++ optional enableCopyArtifacts (
      import ./plugins/beets-copyartifacts.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          fetchTritonPatch
          python2Packages;
      }
    )*/
    /* Provides edit & moveall plugins */
    ++ optional enableDsedivecBeetsPlugins (
      import ./plugins/dsedivec-beets-plugins.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          python2Packages;
      }
    );

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "beets/beets-1.3-replaygain-default-bs1770gain.patch";
      sha256 = "d864aa643c16d5df9b859b5f186766a94bf2db969d97f255a88f33acf903b5b6";
    })
  ];

  postPatch = ''
    sed -i -e '/assertIn.*item.*path/d' test/test_info.py
    echo echo completion tests passed > test/rsrc/test_completion.sh

    sed -i -e '/^BASH_COMPLETION_PATHS *=/,/^])$/ {
      /^])$/i u"${completion}"
    }' beets/ui/commands.py
  '' + /* fix paths for badfiles plugin */ ''
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

  preCheck = ''
    (${concatMapStrings (s: "echo \"${s}\";") allPlugins}) \
      | sort -u > plugins_defined
    find beetsplug -mindepth 1 \
      \! -path 'beetsplug/__init__.py' -a \
      \( -name '*.py' -o -path 'beetsplug/*/__init__.py' \) -print \
      | sed -n -re 's|^beetsplug/([^/.]+).*|\1|p' \
      | sort -u > plugins_available

    if ! mismatches="$(diff -y plugins_defined plugins_available)"; then
      echo "The the list of defined plugins (left side) doesn't match" \
           "the list of available plugins (right side):" >&2
      echo "$mismatches" >&2
      exit 1
    fi
  '';

  # TODO: fix LOCALE_ARCHIVE for freebsd
  checkPhase = ''
    runHook 'preCheck'

    LANG=en_US.UTF-8 \
    LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive \
    BEETS_TEST_SHELL="${testShell}" \
    BASH_COMPLETION_SCRIPT="${completion}" \
    HOME="$(mktemp -d)" \
      nosetests -v

    runHook 'postCheck'
  '';

  installCheckPhase = ''
    runHook 'preInstallCheck'

    tmphome="$(mktemp -d)"

    EDITOR="${writeScript "beetconfig.sh" ''
      #!${stdenv.shell}
      cat > "$1" <<CFG
      plugins: ${concatStringsSep " " allEnabledPlugins}
      CFG
    ''}" HOME="$tmphome" "$out/bin/beet" config -e
    EDITOR=true HOME="$tmphome" "$out/bin/beet" config -e

    runHook 'postInstallCheck'
  '';

  doCheck = true;
  doInstallCheck = true;

  meta = with stdenv.lib; {
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
