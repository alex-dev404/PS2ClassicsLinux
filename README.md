# PS2 Classics para Linux

Este projeto reúne a ferramenta de linha de comando `ps2classic` e uma
interface gráfica para preparar e manipular imagens no formato PS2 Classics
usado no PlayStation 3. A versão atual foi testada em um PS3 e, conforme o
teste realizado neste projeto, o jogo funcionou corretamente.

O projeto é baseado no `ps2classic` de +ps3dev-net
([página original](http://gitorious.ps3dev.net/ps2classic)). A interface
gráfica, a integração com o `pop-fe2`, o instalador de atalho e a configuração
de compilação para Linux fazem parte deste repositório. A licença do código
abrangido é GNU GPL versão 3; consulte [GPLv3.txt](GPLv3.txt).

> **Importante:** a ferramenta não inclui jogos, imagens ISO, licenças ou
> chaves. Use somente jogos e dados que você tenha autorização para utilizar.
> A compatibilidade do jogo no PS3 depende do jogo, dos dados de configuração
> e das ferramentas externas usadas para gerar o pacote.

## O que o projeto faz

- Cria um pacote PS2 Classics completo (`.pkg`) a partir de uma ISO, usando
  o gerador externo `pop-fe2`.
- Criptografa e descriptografa imagens PS2 Classics.
- Criptografa VMC e descriptografa VME para VMC.
- Prepara imagens e exibe informações sobre elas.
- Oferece uma interface gráfica Linux baseada em Zenity.
- Mantém suporte de compilação para Windows/MinGW.

## Baixar a versão Linux

### Pacote da versão compilada neste computador

O arquivo
[`dist/ps2classics-linux-x86_64.tar.gz`](dist/ps2classics-linux-x86_64.tar.gz)
contém a versão Linux x86_64 já compilada neste computador, a interface
gráfica, o script de instalação do `pop-fe2`, o instalador de atalho e este
README. Depois que este repositório for enviado ao GitHub, baixe o arquivo
pela página do repositório: abra `dist/` e selecione o arquivo `.tar.gz`.

Para extrair e iniciar:

```bash
tar -xzf ps2classics-linux-x86_64.tar.gz
cd ps2classic-ps2classic
./ps2classic-gui
```

O pacote é destinado a Linux x86_64. A interface gráfica precisa do Zenity; a
opção de criar o PKG completo também precisa do `pop-fe2` e das ferramentas
auxiliares dele.

### Artefato compilado pelo GitHub Actions

O workflow **C/C++ CI** compila e testa a versão Linux em cada push para
`main`, pull request direcionado a `main` ou execução manual. Para baixar:

1. Abra **Actions** no GitHub e selecione a execução concluída do workflow.
2. Na área **Artifacts**, baixe `ps2classics-linux-x86_64`.
3. Extraia o `.tar.gz` e siga os passos de execução acima.

Os artefatos de uma execução do Actions são temporários e seguem o prazo de
retenção do GitHub. O arquivo em `dist/` é a cópia preparada neste projeto;
uma nova compilação no Actions será produzida a partir do código enviado ao
GitHub.

## Instalação e uso

### Requisitos

- Linux x86_64.
- GCC (ou compilador C compatível) e GNU Make para compilar a partir do código.
- Zenity para abrir a interface gráfica.
- Git, Python 3 com suporte a `venv`, Make e ferramentas de compilação para
  instalar os componentes externos do `pop-fe2`.

Em distribuições baseadas em Debian ou Ubuntu, instale o básico com:

```bash
sudo apt update
sudo apt install build-essential git make python3 python3-venv zenity
```

Os nomes dos pacotes podem variar em outras distribuições.

### Compilar a partir do código-fonte

Na raiz do repositório:

```bash
cd ps2classic-ps2classic
make
make check
```

O executável será criado em `ps2classic-ps2classic/ps2classic`. O comando
`make check` executa verificações de uso, sintaxe dos scripts e testes da
interface/instalador.

### Abrir a interface gráfica

Na raiz do repositório, compile primeiro e inicie a interface:

```bash
cd ps2classic-ps2classic
make
./ps2classic-gui
```

Se você baixou o pacote Linux, o executável já está incluído: basta extrair,
entrar na pasta `ps2classic-ps2classic` e executar `./ps2classic-gui`.

### Gerar um PKG para o PS3

Para fazer o processo completo, basta abrir a interface e clicar em
**“Gerar PKG PS2 Classics completo (requer pop-fe2)”**. Depois:

1. Selecione a ISO original do jogo.
2. Escolha onde salvar o arquivo `.pkg`.
3. Aguarde o `pop-fe2` concluir o processo e confira o resultado exibido.

O PKG completo é criado pelo `pop-fe2`; não é o mesmo que criptografar uma ISO
com a opção separada **“Criptografar ISO para PS2 Classics”**. O `pop-fe2`
prepara também os metadados e a estrutura necessários ao pacote. O título,
os dados de configuração e a arte disponíveis dependem da base de dados do
`pop-fe2`.

Para instalar o gerador e seus auxiliares na pasta local do projeto, execute
na raiz:

```bash
./ps2classic-ps2classic/setup-pop-fe2.sh
```

O script baixa os componentes externos e instala as dependências Python
localmente, sem usar `sudo`. É necessário ter conexão com a Internet. Como
alternativa, instale o `pop-fe2` seguindo as instruções do
[projeto pop-fe2](https://github.com/sahlberg/pop-fe2). Se ele estiver em um
caminho personalizado, defina `POP_FE2` ao iniciar a interface, por exemplo:

```bash
POP_FE2=/caminho/para/pop-fe2.py ./ps2classic-ps2classic/ps2classic-gui
```

### Instalar um atalho no menu do desktop

Na raiz do repositório, execute:

```bash
./install-desktop.sh
```

O atalho é instalado no diretório local de aplicações do usuário. Isso não
instala o `pop-fe2`; ele continua sendo um requisito separado para a criação
do PKG completo.

## Uso pela linha de comando

Execute o programa sem argumentos para exibir a ajuda:

```bash
cd ps2classic-ps2classic
./ps2classic
```

Operações disponíveis:

```text
ps2classic d [cex/dex] [klicensee] [imagem criptografada] [arquivo data] [arquivo meta]
ps2classic e [cex/dex] [klicensee] [iso] [arquivo data] [nome real] [CID]
ps2classic vd [cex/dex] [arquivo vme] [arquivo vmc] [eid root key opcional]
ps2classic ve [cex/dex] [arquivo vmc] [arquivo vme] [eid root key opcional]
ps2classic prepare [arquivo de imagem]
ps2classic info [arquivo de imagem]
```

Os arquivos de chave esperados pelo programa devem ter o tamanho exigido pela
operação. A interface valida os tamanhos de `klicensee` (16 bytes) e EID Root
Key (48 bytes) antes de iniciar as operações correspondentes.

## Compilação contínua (GitHub Actions)

O workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) executa
`make` e `make check` no Linux, empacota o executável e os arquivos necessários
à interface e publica o pacote Linux como artefato da execução. Ele também
mantém a compilação Windows/MinGW.

Para obter o arquivo de uma compilação no GitHub, use o artefato da execução
em **Actions** conforme descrito acima. Para publicar o repositório ou os
artefatos, configure um remoto GitHub e envie os commits; este checkout local
não tem um remoto configurado.

## Limitações e solução de problemas

- **“A interface gráfica precisa do Zenity”**: instale o pacote `zenity` da
  sua distribuição.
- **“O programa ainda não foi compilado”**: entre em
  `ps2classic-ps2classic` e rode `make`.
- **O item de gerar PKG informa que `pop-fe2` não está instalado**: execute
  `./ps2classic-ps2classic/setup-pop-fe2.sh` na raiz ou configure `POP_FE2`.
- **O processo de PKG falha ou não encontra dados do jogo**: confirme que o
  `pop-fe2` e seus auxiliares foram instalados e que há acesso à rede quando
  necessário; os dados disponíveis dependem da base de dados externa.
- **Um jogo não funciona no console**: testar um jogo não garante
  compatibilidade universal; confira também a configuração/compatibilidade
  específica daquele título.

## Créditos e licença

- Ferramenta original: `ps2classic` por +ps3dev-net.
- Gerador de pacotes: [`pop-fe2`](https://github.com/sahlberg/pop-fe2), projeto
  externo com licença e termos próprios.
- Código deste projeto: GNU General Public License version 3. Veja
  [GPLv3.txt](GPLv3.txt).
