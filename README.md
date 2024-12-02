
> Cotemig: Banco de Dados II
> Prof. Gilberto Assis
> Trabalho de PL/SQL

# Regras para o Trabalho de PL/SQL
</br>
## 1. Formação do Grupo
- O trabalho será realizado em grupo de até **3 alunos**.
  - **OBS**: Para cada aluno a mais na formação do grupo corresponderá a **-30% da nota**.
</br>
## 2. Valor do Trabalho
- O valor do trabalho é de **30 pontos**.
</br>
## 3. Data de Entrega
- A data de entrega de **TODOS os grupos** será no dia **17/11/2022**.
  - **OBS**: Para cada dia corrido de atraso na entrega do trabalho será descontado **50% da nota**.
</br>
## 4. Forma de Entrega
- O trabalho deverá ser entregue via **CLASSROOM**.
</br>
## 5. Descrição do Trabalho
O trabalho consiste em criar rotinas que serão responsáveis por criptografar e descriptografar os valores armazenados no campo **SENHA** da tabela **LOGIN**.

### Modelo de Dados
O grupo deverá obedecer ao modelo de dados abaixo e criar os objetos correspondentes.

### Regras de Negócio

#### 1. Função `FN_CRIPTOGRAFIA()`
- Deve receber como parâmetros:
  - `SENHA`: a senha que será criptografada.
  - `ACRESCIMO`: o valor usado seguindo a regra de criptografia abaixo.

#### 2. Regra para Criptografia
A criptografia será realizada em 3 etapas:

1. A função deverá embaralhar os caracteres da senha usando uma matriz **3xN**.
   - Exemplo: Caso a senha usada seja `COTEMIG123`, o resultado do embaralhamento será:
     ```
     C O T
     E M I
     G 1 2
     3
     ```

2. Os caracteres deverão ser convertidos para seu correspondente na tabela **ASCII**.
   - **OBS**: Perceba que todos os números têm 3 posições.

3. a função deverá embaralhar os caracteres da senha usando uma matriz 3xN, ou seja,
caso a senha usada seja COTEMIG123 o resultado do embaralhamento será:
```
CEG3
OM1
TI2
```
=>
```
CEG3OM1TI2
```

4. os caracteres deverão ser convertidos para seu correspondente na tabela ASCII.
`CEG3OM1TI2 -> 070072074054082080052087076053`
> OBS: Perceba que todos os números tem 3 posições.

5. Deve-se acrescentar a cada número gerado o valor passado no parâmetro `ACRESCIMO`.
   - Exemplo: Supondo que o valor de `ACRESCIMO` seja **3**, o resultado seria:
     ```
     [067069071051079077049084073050]
     ```

Esse número será registrado no campo **SENHA** da tabela **LOGIN** para o usuário em questão.

#### 3. Função `FN_DESCRIPTOGRAFIA()`
- Deve receber como parâmetros:
  - `SENHA`: a senha criptografada.
  - `ACRESCIMO`: o valor de acréscimo.
- Deve desfazer a criptografia realizada com base no item 2.

#### 4. Procedure `PR_INSERE_LOGIN()`
- Deve receber como parâmetros:
  - `COD_LOGIN`
  - `LOGIN`
  - `SENHA`

A procedure deverá:

1. Certificar que não haja valores de `COD_LOGIN` e `LOGIN` repetidos.
2. Usar a função `FN_CRIPTOGRAFIA()` para embaralhar a senha passada pelo usuário.
   - **DICA**:
     - Crie uma variável para armazenar o momento do insert:
       ```sql
       DATA_HORA TIMESTAMP;
       DATA_HORA := SYSTIMESTAMP;
       ```
     - Use o comando abaixo como valor para o parâmetro `ACRESCIMO`:
       ```sql
       to_char(DATA_HORA, 'FF1')
       ```
3. Fazer a inserção do login na tabela **LOGIN**.
4. Fazer a inserção do acesso na tabela **ACESSO**, utilizando o valor de `DATA_HORA` acima.

#### 5. Procedure `PR_VALIDA_LOGIN()`
- Deve receber como parâmetros:
  - `LOGIN`
  - `SENHA`

A procedure deverá:

1. Certificar que o `LOGIN` exista na tabela **LOGIN**.
2. Usar a função `FN_DESCRIPTOGRAFIA()` para desembaralhar a senha passada pelo usuário.
   - **DICA**:
     - O valor de `ACRESCIMO` passado no parâmetro deve ser recuperado do campo `DATA_HORA` da tabela **ACESSO** referente ao `LOGIN` informado pelo usuário.
3. Caso as senhas sejam iguais:
   1. Atualizar o valor do campo `SENHA` na tabela **LOGIN** usando o novo valor de `ACRESCIMO` (momento atual).
   2. Atualizar o campo `DATA_HORA` na tabela **ACESSO** com o mesmo valor usado para o `ACRESCIMO`.
4. Emitir uma mensagem compatível.
