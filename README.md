# Círio de Nazaré — App Mobile

Aplicativo Flutter de apoio a quem participa da programação do **Círio de
Nazaré**, em Belém do Pará: notícias, agenda cultural, gastronomia
paraense, mapa da procissão, cálculo de rota até o ponto de início e um
modo de orientação por bússola.

Todos os dados exibidos no app (notícias, eventos, restaurantes, pontos de
interesse, trajeto da procissão e locais de início/chegada) são obtidos
em tempo real na API REST do projeto — **nenhuma informação fica fixa no
código do aplicativo**:

- API: <https://cirio-belem-api.onrender.com> (documentação Swagger em `/docs`)
- Código da API: <https://gitlab.com/ricardo.casseb/cirio-belem-api>

> ⚠️ A API está hospedada no plano gratuito do Render, que "dorme" após um
> período sem uso — a primeira requisição depois de um tempo parado pode
> demorar até ~1 minuto para responder enquanto o serviço acorda. O app já
> usa um timeout generoso (`ApiConstants.timeout`) para lidar com isso.

## Funcionalidades

| Requisito | Onde está implementado |
|---|---|
| Tela inicial com acesso às funcionalidades | `lib/screens/home/home_screen.dart` |
| Notícias (lista + detalhe) | `lib/screens/noticias/` |
| Agenda cultural | `lib/screens/agenda/agenda_screen.dart` |
| Gastronomia paraense + posição no mapa | `lib/screens/gastronomia/` |
| Mapa do Círio (usuário, início, fim, pontos, trajeto) | `lib/screens/mapa_cirio/mapa_cirio_screen.dart` |
| Como chegar ao Círio (rota + trajeto oficial) | `lib/screens/como_chegar/como_chegar_screen.dart` |
| Modo de orientação (seta por bússola) | `lib/screens/como_chegar/orientacao_screen.dart` |
| Centralização rápida ao sacudir o aparelho | `lib/widgets/shake_to_recenter.dart` + `lib/services/shake_detector.dart` |
| Adaptação ao ambiente (luz ambiente → tema claro/escuro) | `lib/services/ambient_light_service.dart` + `lib/state/theme_controller.dart` |
| Integração obrigatória com a API | `lib/services/cirio_api_service.dart` (único ponto de acesso HTTP do app) |

### Sobre cada funcionalidade

- **Notícias**: lista vinda de `GET /noticias` (título, data, resumo,
  imagem); ao tocar em uma notícia, abre a tela de detalhes com o
  conteúdo completo.
- **Agenda cultural**: lista vinda de `GET /eventos` (nome, descrição,
  data, horário, local), ordenada por data.
- **Gastronomia paraense**: lista vinda de `GET /restaurantes` (nome,
  descrição, endereço, especialidades, latitude/longitude); ao selecionar
  um restaurante, abre um mapa centralizado na posição dele.
- **Mapa do Círio**: combina `GET /mapa/cirio` (trajeto oficial, desenhado
  como `Polyline`), `GET /mapa/inicio`, `GET /mapa/fim` e
  `GET /mapa/pontos` (pontos relevantes), junto com a localização atual do
  usuário (GPS).
- **Como chegar ao Círio**: usa a posição atual do usuário para pedir à
  API (`GET /rota/ate-inicio?latitude=..&longitude=..`) o trajeto até o
  ponto de partida da procissão, e sobrepõe o percurso oficial da
  procissão (`GET /mapa/cirio`) como referência. Tem um atalho para abrir
  a mesma rota em um app de mapas externo.
- **Modo de orientação**: uma seta gira continuamente na tela apontando
  para o ponto de início da procissão, combinando a bússola do aparelho
  (`flutter_compass`) com o rumo calculado entre a posição atual do
  usuário e o destino (`geolocator`). A seta se atualiza tanto quando o
  usuário se desloca quanto quando gira o telefone.
- **Centralização rápida**: em qualquer tela de mapa, sacudir o aparelho
  (detectado via acelerômetro, `sensors_plus`) faz o mapa voltar
  imediatamente para a localização atual.
- **Adaptação ao ambiente**: em Android, o app lê o sensor de luminosidade
  do aparelho (`Sensor.TYPE_LIGHT`, via um `EventChannel` nativo próprio em
  `MainActivity.kt` — os pacotes disponíveis no pub.dev para esse sensor
  estavam desatualizados e quebravam o build com o Android Gradle Plugin
  atual) e alterna automaticamente entre tema claro e escuro conforme o
  ambiente fica mais escuro. Em plataformas sem esse sensor (iOS, web,
  desktop), o app usa o brilho do sistema operacional como alternativa.

