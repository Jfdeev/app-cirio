/// Estado genérico de carregamento usado pelos controllers baseados em
/// `ChangeNotifier` — evita repetir a mesma máquina de estados em cada tela.
enum CarregamentoStatus { inicial, carregando, sucesso, erro }
