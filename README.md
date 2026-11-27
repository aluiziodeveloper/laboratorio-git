# Laboratório de missões do Git

Cenários prontos para praticar Git sem medo, do curso **Git e GitHub na Era da IA: do primeiro commit ao portfólio**. Cada cenário monta um repositório com um problema de verdade (um commit perdido, um conflito, um bug escondido entre 40 commits), e o `./lab verificar` confere a sua solução.

Os experimentos destrutivos (`reset --hard`, rebase com conflito, `reflog`, `bisect`) acontecem aqui, numa pasta descartável, e nunca no seu portfólio.

## Como usar

Você precisa do Git e de um terminal bash: o do Linux, o do macOS ou o Git Bash do Windows.

```bash
git clone https://github.com/aluiziodeveloper/laboratorio-git
cd laboratorio-git
./lab listar                 # os cenários
./lab cenario reflog         # monta o cenário na pasta missao/
cd missao                    # resolva a missão aqui dentro
../lab verificar             # confere a solução
```

Cada cenário tem três variantes. Sem número, o `./lab cenario` sorteia uma; com número (`./lab cenario reflog 2`), monta aquela. Depois de cumprir uma missão, tente outra variante: é a **missão extra** da aula. Para ler o enunciado de novo, use `./lab missao`. Montar um cenário apaga a pasta `missao/` anterior.

## Cenários

| Cenário | Assunto |
|---|---|
| `primeiro-commit` | Só o arquivo certo entra no commit |
| `log-e-blame` | Descobrir qual commit escreveu uma linha |
| `restore` | Descartar no disco e tirar do stage |
| `amend` | Corrigir o último commit |
| `reset-soft` | Juntar commits de rascunho |
| `reflog` | Resgatar commits depois de um `reset --hard` |
| `stash` | Guardar o trabalho pela metade |
| `conflito-tres-arquivos` | Merge com conflito em três arquivos |
| `rebase` | Trazer a feature para a ponta da main |
| `bisect` | Achar o commit que quebrou entre 40 |

## Para quem mexe no laboratório

Cada arquivo em `cenarios/` monta o cenário, descreve a missão, verifica e traz uma solução de referência. O `testes/rodar.sh` monta cada cenário e variante e exige três coisas: que o verificador reprove o estado inicial, que aprove a solução de referência e que reprove as soluções erradas de propósito. O workflow `testes` roda isso em Linux, macOS e Windows a cada push.
