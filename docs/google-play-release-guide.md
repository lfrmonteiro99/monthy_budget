# Gestao Mensal — Guia Completo: Do Código ao Google Play

Este documento explica **todo** o processo de como o código chega à Google Play Store, desde o momento em que fazes push de código até a app aparecer na loja.

---

## Índice

1. [Visão Geral do Pipeline](#1-visão-geral-do-pipeline)
2. [Anatomia da Versão (Semver + versionCode)](#2-anatomia-da-versão)
3. [O Que Acontece em Cada Evento Git](#3-o-que-acontece-em-cada-evento-git)
4. [Assinatura da App (Keystore)](#4-assinatura-da-app-keystore)
5. [GitHub Secrets — O Que São e Como Configurar](#5-github-secrets)
6. [Setup Inicial no Google Play Console](#6-setup-inicial-no-google-play-console)
7. [Criar a Service Account para CI/CD](#7-criar-a-service-account-para-cicd)
8. [Alterar o CI para Construir AAB (em vez de APK)](#8-alterar-o-ci-para-construir-aab)
9. [Adicionar Deploy Automático ao Google Play](#9-adicionar-deploy-automático-ao-google-play)
10. [Workflow Completo: Do Código à Loja](#10-workflow-completo-do-código-à-loja)
11. [Gestão de Tags e Versões](#11-gestão-de-tags-e-versões)
12. [Tracks do Google Play (Internal/Beta/Production)](#12-tracks-do-google-play)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Visão Geral do Pipeline

```
git push feature branch → Auto-PR → Tests passam → Auto-merge → main → Tag v1.2.0 → AAB → Google Play
```

O pipeline tem 5 fases:

| Fase | Trigger | O que faz | Workflow |
|------|---------|-----------|----------|
| **Auto-PR** | Push para qualquer branch (exceto `main`) | Cria PR para `main` + ativa auto-merge | `auto-pr.yml` |
| **Test** | PR para `main` ou push para `main` | `flutter analyze` + `flutter test` | `flutter-ci.yml` |
| **Auto-merge** | Tests passam no PR | Squash merge automático para `main` | GitHub auto-merge |
| **Build** | Push para `main` (após test passar) ou tag `v*` (sem test) | Constrói AAB assinado com keystore | `flutter-ci.yml` |
| **GitHub Release** | Apenas tags `v*` | Cria Release no GitHub com o AAB anexado | `flutter-ci.yml` |
| **Deploy Play Store** | Apenas tags `v*` | Faz upload do AAB para Google Play | `flutter-ci.yml` |

**Porquê esta separação?**
- Push para uma branch cria PR automaticamente — não precisas de ir ao GitHub criar manualmente.
- PRs correm testes. Se passam, o auto-merge faz squash merge para `main` sem intervenção.
- Push para `main` (resultado do auto-merge) constrói o AAB — é um "dev build" para testes internos.
- Tags `v*` saltam os testes e constroem diretamente o AAB — a tag é sempre criada a partir de `main` que já foi testado.
- Tags `v*` são releases oficiais — são as únicas que vão para o Google Play.

**Branch protection em `main`:** O merge só acontece se o job `test` passar. Configurado via GitHub branch protection rules com `strict: true` (branch tem de estar up-to-date com `main`).

---

## 2. Anatomia da Versão

No `pubspec.yaml`:

```yaml
version: 1.0.0+1
#         │ │ │  │
#         │ │ │  └── versionCode (inteiro, incrementa SEMPRE)
#         │ │ └──── patch (bugfixes)
#         │ └────── minor (novas features, backward compatible)
#         └──────── major (breaking changes)
```

### Regras

- **`versionName`** (1.0.0): O que o utilizador vê na Play Store. Segue [Semantic Versioning](https://semver.org/).
- **`versionCode`** (+1): Inteiro que o Google Play usa para saber se uma versão é mais recente. **Tem de incrementar em CADA upload**. O Google Play rejeita uploads com versionCode igual ou inferior ao anterior.

### Exemplos

| Situação | Antes | Depois |
|----------|-------|--------|
| Bugfix pequeno | `1.0.0+1` | `1.0.1+2` |
| Nova feature | `1.0.1+2` | `1.1.0+3` |
| Redesign grande | `1.1.0+3` | `2.0.0+4` |

**A tag Git deve corresponder ao versionName**: se `pubspec.yaml` diz `1.2.0+5`, a tag é `v1.2.0`.

---

## 3. O Que Acontece em Cada Evento Git

### Push para uma feature branch

```
Trigger: push → branches-ignore: [main]
Workflow: auto-pr.yml
```

1. Verifica se já existe um PR para esta branch → se não, cria um PR para `main`
2. Ativa **auto-merge** (squash) no PR

**Não precisas de ir ao GitHub criar o PR manualmente.** Basta fazer `git push origin minha-branch` e o PR é criado automaticamente.

### Pull Request para `main` (testes)

```
Trigger: pull_request → branches: [main]
Workflow: flutter-ci.yml (job: test)
```

1. Checkout do código da branch
2. Setup Flutter 3.41.2
3. Cria stub do Supabase config (placeholder — testes não precisam de Supabase real)
4. `flutter pub get`
5. `flutter gen-l10n` (gera ficheiros de tradução)
6. `flutter analyze --no-fatal-infos` (análise estática — erros bloqueiam, warnings não)
7. `flutter test` (corre todos os testes unitários e de widget)

**Se falhar**: PR mostra ❌, auto-merge fica à espera. Corriges o código, fazes push, e os testes correm de novo.
**Se passar**: Auto-merge faz squash merge para `main` automaticamente.

**Não constrói AAB** — seria desperdício de CI minutes para código em revisão.

### Push para `main` (merge do PR)

```
Trigger: push → branches: [main]
Jobs: test → build (sequencial)
```

1. **Job test**: Corre analyze + tests (igual ao PR)
2. **Job build** (só se test passar):
   - Setup Java 17 (necessário para Gradle)
   - Descodifica keystore do secret `KEYSTORE_BASE64`
   - Constrói AAB assinado
   - Faz upload do AAB como artifact no GitHub (guardado 30 dias)
   - Cria uma **prerelease** no GitHub com nome `Dev build (<sha>)`

**Isto é um build de desenvolvimento** — serve para testar internamente antes de criar uma release oficial.

### Tag `v*` (release oficial)

```
Trigger: push → tags: [v*]
Jobs: build (sem test — o código já foi testado no push para main)
```

1. Constrói AAB assinado
2. Faz upload do AAB como artifact
3. Cria uma **GitHub Release** formal (não prerelease) com release notes automáticas
4. Faz upload do AAB para o **Google Play** (track internal ou production)

**Os testes não correm em tags** — a tag é criada a partir de `main`, que já passou pelos testes no momento do merge. Correr testes novamente seria redundante e atrasaria a release.

**Esta é a única forma de publicar na loja.**

---

## 4. Assinatura da App (Keystore)

### O que é

Todas as apps Android têm de ser assinadas com uma chave criptográfica. O Google Play usa esta assinatura para verificar que os updates vêm do mesmo developer. Se perderes a keystore, **nunca mais podes fazer update da app** (terias de criar uma app nova com package name diferente).

### A tua keystore

```
Ficheiro: monthy_budget/my-release-key.jks
Tipo:     PKCS12
Alias:    my-key
Package:  com.orcamentomensal.orcamento_mensal
```

### Como o Gradle a usa

No `android/app/build.gradle.kts`:

```kotlin
val keystoreFile = rootProject.file("keystore.jks")  // android/keystore.jks
if (keystoreFile.exists()) {
    signingConfigs {
        create("release") {
            storeFile = keystoreFile
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")         // "my-key"
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }
}
```

- Localmente: podes definir estas env vars ou usar debug signing.
- No CI: as env vars vêm dos GitHub Secrets.

### Google Play App Signing

Quando submeteres a app pela primeira vez, o Google Play vai pedir para ativar **Play App Signing**. Isto significa:

- Tu assinas o AAB com a tua keystore (upload key).
- O Google re-assina com a chave dele antes de distribuir aos utilizadores.
- Se perderes a tua keystore, podes pedir ao Google para gerar uma nova upload key. A app key do Google nunca se perde.

**Aceita sempre o Play App Signing** — é uma rede de segurança.

---

## 5. GitHub Secrets

Secrets são variáveis encriptadas guardadas no GitHub. O CI acede-lhes mas ninguém consegue lê-las depois de criadas (nem tu — só podes sobrescrever).

### Como configurar

**GitHub → Repo → Settings → Secrets and variables → Actions → New repository secret**

Ou via CLI:
```bash
gh secret set NOME_DO_SECRET --body "valor"
```

### Secrets necessários

| Secret | Valor | Para que serve |
|--------|-------|----------------|
| `KEYSTORE_BASE64` | `base64 -w 0 my-release-key.jks` | Keystore codificada em base64 (ficheiros binários não podem ser secrets diretamente) |
| `KEYSTORE_PASSWORD` | Password da keystore | Abrir o ficheiro .jks |
| `KEY_PASSWORD` | Password da chave | Aceder à chave dentro da keystore (normalmente igual à KEYSTORE_PASSWORD) |
| `KEY_ALIAS` | `my-key` | Nome da chave dentro da keystore |
| `SUPABASE_URL` | URL do projeto Supabase | Config da app para builds de release |
| `SUPABASE_ANON_KEY` | Anon key do Supabase | Config da app para builds de release |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | JSON da service account | Autenticar com Google Play API (ver secção 7) |

### Gerar KEYSTORE_BASE64

```bash
# No diretório do repo
base64 -w 0 my-release-key.jks | gh secret set KEYSTORE_BASE64
```

O `-w 0` remove line breaks — o base64 tem de ser uma linha só.

---

## 6. Setup Inicial no Google Play Console

### 6.1 Criar conta de developer

1. Vai a [play.google.com/console](https://play.google.com/console)
2. Paga a taxa única de $25
3. Completa a verificação de identidade (pode demorar dias)

### 6.2 Criar a app

1. **All apps → Create app**
2. Preenche:
   - App name: `Gestão Mensal`
   - Default language: `Portuguese (Portugal) – pt-PT`
   - App or game: `App`
   - Free or paid: `Free`
3. Aceita as declarações

### 6.3 Configurar a store listing

Antes de poder publicar, tens de preencher:

| Secção | O que preencher |
|--------|-----------------|
| **Main store listing** | Descrição curta (80 chars), descrição longa (4000 chars), screenshots (min 2), ícone (512x512), feature graphic (1024x500) |
| **App category** | Finance → Personal Finance |
| **Contact details** | Email obrigatório |
| **Privacy policy** | URL da privacy policy (já tens em `docs/privacy-policy.html`) |
| **Content rating** | Responder questionário IARC |
| **Target audience** | Faixa etária (18+ por ser app financeira) |
| **Ads** | A app contém anúncios? Sim/Não |
| **Data safety** | Que dados a app recolhe e como os usa |

### 6.4 Primeiro upload (MANUAL e obrigatório)

O Google Play exige que o **primeiro AAB seja submetido manualmente**. O CI/CD só funciona a partir do segundo upload.

1. Constrói o AAB localmente:
   ```bash
   # Define as env vars
   export KEYSTORE_PASSWORD="a-tua-password"
   export KEY_ALIAS="my-key"
   export KEY_PASSWORD="a-tua-password"

   # Copia a keystore para android/
   cp ../my-release-key.jks android/keystore.jks

   # Constrói
   flutter build appbundle --release
   ```
2. O AAB fica em: `build/app/outputs/bundle/release/app-release.aab`
3. No Play Console: **Testing → Internal testing → Create new release**
4. Upload do AAB
5. Adiciona release notes
6. **Review and roll out**

A partir daqui, o CI pode fazer uploads automáticos.

---

## 7. Criar a Service Account para CI/CD

A service account é como um "utilizador robot" que o CI usa para falar com a Google Play API.

### 7.1 Google Cloud Console

1. Vai a [console.cloud.google.com](https://console.cloud.google.com)
2. Cria um projeto (ou usa o existente ligado ao Play Console)
3. **APIs & Services → Enable APIs → Google Play Android Developer API** → Enable
4. **IAM & Admin → Service Accounts → Create Service Account**
   - Nome: `github-ci-deploy`
   - Descrição: `CI/CD deployment to Play Store`
5. Não precisas de dar roles no GCP — os permissões vêm do Play Console
6. **Actions (⋮) → Manage keys → Add key → JSON**
7. Faz download do JSON. Parece assim:
   ```json
   {
     "type": "service_account",
     "project_id": "gestao-mensal-xxxxx",
     "private_key_id": "abc123...",
     "private_key": "-----BEGIN PRIVATE KEY-----\n...",
     "client_email": "github-ci-deploy@gestao-mensal-xxxxx.iam.gserviceaccount.com",
     ...
   }
   ```

### 7.2 Dar permissões no Play Console

1. **Google Play Console → Setup → API access**
2. Liga o projeto GCP que criaste
3. Em **Service accounts**, encontra `github-ci-deploy@...`
4. Clica **Manage Play Console permissions**
5. Dá estas permissões:
   - ✅ **View app information and download bulk reports**
   - ✅ **Create, edit, and delete draft apps**
   - ✅ **Release to production, exclude devices, and use Play App Signing**
   - ✅ **Release apps to testing tracks**
   - ✅ **Manage testing tracks and edit tester lists**
6. Na tab **App permissions**, adiciona a app `Gestão Mensal`
7. **Invite user → Send invite**

### 7.3 Guardar no GitHub

```bash
# Cola o JSON inteiro (multi-linha) como secret
gh secret set PLAY_STORE_SERVICE_ACCOUNT_JSON < path/to/service-account.json
```

**Apaga o ficheiro JSON local depois** — não deve existir em nenhum repositório.

---

## 8. AAB vs APK

O Google Play **exige AAB** (Android App Bundle) para novas apps desde 2021. O AAB permite ao Google optimizar o APK para cada dispositivo (menos tamanho de download).

O CI já está configurado para construir AAB (`flutter build appbundle --release`). O output fica em:

```
build/app/outputs/bundle/release/app-release.aab
```

O nome do AAB é controlado pelo Gradle automaticamente — chama-se sempre `app-release.aab`.

---

## 9. Adicionar Deploy Automático ao Google Play

### GitHub Action: `r0adkll/upload-google-play`

Adiciona um novo job ao `flutter-ci.yml`:

```yaml
deploy-play-store:
  needs: build    # só corre se o build passar
  if: startsWith(github.ref, 'refs/tags/v')  # só em tags
  runs-on: ubuntu-latest
  steps:
    - uses: actions/download-artifact@v4
      with:
        name: gestao-mensal-aab

    - uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT_JSON }}
        packageName: com.orcamentomensal.orcamento_mensal
        releaseFiles: "*.aab"
        track: internal
        status: completed
```

### Parâmetros importantes

| Parâmetro | Valor | Significado |
|-----------|-------|-------------|
| `packageName` | `com.orcamentomensal.orcamento_mensal` | O applicationId da app (tem de corresponder ao da Play Console) |
| `releaseFiles` | `*.aab` | O ficheiro AAB a submeter |
| `track` | `internal` | Para que track do Play Console vai (ver secção 12) |
| `status` | `completed` | `completed` = disponível imediatamente; `draft` = precisa de aprovação manual no Console |
| `whatsNewDirectory` | (opcional) | Pasta com ficheiros `pt-PT` com release notes |

---

## 10. Workflow Completo: Do Código à Loja

### Passo a passo

```
1. Desenvolves na feature branch (ex: claude/nova-feature-xyz)
         │
         ▼
2. git push origin claude/nova-feature-xyz
         │
         ▼
3. CI cria PR automaticamente + ativa auto-merge
         │
         ▼
4. CI corre: analyze + test ──── Se falha: corriges, push, testes correm de novo
         │
         ▼ (passa)
5. Auto-merge: squash merge para main (automático)
         │
         ▼
6. CI corre: build AAB → prerelease no GitHub
   (este é um dev build para testar internamente)
         │
         ▼
7. Testas o AAB do dev build. Tudo OK?
         │
         ▼ (sim)
8. Atualizas pubspec.yaml:
   version: 1.1.0+2  (incrementa versionCode!)
         │
         ▼
9. Commit + push → auto-PR → auto-merge para main
         │
         ▼
10. Crias a tag:
    git tag v1.1.0
    git push origin v1.1.0
         │
         ▼
11. CI corre: build AAB → GitHub Release → Upload Play Store
         │
         ▼
12. App disponível no track "internal" do Google Play
         │
         ▼
13. Testas no Play Console → Promoves para production
         │
         ▼
14. App live na Google Play Store
```

### Comandos concretos

```bash
# 1-5: Desenvolvimento normal (tudo automático após o push)
git checkout -b claude/nova-feature
# ... desenvolve ...
git add -A && git commit -m "claude/nova-feature: add X"
git push origin claude/nova-feature
# PR criado automaticamente, testes correm, auto-merge se passam

# 7: Testa o dev build
# Vai a GitHub → Actions → último run → Artifacts → download AAB

# 8-9: Prepara release (numa nova branch)
git checkout -b claude/bump-version
# Edita pubspec.yaml → version: 1.1.0+2
git add pubspec.yaml
git commit -m "claude/bump-version: bump version to 1.1.0+2"
git push origin claude/bump-version
# Auto-PR + auto-merge levam isto para main

# 10: Cria tag (após o merge para main)
git checkout main && git pull
git tag v1.1.0
git push origin v1.1.0

# 11-14: Automático!
```

---

## 11. Gestão de Tags e Versões

### Convenção de tags

```
v{major}.{minor}.{patch}
```

Exemplos: `v1.0.0`, `v1.1.0`, `v1.1.1`, `v2.0.0`

### Regra fundamental

**A tag e o `pubspec.yaml` têm de corresponder.**

Se `pubspec.yaml` diz `version: 1.2.0+5`, a tag é `v1.2.0`.

### Checklist antes de criar uma tag

1. ✅ Todos os testes passam localmente (`flutter test`)
2. ✅ `flutter analyze --no-fatal-infos` sem erros
3. ✅ `pubspec.yaml` version atualizada (versionName + versionCode incrementado)
4. ✅ Commit da version bump está pushed para `main`
5. ✅ O commit na ponta de `main` é o que queres publicar

### Apagar uma tag (se algo correu mal)

```bash
# Apaga localmente
git tag -d v1.1.0

# Apaga no remote
git push origin :refs/tags/v1.1.0
```

Depois corrige o problema, e cria a tag de novo.

### Listar tags existentes

```bash
git tag --list 'v*' --sort=-v:refname
```

---

## 12. Tracks do Google Play

O Google Play tem 4 tracks (canais de distribuição):

| Track | Quem recebe | Aprovação Google | Uso |
|-------|-------------|------------------|-----|
| **Internal testing** | Até 100 testers que tu convidas por email | Não (disponível em minutos) | Testar antes de publicar |
| **Closed testing (Alpha)** | Testers que se inscrevem via link | Sim (review pode demorar horas/dias) | Beta fechado |
| **Open testing (Beta)** | Qualquer pessoa que encontre o link | Sim | Beta público |
| **Production** | Todos os utilizadores na Play Store | Sim (review 1-7 dias, primeira vez pode ser semanas) | Release final |

### Estratégia recomendada

1. **CI faz upload para `internal`** (automático, sem review do Google)
2. Tu testas no telemóvel via Internal testing
3. Se OK, **promoves para `production`** no Play Console (1 clique)

Para promover: **Play Console → Release → Production → Create new release → Add from library** (seleciona o build do internal).

### Mudar o track no CI

No workflow, muda o `track`:

```yaml
track: internal      # Para testes internos (recomendado inicialmente)
track: production    # Para ir direto para produção (depois de confiares no processo)
```

---

## 13. Troubleshooting

### "Version code already exists"

O `versionCode` no `pubspec.yaml` (+N) já foi submetido antes. Incrementa-o.

### "APK not accepted, use AAB"

O Google Play exige AAB para novas apps. Muda `flutter build apk` para `flutter build appbundle`.

### "Keystore alias not found"

O `KEY_ALIAS` secret não corresponde ao alias dentro do keystore. Verifica com:
```bash
keytool -list -keystore my-release-key.jks
```

### "Service account does not have permission"

A service account não tem as permissões corretas no Play Console, ou a app não está nos "App permissions" da service account. Volta à secção 7.2.

### "First upload must be manual"

O Google Play exige que o primeiro AAB seja submetido pelo Play Console. Não há forma de contornar isto.

### "App signing certificate mismatch"

Submeteste um AAB assinado com uma keystore diferente da que usaste na primeira submissão. Usa sempre a mesma `my-release-key.jks`.

### "Review rejected"

O Google rejeitou a app por violar políticas. Lê o email com os motivos, corrige, e resubmete. Razões comuns:
- Falta privacy policy
- Descrição enganosa
- Permissões desnecessárias
- Conteúdo inapropriado

---

## Resumo: Ficheiros Relevantes

```
monthy_budget/
├── .github/workflows/
│   ├── flutter-ci.yml           ← Pipeline CI/CD (test + build + release)
│   └── auto-pr.yml              ← Auto-criação de PR + auto-merge
├── monthy_budget_flutter/
│   ├── pubspec.yaml             ← version: X.Y.Z+N
│   ├── android/
│   │   └── app/
│   │       └── build.gradle.kts ← Signing config (lê env vars)
│   └── build/                   ← Output dos builds (gitignored)
├── my-release-key.jks           ← Keystore (NÃO commitar!)
└── docs/
    ├── privacy-policy.html      ← Necessário para Play Store listing
    └── google-play-release-guide.md  ← Este documento
```

## Resumo: GitHub Secrets

```
KEYSTORE_BASE64                  ← Keystore em base64
KEYSTORE_PASSWORD                ← Password da keystore
KEY_ALIAS                        ← "my-key"
KEY_PASSWORD                     ← Password da chave
SUPABASE_URL                     ← URL do Supabase
SUPABASE_ANON_KEY                ← Anon key do Supabase
PLAY_STORE_SERVICE_ACCOUNT_JSON  ← JSON da service account (secção 7)
```
