{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchTritonPatch
, glibcLocales
, isPy27
, isPy3k
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
#, gst-plugins-bad
, gst-plugins-base
, gst-plugins-good
#, gst-plugins-ugly
, gst-python
, gstreamer
, imagemagick
, itsdangerous
, jellyfish
, jinja2
, mock
, mp3val
, mpd
, munkres
, musicbrainzngs
, mutagen
, nose
, pathlib
, pyacoustid
, pyechonest
, pygobject_3
, pylast
, pyxdg
, pyyaml
, rarfile
, requests
, responses
, unidecode
, werkzeug

# For use in inline plugin
, pycountry

# External plugins
, enableAlternatives ? false
#, enableArtistCountry ? true
#, enableCopyArtifacts ? true
, enableBeetsMoveAllArtifacts ? true
}:

let
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
    platforms
    versionOlder;

  optionalPlugins = {
    # TODO: write a generic function to detect null dependencies
    acousticbrainz =
      if requests != null then
        true
      else
        false;
    badfiles =
      if flac != null
         && mp3val != null then
        true
      else
        false;
    beatport =
      if requests != null then
        true
      else
        false;
    bpd =
      if pygobject_3 != null
         && gst-plugins-base != null
         && gstreamer != null then
        true
      else
        false;
    chroma =
      if pyacoustid != null then
        true
      else
        false;
    discogs =
      if discogs-client != null then
        true
      else
        false;
    /*echonest =
      if pyechonest != null then
        true
      else
        false;*/
    embyupdate =
      if requests != null then
        true
      else
        false;
    fetchart =
      if requests != null then
        true
      else
        false;
    lastgenre =
      if pylast != null then
        true
      else
        false;
    lastimport =
      if pylast != null then
        true
      else
        false;
    mpdstats =
      if mpd != null then
        true
      else
        false;
    mpdupdate =
      if mpd != null then
        true
      else
        false;
    replaygain =
      if bs1770gain != null then
        true
      else
        false;
    thumbnails =
      if pyxdg != null then
        true
      else
        false;
    web =
      if flask != null then
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
    "export"
    "filefilter"
    "freedesktop"
    "fromfilename"
    "ftintitle"
    "fuzzy"
    "hook"
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
  completion = "${bash-completion}/share/bash-completion/bash_completion";

  version = "2016-08-26";
in
buildPythonPackage rec {
  name = "beets-${version}";

  src = fetchFromGitHub {
    owner = "sampsyo";
    repo = "beets";
    rev = "ed0adc2b6343358274c8b4ab28889f4db245e796";
    sha256 = "66c2ace8077ded84579105868fc4651afdc06c9090d125ddb801f555753e315e";
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
    # Need to for hook to set GI_TYPELIB_PATH
    gobject-introspection
    gstreamer
    imagemagick
    itsdangerous
    jellyfish
    jinja2
    mock
    mp3val
    mpd
    munkres
    musicbrainzngs
    mutagen
    nose
    pyacoustid
    pyechonest
    pygobject_3
    pylast
    pyxdg
    pyyaml
    rarfile
    responses
    requests
    unidecode
    werkzeug
  ] ++ optionals isPy27 [
    enum34
  ] ++ optionals (versionOlder pythonPackages.python.channel "3.5") [
    pathlib
  ] ++ [
    pycountry
  ] ++ optional enableAlternatives (
      import ./plugins/beets-alternatives.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          isPy27
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
    # FIXME: Causes other plugins to fail to load
    /*++ optional enableCopyArtifacts (
      import ./plugins/beets-copyartifacts.nix {
        inherit
          stdenv
          buildPythonPackage
          fetchFromGitHub
          fetchTritonPatch
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

  GST_PLUGIN_PATH = makeSearchPath "lib/gstreamer-1.0" [
    gst-plugins-base
    gst-plugins-good
    #gst-plugins-bad
    #gst-plugins-ugly
  ];

  preFixup = ''
    wrapProgram $out/bin/beet \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'GST_PLUGIN_PATH' : "$GST_PLUGIN_PATH"
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
    HOME="$(mktemp -d)"
    nosetests -v
    mkdir -p $HOME/

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

  doCheck = !isPy3k;
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
