#!/bin/sh -e
export PATH="@sed@${PATH+:}$PATH"
if [ -e "$HOME"/.local/share/factorio/config.ini ]; then
  sed -i "$HOME"/.local/share/factorio/config.ini \
    -e 's,read-data=.*,read-data=__PATH__executable__/../../data,' \
    -e "s,write-data=.*,write-data=$HOME/.local/share/factorio,"
else
  mkdir -p "$HOME"/.local/share/factorio
  cat > "$HOME"/.local/share/factorio/config.ini <<EOF
[path]
read-data=__PATH__executable__/../../data
write-data=$HOME/.local/share/factorio
EOF
fi
exec @factorio@ -c "$HOME/.local/share/factorio/config.ini" "$@"
