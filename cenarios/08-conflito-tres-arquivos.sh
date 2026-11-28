cenario_titulo() { echo "Conflito em três arquivos"; }

# Para cada arquivo, qual lado fica: main (ours) ou feature (theirs).
_lado() { # arquivo
  case "$LAB_VARIANT:$1" in
    1:cores.css | 1:titulo.txt | 2:menu.html | 3:cores.css) echo feature ;;
    *) echo main ;;
  esac
}

cenario_gerar() {
  lab_write cores.css ":root { --destaque: gray; }"
  lab_write menu.html "<nav>Início</nav>"
  lab_write titulo.txt "Portfólio"
  lab_git add .
  lab_commit "feat: add colors, menu and title"
  lab_git switch -q -c feature/visual
  lab_write cores.css ":root { --destaque: teal; }"
  lab_write menu.html "<nav>Início | Projetos</nav>"
  lab_write titulo.txt "Portfólio Vivo"
  lab_git add .
  lab_commit "feat: refresh the visual identity"
  lab_git switch -q main
  lab_write cores.css ":root { --destaque: orange; }"
  lab_write menu.html "<nav>Home</nav>"
  lab_write titulo.txt "Meu Portfólio"
  lab_git add .
  lab_commit "feat: adjust colors, menu and title"
  lab_set main "$(lab_rev main)"
  lab_set feature "$(lab_rev feature/visual)"
  lab_set arvore "$(lab_expected_tree HEAD)"
}

cenario_missao() {
  cat <<TXT
Missão: faça o merge da branch feature/visual na main. Os três arquivos vão dar conflito.
  - cores.css: fique com a versão da $(_lado cores.css)
  - menu.html: fique com a versão da $(_lado menu.html)
  - titulo.txt: fique com a versão da $(_lado titulo.txt)
Termine com o commit de merge.
TXT
}

cenario_verificar() {
  check "HEAD é um commit de merge" same "$(lab_git rev-list --parents -n 1 HEAD | wc -w | tr -d ' ')" 3
  check "o primeiro pai é a main de antes" same "$(lab_rev HEAD^1)" "$(lab_get main)"
  check "o segundo pai é a feature/visual" same "$(lab_rev HEAD^2)" "$(lab_get feature)"
  check "nenhum marcador de conflito" sh -c "! git -C '$MISSION_DIR' grep -q -e '^<<<<<<<' -e '^>>>>>>>' HEAD"
  check "cada arquivo ficou com o lado pedido" same "$(lab_git rev-parse 'HEAD^{tree}')" "$(lab_get arvore)"
  check "nada pendente" sh -c "[ -z \"\$(git -C '$MISSION_DIR' status --porcelain)\" ]"
}

cenario_solucao() {
  local f
  git merge feature/visual || true
  for f in cores.css menu.html titulo.txt; do
    if [ "$(_lado "$f")" = feature ]; then git checkout --theirs "$f"; else git checkout --ours "$f"; fi
    git add "$f"
  done
  git commit --no-edit
}

# Erro comum: resolver tudo com o mesmo lado.
cenario_solucao_errada() {
  git merge feature/visual || true
  git checkout --theirs cores.css menu.html titulo.txt
  git add cores.css menu.html titulo.txt
  git commit --no-edit
}
