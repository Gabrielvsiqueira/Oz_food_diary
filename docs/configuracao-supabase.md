# Configuração do Supabase e do login com Google

Passo a passo para ligar o app ao backend. Sem esta configuração o app ainda
roda, com a sessão local e a conta de demonstração.

## 1. Projeto no Supabase

1. Em [supabase.com](https://supabase.com), crie um projeto. Região:
   **South America (São Paulo)**.
2. Em **SQL Editor**, cole e execute o conteúdo de
   `supabase/migrations/20261009000000_user_data.sql`.
   (Com a [Supabase CLI](https://supabase.com/docs/guides/cli):
   `supabase link` e `supabase db push`.)
3. Em **Authentication → Sign In / Providers → Email**, desligue
   **Confirm email**.
4. Em **Project Settings → API Keys**, copie a **Publishable key**. Em
   **Project Settings → Data API**, copie a **Project URL**.

## 2. Credenciais do Google (Google Cloud Console)

Em [console.cloud.google.com](https://console.cloud.google.com), crie um
projeto, configure a **tela de consentimento OAuth** e crie três **IDs do
cliente OAuth** em *APIs e serviços → Credenciais*:

| Tipo        | Campos                                                                                              |
| ----------- | --------------------------------------------------------------------------------------------------- |
| **Web**     | URI de redirecionamento autorizado: `https://SEU-PROJETO.supabase.co/auth/v1/callback`. Guarde o **client ID** e o **client secret** |
| **iOS**     | Bundle ID: `com.example.ozContadorDeCalorias`                                                      |
| **Android** | Pacote: `com.example.oz_contador_de_calorias` e a impressão digital **SHA-1** da chave de assinatura |

SHA-1 da chave de debug:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

> Antes de publicar nas lojas, troque os identificadores `com.example…`
> (as lojas não aceitam) e cadastre o SHA-1 da chave de release.

## 3. Google no Supabase

Em **Authentication → Sign In / Providers → Google**:

- Ative o provedor.
- **Client IDs:** o client ID **Web** e o **iOS**, separados por vírgula.
- **Client Secret:** o secret do client **Web**.
- Ative **Skip nonce checks** (o SDK do Google no iOS inclui um nonce próprio
  no token).

## 4. Configuração local do app

```bash
cp config/dev.example.json config/dev.json
cp ios/Flutter/Secrets.example.xcconfig ios/Flutter/Secrets.xcconfig
```

- `config/dev.json`: URL e publishable key do Supabase, client ID **Web** e
  client ID **iOS** do Google.
- `ios/Flutter/Secrets.xcconfig`: client ID **iOS** invertido
  (`com.googleusercontent.apps.…`), usado como URL scheme do retorno do login.

Os dois arquivos ficam fora do git.

## 5. Rodar

```bash
flutter run --dart-define-from-file=config/dev.json
```

Sem `--dart-define-from-file`, o app roda com a sessão local.
