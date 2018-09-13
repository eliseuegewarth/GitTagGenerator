# Git Tag Generator
Este projeto tem o intuito de automatizar a criação de git tags automaticamente.

## How-To

### Configuração de variáveis de ambiente

- Para adicionar variaveis ambiente ao seu sistema linux, basta usar `export VAR_NAME="value"`.
- Para persistir essa variavel ambiente, basta armazenar o comando indicado no arquivo `~/.bashrc` do seu usuário.
- Para exportar estas variáveis de ambiente no ambiente do Travis CI, basta acessar as configurações do build.

#### Adicionando repositórios
Para adicionar um repositório ao build, basta criar uma variável ambiente `REPOSITORY_<NAME>`.

Template: `export REPOSITORY_<name>="<user>/<repository>"`

Template: `export REPOSITORY_<name>="<organization>/<repository>"`

Exemplo: `export REPOSITORY_GIT="git/git"`

Caso você não tenha configurado nenhuma variável ambiente `REPOSITORY_*`, o script vai usar os repositórios descritos no arquivo `repos.txt`.

### Execução

```
./git_tag_gen.sh
```
