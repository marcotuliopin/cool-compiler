# cool-compiler

A Compiler for the Cool programming language.

## Seção 1: Interpretador Léxico

**Marco Túlio de Pinho e Raul Araju**

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

Quando o caractere referente às aspas é lido, o estado *strings* é iniciado. A partir daí, para cada caractere lido, este é adicionado à string e o tamanho dela é incrementado até que seja lido um caractere de aspas novamente, quando o estado é definido para *INITIAL* (o estado inicial padrão) novamente.
Alguns cuidados especiais foram tomados: conferir se caso tenha um caractere de nova linha, esse caractere deve ter um '\\' antes dele, conferir se não há EOF no meio da string e conferir se não há caracteres nulos. Qualquer desses casos levará a um erro.

#### Inteiros e Identificadores

Tanto para inteiros, quanto para identificadores, criamos regras que adicionam o lexema lido à tabela fornecida (*inttable* e *idtable*, respectivamente) e retornam seus tokens. Para inteiros, o token correspondente é o *INT_CONST*, para identificadores iniciados com uma letra maiúscula é *TYPEID*, e para identificadores iniciados com uma letra minúscula é *OBJECTID*.

#### Erros

Qualquer leitura que não cause match com uma das regras especificadas levará a um erro, retornando o token *ERROR*, e imprimindo o texto que gerou o problema como mensagem de erro.

Note que todo erro identificado pelo interpretador léxico gera à criação de um token da classe *ERROR* e à impressão de uma mensagem de erro.

--------------------------

## Seção 2 : Analisador Sintático

**Marco Túlio de Pinho e Raul Araju**

Dividimos a documentação dessa seção na explicação das definições dos terminais e das regras implementadas para o Analisdor sintático.

--------------------------
### Terminais

Começamos nossas com a declaração dos terminais e dos seus tipos:
- **%type \<feature> feat** : define a feature de uma classe.
- **%type \<features> feat_list** : define uma lista de features de uma classe.
- **%type \<feature> attr** : o atributo de uma classe é uma feature dela.
- **%type \<feature> method** : o método de uma classe é uma feature dela.
 - **%type \<formal> formal**: define o parâmetro formal.
 - **%type \<formals> formal_list**: define uma lista de parâmetros formais.
 - **%type \<cases> case_list**: define uma lista de casos de uma estrutura *case*.    
 -  **%type \<expression> expr**: define uma      
   expressão.    
  - **%type \<expressions> expr_list**: define uma lista de
   expressões separadas por ' , '.   
   - **%type \<expressions> expr_list_1**: define uma lista de expressões separadas por ' ; '.   
 -  **%type \<expression> let**: define uma estrutura *let*.    
 - **%type \<expression> init**: define a estrutura de uma inicialização de uma 
   variável.

--------------------------
### Regras
 As regras foram baseadas na documentação da linguagem COOL, bem como nos métodos definidos no arquivo *cool-tree.cc*.

#### feat
Uma feature pode ser um atributo ou um método.

#### feat_list
Adiciona cada feature à lista até que não haja mais features a serem adicionadas. Uma lista sem features é uma lista de features.

#### attr
Um atributo é da forma : \<id1> :\<tipo> [ <- \<expr> ]

#### method
Um método é da forma \<id>(\<id> : \<type>,...,\<id> : \<type>): \<type> { \<expr> };

#### formal

Um parâmetro formal é da forma: \<id> : \<tipo>.

#### formal_list
Para cada parâmetro formal lido após um *,*, adiciona ele à lista. Nesse caso, uma lista sem parâmetros é uma lista de parâmetros.

#### case
Uma linha do tipo \<id> : \<tipo> => \<expr>;. Adicionamos uma *branch* nesse caso.

#### case_list
Para cada linha da forma: \<id> : \<tipo> => \<expr>;, adiciona um *case* à lista. Nesse caso, uma lista sem parâmetros é uma lista de *case*s.

