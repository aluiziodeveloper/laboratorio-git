cenario_titulo() { echo "commit --amend: corrigir o último commit"; }

_pagina() { case "$LAB_VARIANT" in 1) echo contato ;; 2) echo projetos ;; 3) echo sobre ;; esac; }
_errada() { case "$LAB_VARIANT" in 1) echo "feat: add contct page" ;; 2) echo "feat: add projetcs page" ;; 3) echo "feat: add abuot page" ;; esac; }
_certa() { case "$LAB_VARIANT" in 1) echo "feat: add contact page" ;; 2) echo "feat: add projects page" ;; 3) echo "feat: add about page" ;; esac; }

cenario_gerar() {
  lab_write index.html "<h1>Portfólio</h1>"
  lab_git add .
  lab_commit "feat: add the home page"
  lab_set pai "$(lab_rev HEAD)"
  lab_write "$(_pagina).html" "<h1>$(_pagina)</h1>"
  lab_git add .
  lab_commit "$(_errada)"
  lab_write "$(_pagina).css" "h1 { font-size: 2rem; }"
}

cenario_missao() {
  cat <<TXT
Missão: o último commit saiu com a mensagem errada ("$(_errada)")
e esqueceu o arquivo $(_pagina).css. Corrija o último commit, sem criar um commit novo.
  - Mensagem certa: $(_certa)
TXT
}

cenario_verificar() {
  check "continuam 2 commits na main" same "$(lab_git rev-list --count main)" 2
  check "o primeiro commit não mudou" same "$(lab_rev HEAD~1)" "$(lab_get pai)"
  check "a mensagem é '$(_certa)'" same "$(lab_git log -1 --format=%s)" "$(_certa)"
  check "o commit contém $(_pagina).css" lab_git cat-file -e "HEAD:$(_pagina).css"
  check "o commit ainda contém $(_pagina).html" lab_git cat-file -e "HEAD:$(_pagina).html"
}

cenario_solucao() {
  git add "$(_pagina).css"
  git commit --amend -m "$(_certa)"
}

# Erro comum: um commit novo em vez de corrigir o último.
cenario_solucao_errada() {
  git add "$(_pagina).css"
  git commit -m "$(_certa)"
}
