# cool-compiler

A Compiler for the Cool programming language.

## Seção 1: Interpretador Léxico

Marco Túlio de Pinho e Raul Araju

Dividimos a documentação desse trabalho na explicação das definições e das regras implementadas para o Interpretador Léxico.

--------------------------

### Definições

Começamos nossas definições por três variáveis auxiliares na execução do lexer:
- **str_const (char\*)**: armazena a string sendo lida.
- **str_len (int)**: captura o comprimento de uma string sendo lida.
- **str_contain_null_char (bool)**: captura a existência de um caractere nulo em uma string.

Também definimos três estados de início para as nossas regras:
- **inline_comment**: é ativado quando há a leitura de um marcador de começo de comentário "--", e é desativado quando lê-se uma nova linha "\n".
- **multiline_comment**: é ativado quando há a leitura de um marcador de começo de comentário "(\*" e é desativado quando lê-se um marcador de fim de comentário "\*)".
- **strings**: é ativado quando há a leitura de um marcador de começo de string (aspas) e é desativado quando lê-se um marcador de fim de string.
Os estados podem também ser desativados prematuramente em caso de erro, como por exemplo a leitura de um caracter *EOF* (end-of-file) em uma string.

Por último, temos macros para expressões regulares:
- **ASSIGN**: símbolo de atribuição (<-).
- **LE**: simbolo de menor ou igual (<=).
- **DIGIT**: dígitos de 0 a 9 ([0-9]).
- **UPPER**: letras maiúsculas ([A-Z]).
- **LOWER**: letras minúsculas ([a-z]).
- **CHAR**: letras, dígitos ou underscore ([A-Za-z0-9_]).
Essas macros nos permite maior legibilidade e facilidade de escrita na implementação do lexer.

--------------------------

### Regras

#### Espaços em Branco

Os espaços em branco, representados pelos caracteres " ", "\t", "\r", "\v" e "\f" são ignorados no processo de tokenização e **excluídos do resultado final** do interpretador.

#### Leitura de Comentários

Assim como os espaços em branco, os comentários **não são tokenizados**. Considera-se, porém, quebras de linha durante os comentários para a contagem de linhas do programa.
A leitura de um marcador de fim de comentário ("\*)") enquanto fora do estado *multiline_comment*, também como a leitura de um *EOF* durante o comentário levará a um erro.

#### Operadores e Palavras Reservadas

Tanto para operadores, quanto para palavras reservadas, retornamos os tokens correspondentes exclusivamente à classe dos mesmos. Por exemplo, a leitura de um operador "{" gerará um token "{", assim como a leitura da palavra "if" levará ao token "IF".

Com exceção das palavras "true" e "false", que devem ser iniciadas com letra minúscula, as palavras reservadas não são sensíveis à minúsculo e maiúsculo. Assim, desenvolvemos expressões regulares que geram match independentemente do case dos caracteres.

#### Strings

Quando o carctere referente às aspas é lido o estado <strings> é inicado. A partir daí, para cada caractere lido, esse caractere é adicionado à string e o tamanho dela é incrementado até que seja lido um caractere de aspas novamente, quando o estado é setado para <BEGIN> novamente.
Alguns cuidados especiais foram tomados: conferir se caso tenha um caractere de nova linha, esse caractere deve ter um '\' antes dele, conferir se não há EOF no meio da string e conferir se não há caracteres nulos.

#### Inteiros e Identificadores

Tanto para inteiros, quanto para identificadores, criamos regras que adicionam o lexema lido à tabela fornecida (*inttable* e *idtable*, respectivamente) e retornam seus tokens. Para inteiros, o token correspondente é o *INT_CONST*, para identificadores iniciados com uma letra maiúscula é *TYPEID*, e para identificadores iniciados com uma letra minúscula é *OBJECTID*.

#### Erros

Qualquer leitura que não cause match com uma das regras especificadas levará a um erro, retornando o token *ERROR*, e imprimindo o texto que gerou o problema como mensagem de erro.

Note que todo erro identificado pelo interpretador léxico gera à criação de um token da classe *ERROR* e à impressão de uma mensagem de erro.