## Arquitetura

```
lib/
├── core/            # constantes, tema, exceções de rede, utilitários
├── models/          # classes de dados (Noticia, Evento, Restaurante, ...)
├── services/        # acesso à API, GPS, bússola, acelerômetro, luz ambiente
├── state/           # controllers (ChangeNotifier) que ligam services às telas
├── screens/         # uma pasta por funcionalidade
└── widgets/         # componentes reutilizáveis (cards, estados de loading/erro, mapa)
```

- **Gerenciamento de estado**: `provider` + `ChangeNotifier`. Cada tela
  cria seu próprio controller (escopo local), e os serviços
  compartilhados (`CirioApiService`, `LocationService`, `CompassService`,
  o tema) são fornecidos uma única vez na raiz do app (`lib/main.dart`).
- **Mapas**: `flutter_map` com tiles do OpenStreetMap — não exige
  configuração de chave de API, diferente do Google Maps.
- **HTTP**: `package:http`, com parsing defensivo em `JsonUtils` (a API
  pode variar o tipo de alguns campos numéricos/textuais).

## Como rodar o projeto

O repositório já inclui as pastas nativas `android/` e `ios/` (geradas com
`flutter create`) e as permissões de internet/localização já configuradas
em `AndroidManifest.xml` e `Info.plist`. Para rodar:

1. Tenha o [Flutter SDK](https://docs.flutter.dev/get-started/install)
   instalado — este projeto foi validado com o Flutter 3.47.4
   (`flutter analyze` e `flutter test` passam sem erros).
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Rode o app em um emulador/aparelho físico:
   ```bash
   flutter run
   ```

> 💡 Bússola, acelerômetro (sacudir) e sensor de luz ambiente dependem de
> hardware real — teste essas três funcionalidades em um aparelho físico,
> não em emulador.

### Permissões já configuradas

- **Android** (`android/app/src/main/AndroidManifest.xml`): `INTERNET`,
  `ACCESS_FINE_LOCATION` e `ACCESS_COARSE_LOCATION`.
- **iOS** (`ios/Runner/Info.plist`): `NSLocationWhenInUseUsageDescription`.

> Observação: o sensor de luminosidade ambiente só está disponível em
> Android (lido nativamente em `MainActivity.kt`, sem depender de pacotes
> de terceiros), pois o iOS não expõe uma API pública de luz ambiente para
> apps de terceiros; no iOS o app usa o brilho do sistema como alternativa
> (ver `AmbientLightService`).

## Sobre os campos da API

O formato abaixo foi levantado a partir da documentação da API
(README/Swagger do projeto). Caso algum nome de campo tenha mudado desde
então, ajuste apenas o `fromJson` do model correspondente em `lib/models/`
— o resto do app não precisa mudar:

- `GET /noticias`, `/noticias/{id}`: `id, titulo, data, resumo, imagem, conteudo`
- `GET /eventos`, `/eventos/{id}`: `id, nome, descricao, data, horario, local[, latitude, longitude]`
- `GET /restaurantes`, `/restaurantes/{id}`: `id, nome, descricao, endereco, especialidades[], latitude, longitude`
- `GET /mapa/pontos`: lista de `{ id, nome, tipo, descricao, latitude, longitude }`
- `GET /mapa/cirio`: `{ id, nome, data, distancia_km, inicio: {...}, fim: {...}, pontos: [{ ordem, latitude, longitude }] }`
- `GET /mapa/inicio`, `/mapa/fim`: `{ nome, latitude, longitude }`
- `GET /rota/ate-inicio?latitude=..&longitude=..`: `{ origem, destino: { nome, latitude, longitude }, distancia_metros, duracao_segundos, pontos: [{ latitude, longitude }] }`

## Testes

Há um teste de smoke da tela inicial em `test/widget_test.dart`. Rode com:

```bash
flutter test
```

## Possíveis evoluções

- Cache local (ex.: `shared_preferences`/`sqflite`) para consulta offline
  das últimas notícias/agenda já carregadas.
- Notificações push para lembrar o usuário de eventos da agenda.
- Testes de widget para as telas de lista e para o cálculo do ângulo da
  seta de orientação (`OrientacaoController.anguloDaSeta`).
