# Portable-LLM: Ollama on-the-go

Este projeto permite transformar qualquer dispositivo de armazenamento removível (Pendrive, SSD Externo, SD Card) em um ambiente completo e isolado para execução de Modelos de Linguagem de Grande Escala (LLMs).

Diferente de uma instalação padrão que espalha binários e modelos pelo sistema hospedeiro, o Portable-LLM centraliza tudo no seu dispositivo portátil, permitindo que você leve suas IAs e históricos para qualquer máquina Linux.

## 🛠️ Requisitos de Sistema

    Armazenamento: Mínimo de 8GB (Recomendado: 16GB+ para modelos como Llama 3 ou Mistral).

    Sistema de Arquivos: O dispositivo deve estar formatado em EXT4. Sistemas como FAT32 ou exFAT não suportam as permissões de execução e links simbólicos necessários.

    SO Hospedeiro: Debian, Ubuntu ou distribuições baseadas (recomenda-se o uso de Kernel estável).

## 🧠 Como Funciona

O script de automação realiza uma "instalação agnóstica de caminho" (Path-agnostic). Em vez de utilizar os diretórios padrão do sistema (/usr/bin ou /var/lib/ollama), ele remapeia as variáveis de ambiente do Ollama para o diretório raiz do seu pendrive.
Estrutura Gerada:

    run.sh: Inicializa o servidor Ollama (ollama serve) configurando o OLLAMA_MODELS para o diretório local.

    ollama-cli.sh: Um wrapper para interagir com o servidor sem precisar instalar nada no sistema local.

## 🚀 Instalação e Uso
  1. Preparação

  Mova o arquivo setup_ollama_linux.sh para a raiz do seu dispositivo portátil. Abra o terminal na pasta e conceda permissão de execução:
  
    chmod +x setup_ollama_linux.sh

  2. Setup

  Execute o script de configuração. Ele detectará a arquitetura do sistema, baixará o binário oficial do Ollama e preparará a estrutura de diretórios:

    ./setup_ollama_linux.sh

  3. Execução

  Para utilizar, você precisará de dois terminais abertos na raiz do dispositivo:

  Terminal 1 (Servidor):
  Inicie o motor do Ollama.
  
    ./run.sh

  Terminal 2 (Interação):
  Agora você pode baixar e rodar modelos. Eles serão salvos dentro do pendrive.

    ./ollama-cli.sh pull dolphin-llama3
    ./ollama-cli.sh run dolphin-llama3

## 🛠️ Comandos Úteis do Ollama

Comando	        Descrição
list          	Lista os modelos instalados no pendrive.
ps	            Exibe os modelos que estão carregados na memória.
rm <modelo>	    Remove um modelo para liberar espaço no dispositivo.

Contribuições são bem-vindas! Sinta-se à vontade para abrir uma Issue ou enviar um Pull Request.
