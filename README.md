# Desafio Técnico Flutter - Ide-z Digital

Este projeto é uma implementação de um aplicativo de lista de tarefas (To-Do), desenvolvido como parte do desafio técnico para a vaga de Desenvolvedor Flutter Pleno na [Ide-z Digital](https://www.idez.com.br/).

## Visão Geral

O aplicativo permite que os usuários gerenciem suas tarefas diárias. As funcionalidades incluem a capacidade de adicionar novas tarefas, visualizar a lista de tarefas existentes e marcar tarefas como concluídas. Os dados são persistidos localmente no dispositivo.

## Estrutura do Projeto

O projeto foi estruturado seguindo princípios de Clean Architecture, visando a separação de responsabilidades, escalabilidade e testabilidade. As principais camadas são:

-   **`lib/src/data`**: Contém as implementações dos repositórios e fontes de dados (neste caso, `shared_preferences` para persistência local).
-   **`lib/src/domain`**: Camada de domínio, contendo os modelos de dados (`TaskModel`).
-   **`lib/src/ui`**: Responsável pela apresentação (UI), contendo as views, view models e widgets. O gerenciamento de estado é feito com o `Provider`.
-   **`lib/src/core`**: Componentes e utilitários compartilhados por todo o aplicativo, como classes de resultado, exceptions, temas e navegação.

A navegação entre telas é gerenciada pelo pacote `go_router`.

## Tecnologias e Dependências

-   **Linguagem**: Dart
-   **Framework**: Flutter
-   **Gerenciamento de Estado**: `provider`
-   **Navegação**: `go_router`
-   **Modelos Imutáveis**: `freezed`
-   **Persistência Local**: `shared_preferences`
-   **Estilização**: `flex_color_scheme` para um sistema de temas flexível.
-   **Testes**: `flutter_test` e `mocktail` para testes unitários.

## Como Executar o Projeto

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/tiagualvs/idez_todos.git
    cd idez_todos
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Execute o `build_runner` para gerar os arquivos necessários (para `freezed` e `json_serializable`):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## Testes

Para executar os testes unitários, utilize o seguinte comando:

```bash
flutter test
```