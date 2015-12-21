{ qtSubmodule, qtbase }:

qtSubmodule {
  name = "qttools";
  qtInputs = [ qtbase ];
  postInstall = ''
    find $out/lib/pkgconfig -name \*.pc -exec sed -i 's,Qt5UiPlugin,,g' {} \;
  '';
}
