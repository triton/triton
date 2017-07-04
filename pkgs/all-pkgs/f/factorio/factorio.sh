#!/bin/sh -e
export PATH="@sed@${PATH+:}$PATH"
if [ -e "$HOME"/.local/share/factorio ]; then
  sed \
    -e 's,read-data=.*,read-data=__PATH__executable__/../../share/factorio,' \
    -e "s,write-data=.*,write-data=$HOME/.local/share/factorio," \
    -i "$HOME"/.local/share/factorio/config.ini
else
  mkdir -p "$HOME"/.local/share/factorio
  echo "[path]" >> "$HOME"/.local/share/factorio/config.ini
  echo "read-data=__PATH__executable__/../../share/factorio" >> "$HOME"/.local/share/factorio/config.ini
  echo "write-data=$HOME/.local/share/factorio" >> "$HOME"/.local/share/factorio/config.ini
fi
exec @factorio@ -c "$HOME/.local/share/factorio/config.ini" "$@"