####  expr
As expressões são a maior categoria sintática do COOL, então há muitas regras relacionadas a elas. De maneira geral, para cada método no arquivo *cool-tree.cc* que retorna um objeto da classe Expression, criou-se uma regra apropriada relacionada a esse método. Por exemplo, para as contantes, criaram-se 3 regras que usaram os métodos: int_const, string_const e bool_const.

#### expr_list

Para cada expressão lida após um *,*, adiciona ela à lista. Nesse caso, uma lista sem expressões é uma lista de expressões.

#### expr_list1

Para cada expressão lida após um *;*, adiciona ela à lista. Nesse caso, uma lista deve ter pelo menos uma  lista de expressões.

#### let

Na declarações de precedência e de associatividade, foi criado um token *LET_REC*. Esse token foi usado na regra para definir precedência e solucionar o conflito de shift-reduce, introduzido pela ambiguidade da gramática. Além disso, um tratamento de erro é aplicado para que caso ocorra um erro de um let em uma variável, o parser siga para a próxima variável.
case_list.

#### init

Essa regra define uma inicialização opcional da variável.

### Erros

Adicionamos uma regra de reconhecimento de erros em *features*, de forma que, caso haja um erro em uma *feature*, o parser segue para a próxima *feature*. Além disso, tratamos de erros em *blocks* (definidos conforme *expr_list1*, invocando a macro *yyerrok*. O mesmo tratamento é realizado para expressões apresentando erro na definição de um *let*. Por fim, uma classe que apresenta erro também é tratada conforme a macro *yyerrok*.

## Good.cl
Definições de Classe: O código define uma classe chamada  C. Isso demonstra o conceito de definições de classe.

Atributos: Ele inclui um atributo var: Int dentro da classe C, mostrando declarações de atributos.

Métodos: A classe C define alguns métodos, incluindo method0, method1, method2 etc. Esses métodos ilustram definições de métodos.

Parâmetros de Método: Os métodos method0 e method1, por exemplo, recebem parâmetros (num1, num2, num), destacando os parâmetros de método em COOL.

Variáveis Locais: Os métodos declaram variáveis locais usando a expressão let, como let y: Int <- 1, o que demonstra declarações de variáveis.

Operações Aritméticas: O método add realiza uma operação aritmética, x * y, para mostrar expressões matemáticas em COOL.

Declarações Condicionais: O método method2 declarações condicionais (if...then...else...fi) para demonstrar construções de fluxo de controle.

Expressão Case: O método method3 usa uma expressão case para verificar o tipo dinâmico de um objeto, cobrindo a expressão case do COOL.

Herança: A classe B herda da classe A, ilustrando a herança de classes no COOL.

Instanciação de Objetos (New): O método method1 usa a expressão new B para criar um novo objeto, destacando a instanciação de objetos.

### Bad.cl

Nome do Método Ausente: Na classe Principal, o método principal está sem um nome após o parêntese de abertura. Esse erro representa um erro comum ao definir um método.

Dois Pontos Ausentes Após o Nome do Método: No método "add" dentro da classe Principal, não há dois pontos (:) após o nome do método. Isso representa uma violação da sintaxe de declaração de método.

Falta de <- para Atribuição de Atributo: No atributo "a" da classe Principal, o operador <- para atribuição de atributo foi substituído por um sinal de igual (=). Isso demonstra a maneira incorreta de inicializar atributos.

Parênteses não Correspondentes: No método "if_example" da classe Principal, há um parêntese de abertura não correspondente na instrução "if", que não está sendo fechado corretamente. Esse erro representa um erro comum de sintaxe em instruções condicionais.

Chaves não Correspondentes: No método "while_example" da classe Principal, a chave de abertura do loop "while" não está sendo fechada com a palavra-chave "pool" corretamente. Isso demonstra a importância do emparelhamento adequado de chaves em estruturas de controle.

Uso de Tipo Desconhecido: No método "let_example" da classe Principal, um tipo desconhecido, "UnknownType," é usado em uma declaração de variável. Isso destaca o problema de usar tipos indefinidos em COOL.

Definição de Classe Incompleta: O código inclui a classe "IncompleteClass," que não possui uma chave de fechamento para encerrar adequadamente a definição da classe. Isso representa um erro comum ao definir classes.




