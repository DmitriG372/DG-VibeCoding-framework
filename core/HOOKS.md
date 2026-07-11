# Hooks — DG-VibeCoding Framework v8.0

> Hook'id lisavad Operating Protocoli guardrail'e Claude Code'i ja Codexi tasandil. Claude konfiguratsioon: `.claude/settings.local.json`; Codex konfiguratsioon: `.codex/hooks.json`. Allikas: `hooks/*.js` (15 hook'i).

## Eesmärk

Hook'id ei ole "nice-to-have" automatika — nad teisendavad Operating Protocoli reeglid **jõustatavateks piiranguteks**. Manuaalne distsipliin ei skaleeru; hook'id skaleeruvad.

| Operating Protocol reegel | Jõustav hook |
|---|---|
| Rule 1 — Dekomponeeri enne tegutsemist | `decomposition-guard.js` |
| Rule 4 — Kirurgilised muudatused | `scope-guard.js` |
| Rule 5 — Eesmärgipõhine täitmine (ei stub'e committi) | `completion-guard.js` |

## Hook'id raamistuse järgi

### PreToolUse (võivad blokeerida, exit 2 = hard block)

| Hook | Matcher | Mida teeb |
|------|---------|-----------|
| `block-env.js` | `Read\|Grep` | Blokeerib `.env*` failide lugemise |
| `decomposition-guard.js` | `Edit\|Write\|MultiEdit` | Blokeerib editi kui aktiivne feature ei ole dekomponeeritud (`steps` puudub + `trivial:true` puudub) |
| `test-dir-protection.js` | `Edit\|Write\|MultiEdit` | Kaitseb testkausta läbimõtlematu muutuse eest |
| `completion-guard.js` | `Bash` | Blokeerib `git commit` kui `scripts/stub-check.sh` leiab stub'e |

### PostToolUse (ainult tagasiside, ei blokeeri)

| Hook | Matcher | Mida teeb |
|------|---------|-----------|
| `scope-guard.js` | `Edit\|Write\|MultiEdit` | Hoiatab kui muudetud fail langeb feature `corridor.forbidden` alla |
| `type-check.js` | `Edit\|Write\|MultiEdit` | Käivitab `tsc --noEmit` muudetud TS-failidele |
| `auto-format.js` | `Edit\|Write\|MultiEdit` | Vormindab (prettier / projekti formatter) |
| `sprint-sync.js` | `Edit\|Write\|MultiEdit` | Sünkib `sprint/sprint.json` ↔ `sprint.md` |
| `test-output-filter.js` | `Bash` | Filtreerib testijooksu väljundit kompaktsemaks |
| `usage-tracker.js` | `Skill\|SlashCommand\|Task` | Logib agentide ja skillide kasutust |
| `context-monitor.js` | `.*` | Jälgib kontekstiakna kasutust |
| `plan-to-sprint.js` | `ExitPlanMode` | Teisendab plaani `sprint/sprint.json`-iks |

### Muud raamistused

| Hook | Sündmus | Mida teeb |
|------|---------|-----------|
| `pre-compact.js` | `PreCompact` | Salvestab konteksti-snapshot enne kompaktimist |
| `git-context.js` | `SessionStart` (once) | Laadib git branch + ahead/behind sessiooni algul |
| `context-reload.js` | `SessionStart` (matcher: compact) | Taastab konteksti pärast compactimist |

## Konfiguratsioon

`setup-project.sh` paigaldab konfiguratsiooni `.claude/settings.local.json`-i. Vorm:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "node ./hooks/decomposition-guard.js" }
        ]
      }
    ]
  }
}
```

Täielik vaikimisi seadistus: `core/settings.template.json` (kopeeritakse setup'i 6. sammus).

## Hook'i kontraktid

Iga hook saab stdin'i kaudu JSON-payload'i:

```json
{
  "tool_name": "Edit",
  "tool_input": { "file_path": "src/foo.ts", "old_string": "...", "new_string": "..." },
  "cwd": "/path/to/project"
}
```

Exit-koodid:
- **0** — õnnestus, jätka
- **1** — soft fail (logitakse, ei blokeeri)
- **2** — hard block (PreToolUse hook'idel — tööriist ei käivitu, mudel saab stderr-i)

Stderr → Claude'i kontekst (mudel näeb feedback'i).
Stdout → kasutaja konsool (debug).

## Debugimine

```bash
# Käivita hook käsitsi
echo '{"tool_name":"Edit","tool_input":{"file_path":"src/main.ts"}}' | node ./hooks/decomposition-guard.js
echo $?  # exit code

# Kontrolli kas hook'id on registreeritud
cat .claude/settings.local.json | grep -A 2 '"matcher"'

# Hook'i logifail (kui hook seda kasutab — vt hook'i lähtekoodist)
ls -la .claude/hook-logs/ 2>/dev/null
```

## Hook'ide väljalülitamine

Soovitatav **mitte** hook'e välja lülitada — nad jõustavad protocoli. Aga vajaduse korral (nt CI):

```bash
# Ühe hook'i mööda
mv hooks/decomposition-guard.js hooks/decomposition-guard.js.disabled

# Kõik hook'id
mv .claude/settings.local.json .claude/settings.local.json.bak
```

## Versioonid

| Framework | Hook'ide arv | Märkused |
|-----------|--------------|----------|
| 6.x | 8 | Algne süsteem |
| 7.x | 11 | Lisati `context-monitor`, `usage-tracker`, `plan-to-sprint` |
| 8.0 | 15 | Lisati `decomposition-guard`, `scope-guard`, `completion-guard` (Operating Protocol jõustamine) |

## Lingid

- Framework juur: `~/_VibeCoding/_tools/DG-VibeCoding-framework/`
- Hook'ide lähtekood: `hooks/*.js`
- Settings template: `core/settings.template.json`
- Operating Protocol: `~/.claude/CLAUDE.md` sektsioon "Operating Protocol"
