cenario_titulo() { echo "restore: descartar no disco e tirar do stage"; }

_descartar() { case "$LAB_VARIANT" in 1) echo index.html ;; 2) echo estilo.css ;; 3) echo app.js ;; esac; }
_destagear() { case "$LAB_VARIANT" in 1) echo estilo.css ;; 2) echo app.js ;; 3) echo index.html ;; esac; }

cenario_gerar() {
  lab_write index.html "<h1>Portfólio</h1>"
  lab_write estilo.css "h1 { color: navy; }"
  lab_write app.js "console.log('oi');"
  lab_git add .
  lab_commit "feat: add the first site files"
  lab_set head "$(lab_rev HEAD)"
  printf 'mudança que deu errado\n' >>"$MISSION_DIR/$(_descartar)"
  printf 'mudança boa, mas ainda não é para este commit\n' >>"$MISSION_DIR/$(_destagear)"
  lab_git add "$(_destagear)"
  lab_set blob-bom "$(lab_git hash-object "$(_destagear)")"
}

cenario_missao() {
  cat <<TXT
Missão: arrume a área de trabalho sem fazer commit.
  - Descarte a mudança de $(_descartar): ele volta a ser igual ao último commit.
  - Tire $(_destagear) do stage, mas mantenha a mudança dele no disco.
TXT
}

cenario_verificar() {
  local a b
  a="$(_descartar)"
  b="$(_destagear)"
  check "nenhum commit novo" same "$(lab_rev HEAD)" "$(lab_get head)"
  check "$a igual ao último commit" lab_git diff --quiet HEAD -- "$a"
  check "nada no stage" lab_git diff --cached --quiet
  check "a mudança de $b continua no disco" same "$(lab_git hash-object "$b")" "$(lab_get blob-bom)"
}

cenario_solucao() {
  git restore "$(_descartar)"
  git restore --staged "$(_destagear)"
}
