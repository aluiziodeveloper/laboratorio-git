#!/usr/bin/env bash
# Testa todos os cenários: monta, o verificador reprova, a solução de referência resolve, o verificador aprova.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Configuração isolada: nada do usuário (assinatura, hooks, aliases) interfere.
export HOME="$WORK/home"
export GIT_CONFIG_NOSYSTEM=1
mkdir -p "$HOME"
git config --global user.name "Aluno de Teste"
git config --global user.email "aluno@exemplo.invalid"
git config --global advice.detachedHead false

printf 'git: %s | bash: %s | sistema: %s\n\n' "$(git --version | cut -d' ' -f3)" "$BASH_VERSION" "$(uname -s)"
total=0
falhas=0
erradas=0
for file in "$ROOT"/cenarios/*.sh; do
  name="$(basename "$file" .sh)"
  name="${name#*-}"
  for variant in 1 2 3; do
    total=$((total + 1))
    export LAB_MISSION_DIR="$WORK/missao-$name-$variant"
    status="ok"
    "$ROOT/lab" cenario "$name" "$variant" >"$WORK/log" 2>&1 || status="falhou ao montar"
    if [ "$status" = ok ] && "$ROOT/lab" verificar >>"$WORK/log" 2>&1; then
      status="verificador aprovou antes da solução"
    fi
    if [ "$status" = ok ]; then
      (
        MISSION_DIR="$LAB_MISSION_DIR"
        LAB_VARIANT="$variant"
        . "$file"
        cd "$LAB_MISSION_DIR" && cenario_solucao
      ) >>"$WORK/log" 2>&1
      "$ROOT/lab" verificar >>"$WORK/log" 2>&1 || status="verificador reprovou a solução"
    fi
    if [ "$status" = ok ] && grep -q '^cenario_solucao_errada()' "$file"; then
      "$ROOT/lab" cenario "$name" "$variant" >>"$WORK/log" 2>&1
      (
        MISSION_DIR="$LAB_MISSION_DIR"
        LAB_VARIANT="$variant"
        . "$file"
        cd "$LAB_MISSION_DIR" && cenario_solucao_errada
      ) >>"$WORK/log" 2>&1
      if "$ROOT/lab" verificar >>"$WORK/log" 2>&1; then
        status="verificador aprovou a solução errada"
      else
        erradas=$((erradas + 1))
      fi
    fi
    if [ "$status" = ok ]; then
      printf '  ok    %-26s variante %s\n' "$name" "$variant"
    else
      falhas=$((falhas + 1))
      printf '  FALHA %-26s variante %s: %s\n' "$name" "$variant" "$status"
      sed 's/^/        | /' "$WORK/log"
    fi
  done
done
printf '\n%s cenários, %s falha(s); %s soluções erradas reprovadas\n' "$total" "$falhas" "$erradas"
[ "$falhas" -eq 0 ]
