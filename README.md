# PS2 Classics Tool

Fork de [`sdkmap/PS2Classics`](https://github.com/sdkmap/PS2Classics), ferramenta de linha de comando originalmente publicada por +ps3dev-net para criptografar e descriptografar imagens e arquivos de memory card do PS2 usados no PS3.

> **Sobre este fork:** este repositório contém a versão de linha de comando do projeto original. Ele não inclui interface gráfica, gerador de PKG, jogos, ISOs, licenças ou chaves. Para a versão Linux com interface gráfica e integração com `pop-fe2`, consulte [PS2Classics-for-Linux](https://github.com/alex-dev404/PS2Classics-for-Linux).

## Recursos

- Criptografar uma ISO de PS2 para o formato de dados PS2 Classics.
- Descriptografar os dados de uma imagem PS2 Classics.
- Criptografar VMC e descriptografar VME para VMC.
- Preparar uma imagem e exibir informações de uma imagem compatível.
- Selecionar modo `cex` ou `dex` nas operações que o aceitam.

Este programa manipula arquivos de dados; ele não monta um pacote `.pkg` completo. A versão Linux vinculada acima adiciona interface gráfica, fluxo de geração de PKG via `pop-fe2` e instruções próprias.

## Compilação

O workflow deste fork compila para Windows usando MinGW-w64/MSYS2. Para reproduzir o build no Windows:

1. Instale [MSYS2](https://www.msys2.org/) e abra o terminal **MINGW64**.
2. Instale as ferramentas de build:

   ```bash
   pacman -Syu
   pacman -S --needed git make mingw-w64-x86_64-toolchain
   ```

3. Clone este repositório e compile:

   ```bash
   git clone https://github.com/alex-dev404/PS2ClassicsLinux.git
   cd PS2ClassicsLinux/ps2classic-ps2classic
   make
   ```

O executável compilado fica na pasta `ps2classic-ps2classic` (normalmente `ps2classic.exe` no ambiente MinGW). O workflow **C/C++ CI** também compila essa versão em cada push ou pull request para `main`; os arquivos de Windows ficam em **Actions → execução → Artifacts** quando a execução termina com sucesso.

### Linux

A compilação de Linux mantida e testada para este projeto está no repositório [PS2Classics-for-Linux](https://github.com/alex-dev404/PS2Classics-for-Linux). Consulte o README de lá para os requisitos Linux, os testes, o pacote para download e o uso da interface gráfica. O workflow deste fork é de Windows/MinGW e não publica um binário Linux.

## Uso da linha de comando

Execute `ps2classic` sem argumentos para exibir a ajuda:

```bash
./ps2classic.exe
```

Os comandos aceitos são:

```text
ps2classic d  [cex|dex] [klicensee] [imagem criptografada] [arquivo data] [arquivo meta]
ps2classic e  [cex|dex] [klicensee] [ISO] [arquivo data] [nome real] [CID]
ps2classic vd [cex|dex] [arquivo VME] [arquivo VMC de saída] [EID Root Key opcional]
ps2classic ve [cex|dex] [arquivo VMC] [arquivo VME de saída] [EID Root Key opcional]
ps2classic prepare [arquivo de imagem]
ps2classic info [arquivo de imagem]
```

### Criptografar uma ISO

Exemplo de formato (substitua caminhos e metadados pelos valores apropriados):

```bash
./ps2classic.exe e cex klicensee.bin jogo.iso jogo.data "Nome do jogo" UP0000-EXEMPLO00000_00-0000000000000000
```

`klicensee.bin` deve conter a chave binária esperada pela operação. O modo é `cex` ou `dex`. Informe o nome real associado ao conteúdo e o Content ID (CID) nos formatos requeridos pelo uso pretendido.

### Descriptografar uma imagem PS2 Classics

```bash
./ps2classic.exe d cex klicensee.bin jogo.BIN.ENC jogo.data jogo.meta
```

A operação grava separadamente os arquivos de dados e metadados nos caminhos informados.

### VMC e VME

```bash
./ps2classic.exe ve cex memory-card.vmc memory-card.vme
./ps2classic.exe vd cex memory-card.vme memory-card-restaurado.vmc
```

A EID Root Key é opcional para estes comandos; quando informada, use o arquivo binário no formato esperado pelo programa (48 bytes). Sem ela, o código usa uma chave zerada. Confirme que essa opção corresponde ao seu caso antes de usar os arquivos resultantes.

### Preparar e inspecionar imagens

```bash
./ps2classic.exe info imagem
./ps2classic.exe prepare imagem
```

`info` exibe informações da imagem. `prepare` altera o arquivo indicado; faça uma cópia de segurança antes de executá-lo.

## GitHub Actions

O arquivo [`.github/workflows/ci.yml`](.github/workflows/ci.yml) automatiza o build Windows/MinGW para `push`, pull request em `main` e execução manual. Os artefatos de Actions têm prazo de retenção definido pelo GitHub; faça download pela página da execução concluída.

## Créditos, origem e licença

- Código original: `ps2classic` por +ps3dev-net; página histórica: http://gitorious.ps3dev.net/ps2classic.
- Este fork parte de [`sdkmap/PS2Classics`](https://github.com/sdkmap/PS2Classics).
- Algoritmos de descriptografia são creditados no código-fonte a `flatz`.
- A licença do projeto é GNU General Public License versão 3; leia [`GPLv3.txt`](GPLv3.txt) antes de redistribuir ou modificar o código.

## Aviso

Use o programa somente com jogos, imagens e dados que você tenha autorização para utilizar. Este projeto não fornece conteúdo de jogos nem chaves pessoais. O funcionamento de um título depende da configuração usada e da compatibilidade específica do jogo; o sucesso de um teste isolado não garante compatibilidade geral.

---

[Fork Linux mantido por alex-dev404](https://github.com/alex-dev404/PS2Classics-for-Linux) · [Repositório original](https://github.com/sdkmap/PS2Classics)
