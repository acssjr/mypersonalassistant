# Personal Assistant

Projeto do assistente pessoal baseado no OpenClaw oficial. O núcleo permanece intacto; personalizações vivem em `services/assistant/workspace/skills`.

## Limites

- `services/assistant/workspace`: conteúdo portátil e versionado.
- `work/openclaw-state`: configuração e estado local ignorados pelo Git.
- `work/openclaw-auth`: credenciais locais ignoradas pelo Git.
- `work/openclaw-codex`: autenticação local do Codex ignorada pelo Git.
- `.env`: token local e caminhos do Compose, nunca versionados.

## Operação local

1. Execute `pwsh -File scripts/Initialize-LocalRuntime.ps1`.
2. Inicie o Docker Desktop.
3. Execute `docker compose pull`.
4. Execute `docker compose up -d openclaw-gateway`.
5. Abra `http://127.0.0.1:18789/`.

O acesso ao modelo usa uma autenticação local do Codex armazenada em
`work/openclaw-codex`. Esse diretório não deve ser enviado ao Git nem copiado
automaticamente para o VPS; o servidor terá sua própria autenticação.

Google Calendar, WhatsApp e outras contas serão conectadas somente depois da validação local.
