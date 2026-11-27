cenario_titulo() { echo "stash: guardar o trabalho pela metade"; }

_errado() { case "$LAB_VARIANT" in 1) echo Portfolo ;; 2) echo Portifólio ;; 3) echo Protfólio ;; esac; }

cenario_gerar() {
  lab_write titulo.txt "Meu $(_errado) Vivo"
  lab_write index.html "<h1>Portfólio</h1>"
  lab_git add .
  lab_commit "feat: add the title and home page"
  lab_set main "$(lab_rev HEAD)"
  printf '<p>Seção nova, pela metade</p>\n' >>"$MISSION_DIR/index.html"
  lab_set blob-metade "$(lab_git hash-object index.html)"
}

cenario_missao() {
  cat <<TXT
Missão: você está no meio de uma mudança no index.html e apareceu um erro urgente:
o titulo.txt diz "$(_errado)" em vez de "Portfólio".
  1. Guarde o trabalho pela metade, sem commit.
  2. Crie a branch hotfix a partir da main e corrija o titulo.txt num commit
     com a mensagem "fix: correct the title typo".
  3. Volte para a main e recupere o trabalho pela metade. A pilha do stash termina vazia.
TXT
}

cenario_verificar() {
  check "a branch hotfix existe" lab_rev refs/heads/hotfix
  check "hotfix tem um commit acima da main" same "$(lab_rev hotfix~1)" "$(lab_get main)"
  check "a mensagem é 'fix: correct the title typo'" same "$(lab_git log -1 --format=%s hotfix)" "fix: correct the title typo"
  check "o título está certo no hotfix" same "$(lab_git show hotfix:titulo.txt)" "Meu Portfólio Vivo"
  check "você está na main" same "$(lab_git symbolic-ref --short HEAD)" main
  check "a main não mudou" same "$(lab_rev main)" "$(lab_get main)"
  check "o trabalho pela metade voltou" same "$(lab_git hash-object index.html)" "$(lab_get blob-metade)"
  check "a pilha do stash está vazia" same "$(lab_git stash list | wc -l | tr -d ' ')" 0
}

cenario_solucao() {
  git stash push -m "half-done section"
  git switch -c hotfix
  printf 'Meu Portfólio Vivo\n' >titulo.txt
  git commit -am "fix: correct the title typo"
  git switch main
  git stash pop
}
