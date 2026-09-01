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

## Google Workspace

O executável `gog` é incorporado à imagem Docker e o estado OAuth fica em
`work/openclaw-state/gog`, fora do Git. A configuração inicial recomendada é
autorizar apenas Google Calendar e Google Tasks:

```text
gog auth setup usuario@gmail.com --services calendar,tasks
```

O Gateway recebe `GOG_KEYRING_PASSWORD` pelo arquivo `.env`; nunca versione esse
valor, o JSON do cliente OAuth ou os tokens gerados.

## Produtividade pessoal

As versões das cinco skills de produtividade ficam registradas em
`services/assistant/skills.lock.json`. A skill própria
`personal-productivity-orchestrator` conecta os métodos de planejamento, revisão
diária, reunião, memória e foco ao `gog`, ao cron e ao WhatsApp.

Na VPS, defina `PERSONAL_ASSISTANT_WHATSAPP_TO` apenas no `.env` usando o destino
E.164 autorizado. Em seguida execute:

```text
bash scripts/Install-VpsProductivitySkills.sh
```

O script reinstala as versões fixas e declara, de forma idempotente, o plano
matinal às 08:00 e a revisão diária às 21:00 em `America/Bahia`.
