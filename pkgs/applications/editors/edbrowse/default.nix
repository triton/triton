{ stdenv, fetchurl, spidermonkey_24, unzip, curl, pcre, readline, openssl }:

let
  spidermonkey = spidermonkey_24;
in
stdenv.mkDerivation rec {
  name = "edbrowse-${version}";
  version = "3.5.4.2";

  nativeBuildInputs = [ unzip ];
  buildInputs = [ curl pcre readline openssl spidermonkey ];

  patchPhase = ''
    substituteInPlace src/ebjs.c --replace \"edbrowse-js\" \"$out/bin/edbrowse-js\"
  '';

  NIX_CFLAGS_COMPILE = "-I${spidermonkey}/include/mozjs-";
  makeFlags = "-C src prefix=$(out)";

  src = fetchurl {
    url = "http://edbrowse.org/${name}.zip";
    sha256 = "07am4936lz4fyf2n6qxfqaldjn1a77ayhlbvvh6xnshvra3xl50c";
  };
  meta = {
    description = "Command Line Editor Browser";
    longDescription = ''
      Edbrowse is a combination editor, browser, and mail client that is 100% text based.
      The interface is similar to /bin/ed, though there are many more features, such as editing multiple files simultaneously, and rendering html.
      This program was originally written for blind users, but many sighted users have taken advantage of the unique scripting capabilities of this program, which can be found nowhere else.
      A batch job, or cron job, can access web pages on the internet, submit forms, and send email, with no human intervention whatsoever.
      edbrowse can also tap into databases through odbc. It was primarily written by Karl Dahlke.
      '';
    license = stdenv.lib.licenses.gpl1Plus;
    homepage = http://edbrowse.org/;
    maintainers = [ stdenv.lib.maintainers.schmitthenner ];
  };
}
