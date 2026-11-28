cenario_titulo() { echo "rebase: trazer a feature para a ponta da main"; }

cenario_gerar() {
  local i
  lab_write index.html "<h1>Portfólio</h1>"
  lab_write README.md "# Portfólio Vivo"
  lab_git add .
  lab_commit "feat: add the home page"
  lab_git switch -q -c feature/projetos
  for i in 1 2 3; do
    lab_write "projeto-$i.html" "<h2>Projeto $i</h2>"
    lab_git add .
    lab_commit "feat: add project $i"
  done
  if [ "$LAB_VARIANT" = 3 ]; then
    lab_write README.md "# Portfólio Vivo" "Agora com projetos."
    lab_git add README.md
    lab_commit_entre "docs: mention the projects"
  fi
  lab_git switch -q main
  lab_write rodape.html "<footer>2026</footer>"
  lab_git add .
  lab_commit "feat: add the footer"
  if [ "$LAB_VARIANT" != 1 ]; then
    lab_write README.md "# Portfólio Vivo" "Site pessoal."
    lab_git add README.md
    lab_commit "docs: describe the site"
  fi
  lab_set main "$(lab_rev main)"
  lab_set mensagens "$(lab_git log --reverse --format=%s main..feature/projetos | tr '\n' '|')"
  lab_set arvore "$(lab_expected_tree feature/projetos)"
}

cenario_missao() {
  cat <<TXT
Missão: a main andou depois que a branch feature/projetos nasceu.
Faça o rebase da feature/projetos sobre a main, para a história ficar linear.
TXT
  if [ "$LAB_VARIANT" = 3 ]; then
    echo '  - No conflito do README.md, fique com as duas linhas: "Site pessoal." e depois "Agora com projetos."'
  fi
  echo "  - Não mexa na main."
}

cenario_verificar() {
  check "a main não mudou" same "$(lab_rev main)" "$(lab_get main)"
  check "a feature parte da ponta da main" same "$(lab_git merge-base main feature/projetos)" "$(lab_get main)"
  check "nenhum commit de merge na feature" same "$(lab_git rev-list --merges main..feature/projetos | wc -l | tr -d ' ')" 0
  check "os commits da feature foram mantidos" same "$(lab_git log --reverse --format=%s main..feature/projetos | tr '\n' '|')" "$(lab_get mensagens)"
  check "o conteúdo final está certo" same "$(lab_git rev-parse 'feature/projetos^{tree}')" "$(lab_get arvore)"
  check "nenhum rebase pela metade" sh -c "[ ! -d '$MISSION_DIR/.git/rebase-merge' ] && [ ! -d '$MISSION_DIR/.git/rebase-apply' ]"
}

cenario_solucao() {
  git switch feature/projetos
  if ! git rebase main; then
    printf '%s\n' "# Portfólio Vivo" "Site pessoal." "Agora com projetos." >README.md
    git add README.md
    GIT_EDITOR=true git rebase --continue
  fi
}

# Erro comum: merge em vez de rebase.
cenario_solucao_errada() {
  git switch feature/projetos
  if ! git merge --no-edit main; then
    printf '%s\n' "# Portfólio Vivo" "Site pessoal." "Agora com projetos." >README.md
    git add README.md
    git commit --no-edit
  fi
}
