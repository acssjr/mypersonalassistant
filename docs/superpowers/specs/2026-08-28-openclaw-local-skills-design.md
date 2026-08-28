# OpenClaw local com skills portáteis

Data: 2026-08-28

## Objetivo

Instalar uma versão oficial e estável do OpenClaw no computador local, personalizar skills sem alterar o núcleo instalado e transportar o mesmo workspace de skills para o VPS Ubuntu 24.04 LTS.

## Decisão arquitetural

O projeto usará o OpenClaw oficial sem modificações em seu código-fonte. As personalizações ficarão no workspace do assistente, cuja precedência permite substituir uma skill incluída quando a versão local usa o mesmo nome.

Skills oficiais poderão ser usadas sem alteração, copiadas para adaptação ou complementadas por novas skills. Uma necessidade que não possa ser resolvida com skills será avaliada primeiro como configuração ou plugin. Modificar o núcleo fica fora deste escopo.

## Estrutura

```text
personal-assistant/
├── services/
│   └── assistant/
│       ├── workspace/
│       │   ├── skills/
│       │   ├── agents/
│       │   └── references/
│       ├── tests/
│       └── upstream/
├── infrastructure/
│   └── docker/
├── docker-compose.yml
├── .env.example
└── .gitignore
```

`workspace/skills` será a fonte versionada das personalizações. `upstream` guardará somente metadados e referências necessárias para comparar uma skill adaptada com sua origem oficial; não será uma cópia modificada do núcleo.

## Runtime local

O Node.js do Windows será atualizado para a versão 26 suportada mais recente. O OpenClaw local será instalado pelo canal estável oficial e fixado na versão verificada no momento da instalação.

Os testes de portabilidade ocorrerão em ambiente Linux por Docker ou WSL2. Isso detectará antecipadamente dependências de skills que funcionem no Windows, mas não no Ubuntu do VPS.

## Personalização de skills oficiais

Cada skill relevante será classificada como:

1. usar sem alteração;
2. substituir no workspace mantendo o mesmo nome;
3. complementar com uma nova skill;
4. substituir por plugin quando forem necessárias novas ferramentas executáveis.

Uma skill adaptada registrará a versão ou commit de origem e o motivo da alteração. As atualizações do OpenClaw não alterarão automaticamente nossas cópias. O processo de atualização comparará cada override com a nova versão oficial antes de incorporar mudanças.

## Migração para o VPS

O mesmo diretório `services/assistant/workspace` será montado no contêiner do OpenClaw local e no contêiner do VPS. A versão do OpenClaw também será fixada para evitar diferenças silenciosas entre os ambientes.

Skills, referências, scripts e configurações não secretas serão transportados pelo repositório. Chaves de API, tokens, sessões do WhatsApp, autorizações do Google e o token do Gateway não serão versionados. Esses dados serão configurados ou migrados por um canal seguro no VPS.

## Segurança

- Segredos reais ficarão fora do Git.
- `.env.example` conterá apenas nomes e exemplos inofensivos.
- Skills copiadas ou instaladas serão revisadas antes de receber ferramentas com escrita, execução ou acesso a contas.
- O OpenClaw local e o VPS usarão workspaces e diretórios de estado separados.
- O Gateway do VPS permanecerá em loopback e exigirá autenticação.

## Verificação

A instalação só será considerada pronta quando:

1. Node.js e OpenClaw reportarem as versões esperadas;
2. o Gateway local iniciar e responder ao diagnóstico;
3. uma skill simples do workspace for carregada e executada;
4. uma skill de mesmo nome demonstrar precedência sobre a versão incluída;
5. o workspace funcionar no ambiente Linux local;
6. nenhum segredo real estiver presente nos arquivos versionados.

## Fora do escopo inicial

- Alterar ou manter um fork do núcleo do OpenClaw.
- Instalar simultaneamente PostgreSQL, Redis e n8n.
- Conectar Google Calendar ou WhatsApp antes de validar o Gateway e as skills locais.
- Transferir automaticamente credenciais locais para o VPS.

## Critérios de aceitação

- O OpenClaw oficial executa localmente na versão estável fixada.
- As skills personalizadas vivem somente no workspace do projeto.
- Uma skill oficial pode ser adaptada sem editar arquivos do pacote instalado.
- O projeto reproduz o mesmo conjunto de skills no Linux local e no VPS.
- Atualizar o OpenClaw não sobrescreve as personalizações.
