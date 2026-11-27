cenario_titulo() { echo "Primeiro commit: só o arquivo certo entra"; }

_arquivo() { case "$LAB_VARIANT" in 1) echo notas.md ;; 2) echo ideias.md ;; 3) echo tarefas.md ;; esac; }

cenario_gerar() {
  lab_write "$(_arquivo)" "# Minhas $(_arquivo .md)" "" "Primeira linha do arquivo."
  lab_write rascunho.tmp "não versionar"
}

cenario_missao() {
  cat <<TXT
Missão: faça o primeiro commit do repositório.
  - Só o arquivo $(_arquivo) entra no commit; o rascunho.tmp fica de fora (e no disco).
  - Mensagem do commit: docs: add $(_arquivo)
TXT
}

cenario_verificar() {
  local f
  f="$(_arquivo)"
  check "existe exatamente um commit na main" same "$(lab_git rev-list --count main 2>/dev/null)" 1
  check "o commit contém $f" lab_git cat-file -e "main:$f"
  check "o commit não contém rascunho.tmp" sh -c "! git -C '$MISSION_DIR' cat-file -e main:rascunho.tmp"
  check "a mensagem é 'docs: add $f'" same "$(lab_git log -1 --format=%s main 2>/dev/null)" "docs: add $f"
  check "rascunho.tmp continua no disco" test -f "$MISSION_DIR/rascunho.tmp"
}

cenario_solucao() {
  git add "$(_arquivo)"
  git commit -m "docs: add $(_arquivo)"
}

# Erro comum: "git add ." leva o rascunho junto.
cenario_solucao_errada() {
  git add .
  git commit -m "docs: add $(_arquivo)"
}
