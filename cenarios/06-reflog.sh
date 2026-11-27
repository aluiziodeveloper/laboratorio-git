cenario_titulo() { echo "reflog: resgatar commits depois de um reset --hard"; }

_perdidos() { echo $((LAB_VARIANT + 1)); }

cenario_gerar() {
  local i
  for i in 1 2 3 4 5 6; do
    lab_write "secao-$i.html" "<section>Seção $i</section>"
    lab_git add .
    lab_commit "feat: add section $i"
  done
  lab_set perdido "$(lab_rev HEAD)"
  lab_git reset -q --hard "HEAD~$(_perdidos)"
  lab_set main "$(lab_rev HEAD)"
}

cenario_missao() {
  cat <<TXT
Missão: alguém rodou "git reset --hard" e os últimos $(_perdidos) commits sumiram da main.
  - Crie a branch resgate apontando para o commit mais novo que se perdeu.
  - Não mexa na main.
TXT
}

cenario_verificar() {
  check "a branch resgate existe" lab_rev refs/heads/resgate
  check "resgate aponta o commit perdido mais novo" same "$(lab_rev refs/heads/resgate)" "$(lab_get perdido)"
  check "a main não mudou" same "$(lab_rev refs/heads/main)" "$(lab_get main)"
}

cenario_solucao() {
  git branch resgate "HEAD@{1}"
}
