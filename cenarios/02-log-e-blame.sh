cenario_titulo() { echo "Histórico: quem escreveu esta linha?"; }

_alvo() { case "$LAB_VARIANT" in 1) echo Contato ;; 2) echo Cidade ;; 3) echo Objetivo ;; esac; }

cenario_gerar() {
  local i author linha
  lab_write site/sobre.md "# Sobre mim"
  lab_git add .
  lab_commit "docs: start the about page" "Ana Souza <ana@exemplo.invalid>"
  for i in 1 2 3 4 5 6 7 8; do
    case $((i % 3)) in 0) author="Ana Souza <ana@exemplo.invalid>" ;; 1) author="Bruno Lima <bruno@exemplo.invalid>" ;; 2) author="Carla Dias <carla@exemplo.invalid>" ;; esac
    case "$i" in
      2) linha="Contato: contato@exemplo.invalid" ;;
      4) linha="Cidade: Recife" ;;
      6) linha="Objetivo: primeira vaga como dev" ;;
      *) linha="Nota $i sobre a minha trajetória." ;;
    esac
    printf '%s\n' "$linha" >>"$MISSION_DIR/site/sobre.md"
    lab_git add .
    lab_commit "docs: add line $i to the about page" "$author"
    case "$linha" in "$(_alvo):"*) lab_set esperado "$(lab_rev HEAD)" ;; esac
  done
}

cenario_missao() {
  cat <<TXT
Missão: descubra qual commit escreveu a linha que começa com "$(_alvo):" em site/sobre.md.
  - Grave o hash desse commit (pelo menos 7 caracteres) no arquivo resposta.txt, na raiz do repositório.
  - Não faça commit da resposta.
TXT
}

cenario_verificar() {
  local resposta esperado
  esperado="$(lab_get esperado)"
  resposta="$( (tr -d ' \r\n' <"$MISSION_DIR/resposta.txt") 2>/dev/null)"
  check "resposta.txt existe" test -f "$MISSION_DIR/resposta.txt"
  check "a resposta tem pelo menos 7 caracteres" test "${#resposta}" -ge 7
  check "o hash aponta o commit certo" sh -c "case '$esperado' in '$resposta'*) [ -n '$resposta' ] ;; *) false ;; esac"
  check "o histórico não mudou (9 commits)" same "$(lab_git rev-list --count main)" 9
}

# No Git Bash do Windows, um -L "/regex/" vira caminho do Windows (conversão do MSYS).
# Por isso a solução acha o número da linha antes.
cenario_solucao() {
  local linha
  linha="$(grep -n "^$(_alvo):" site/sobre.md | cut -d: -f1)"
  git blame --porcelain -L "$linha,$linha" site/sobre.md | head -n 1 | cut -c1-12 >resposta.txt
}
