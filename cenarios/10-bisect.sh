cenario_titulo() { echo "bisect: o bug entre 40 commits"; }

_quebra() { case "$LAB_VARIANT" in 1) echo 13 ;; 2) echo 27 ;; 3) echo 34 ;; esac; }

cenario_gerar() {
  local i valor
  lab_write teste.sh '#!/bin/sh' '# Falha se algum preço for negativo.' "! grep -q -- '-' precos.txt"
  lab_write precos.txt "10"
  lab_git add .
  lab_commit "test: add the price check"
  lab_set bom "$(lab_rev HEAD)"
  for i in $(seq 1 39); do
    valor=$((i * 7 % 50 + 1))
    if [ "$i" -eq "$(_quebra)" ]; then valor="-$valor"; fi
    printf '%s\n' "$valor" >>"$MISSION_DIR/precos.txt"
    lab_git add .
    lab_commit "feat: add price $i"
    if [ "$i" -eq "$(_quebra)" ]; then lab_set esperado "$(lab_rev HEAD)"; fi
  done
}

cenario_missao() {
  cat <<TXT
Missão: o teste "sh teste.sh" passa no primeiro commit e falha no último (são 40).
Descubra o primeiro commit em que ele falha.
  - Grave o hash desse commit (pelo menos 7 caracteres) em resposta.txt, na raiz.
  - Termine fora do bisect, de volta na main.
TXT
}

cenario_verificar() {
  local resposta esperado
  esperado="$(lab_get esperado)"
  resposta="$(tr -d ' \r\n' <"$MISSION_DIR/resposta.txt" 2>/dev/null)"
  check "resposta.txt existe" test -f "$MISSION_DIR/resposta.txt"
  check "a resposta tem pelo menos 7 caracteres" test "${#resposta}" -ge 7
  check "o hash aponta o commit que quebrou" sh -c "case '$esperado' in '$resposta'*) [ -n '$resposta' ] ;; *) false ;; esac"
  check "o bisect terminou" sh -c "! git -C '$MISSION_DIR' rev-parse -q --verify refs/bisect/bad"
  check "você está na main" same "$(lab_git symbolic-ref --short HEAD 2>/dev/null)" main
}

cenario_solucao() {
  git bisect start main "$(git rev-list --max-parents=0 main)"
  git bisect run sh teste.sh
  git rev-parse refs/bisect/bad >resposta.txt
  git bisect reset
}
