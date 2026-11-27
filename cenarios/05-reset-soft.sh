cenario_titulo() { echo "reset --soft: juntar commits de rascunho"; }

_n() { echo $((LAB_VARIANT + 1)); }

cenario_gerar() {
  local i
  lab_write index.html "<h1>Portfólio</h1>"
  lab_git add .
  lab_commit "feat: add the home page"
  lab_set base "$(lab_rev HEAD)"
  i=1
  while [ "$i" -le "$(_n)" ]; do
    printf '<li>Projeto %s</li>\n' "$i" >>"$MISSION_DIR/index.html"
    lab_git add .
    lab_commit "wip $i"
    i=$((i + 1))
  done
  lab_set arvore "$(lab_git rev-parse 'HEAD^{tree}')"
}

cenario_missao() {
  cat <<TXT
Missão: os últimos $(_n) commits se chamam "wip". Junte os $(_n) num único commit,
com a mensagem "feat: add the project list", sem perder nenhuma linha do index.html.
TXT
}

cenario_verificar() {
  check "o commit anterior é o da home page" same "$(lab_rev HEAD~1)" "$(lab_get base)"
  check "a mensagem é 'feat: add the project list'" same "$(lab_git log -1 --format=%s)" "feat: add the project list"
  check "o conteúdo é o mesmo dos commits wip" same "$(lab_git rev-parse 'HEAD^{tree}')" "$(lab_get arvore)"
  check "nenhum commit wip na main" same "$(lab_git log --format=%s main | grep -c '^wip')" 0
}

cenario_solucao() {
  git reset --soft "HEAD~$(_n)"
  git commit -m "feat: add the project list"
}
