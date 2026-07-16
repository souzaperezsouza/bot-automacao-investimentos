# bot-de-automacao-investimentos
TUTORIAL - DEPLOY DO BOT DE INVESTIMENTOS (RENDER + GITHUB)


PARTE 1 - REPOSITORIO NO GITHUB


1. Crie uma conta no GitHub (github.com) se ainda nao tiver.
2. Clique em "New repository".
3. De um nome (ex: bot-investimentos), marque como Privado (recomendado,
   ja que o codigo mexe com dinheiro e credenciais de infraestrutura).
4. NAO faca commit de nenhum arquivo com token, senha ou DATABASE_URL
   dentro. O bot_investimentos.py ja le tudo via os.environ, entao ele
   e seguro para subir do jeito que esta.
5. Crie um arquivo .gitignore na raiz do repositorio com pelo menos:

   .env
   __pycache__/
   *.pyc

6. Suba o codigo:
   git init
   git add .
   git commit -m "versao inicial do bot de investimentos"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/bot-investimentos.git
   git push -u origin main


PARTE 2 - CONTA E PROJETO NO RENDER


1. Crie uma conta em render.com (pode logar com GitHub, facilita a
   conexao do repositorio).
2. No dashboard, clique em "New +" > "Web Service".
3. Conecte sua conta do GitHub e selecione o repositorio criado na
   Parte 1.
4. Configure o servico:
   - Name: bot-investimentos (ou o nome que preferir)
   - Region: escolha uma proxima do Brasil (ex: Oregon mesmo serve,
     nao ha regiao Render no Brasil ainda; a latencia nao afeta o bot)
   - Branch: main
   - Runtime: Python 3
   - Build Command: pip install -r requirements.txt
   - Start Command: python bot_investimentos.py
   - Plan: Free (ou pago, se quiser evitar o sono do free apos
     inatividade)
5. NAO clique em "Create Web Service" ainda - primeiro crie o banco
   de dados na Parte 3, porque voce vai precisar da URL dele nas
   variaveis de ambiente deste servico.


============================================
PARTE 3 - CRIAR O BANCO DE DADOS (POSTGRES) NO RENDER
============================================

1. No dashboard do Render, clique em "New +" > "PostgreSQL".
2. De um nome (ex: bot-investimentos-db).
3. Plan: Free.
4. ATENCAO: o banco Postgres gratuito do Render expira automaticamente
   depois de 30 dias e e apagado. E por isso que este tutorial tem a
   Parte 6 (migracao de fim de mes) - voce precisa recriar o banco
   periodicamente antes que ele expire, migrando os dados para o novo.
5. Apos criado, na pagina do banco voce vai ver duas conexoes:
   - Internal Database URL: so funciona entre servicos DENTRO do
     Render (ex: seu Web Service conversando com esse banco). Mais
     rapida e nao conta no limite de conexoes externas.
   - External Database URL: funciona de qualquer lugar, inclusive do
     seu computador. E a que voce vai usar para rodar scripts de
     migracao pelo cmd.



PARTE 4 - VARIAVEIS DE AMBIENTE NO RENDER


1. Volte para o Web Service criado na Parte 2 (ou finalize a criacao
   dele agora que o banco existe).
2. Va em "Environment" (ou "Environment Variables").
3. Adicione:

   TELEGRAM_BOT_TOKEN = (o token do seu bot, gerado no BotFather)
   DATABASE_URL = (cole aqui a INTERNAL Database URL do banco criado
                   na Parte 3 - o bot roda dentro do Render, entao usa
                   a interna)
   TZ = America/Sao_Paulo

4. O TZ = America/Sao_Paulo garante que qualquer datetime.now() ou
   log gerado pelo bot use o horario de Brasilia, e nao UTC (que e o
   padrao dos servidores do Render). Isso evita que a "Data" de uma
   compra/venda registrada as 23h no Brasil va para o dia seguinte
   no banco.
5. Salve. O Render vai reiniciar o servico automaticamente com as
   novas variaveis.

IMPORTANTE: a External Database URL NAO vai numa variavel de ambiente
do Web Service. Ela e usada so quando voce quer acessar o banco de
FORA do Render - ou seja, do seu computador, na Parte 6.



PARTE 5 - CONFIRMANDO QUE O BOT ESTA NO AR


1. Va na aba "Logs" do Web Service no Render e veja se apareceu algo
   como "Application started" sem erros de conexao.
2. Abra o Telegram, mande /start para o bot e confirme que ele
   responde.



PARTE 6 - MIGRACAO DE FIM DE MES (ANTES DO BANCO GRATUITO EXPIRAR)


Objetivo: tirar todos os dados do banco antigo e colocar num banco
novo, sem perder historico, antes que o banco antigo (30 dias) seja
apagado pelo Render.

Pre-requisito: ter o PostgreSQL instalado no seu computador (so
precisa das ferramentas de linha de comando: pg_dump e psql/pg_restore
- nao precisa rodar um servidor Postgres local).

Passo 1: exportar os dados do banco ATUAL

No cmd (Prompt de Comando do Windows), NUNCA cole a External Database
URL direto no comando ou dentro de um arquivo .py que vai pro GitHub.
Em vez disso, defina como variavel de ambiente temporaria na sessao
do cmd:

   set DATABASE_URL_ANTIGA=postgres://usuario:senha@host-externo.render.com/nome_do_banco

(pegue esse valor na pagina do banco antigo no Render, campo
"External Database URL")

Depois rode o dump:

   pg_dump --dbname=%DATABASE_URL_ANTIGA% --format=custom --file=backup_investimentos.dump

Isso gera um arquivo backup_investimentos.dump na pasta atual do cmd,
com todas as tabelas (compras, vendas, proventos, configuracoes) e
dados.
Passo 2: criar o banco NOVO no Render

1. Repita a Parte 3 deste tutorial: "New +" > "PostgreSQL", novo nome
   (ex: bot-investimentos-db-2).
2. Pegue a External Database URL do banco NOVO.

Passo 3: importar os dados no banco NOVO 
Ainda no cmd:

   set DATABASE_URL_NOVA=postgres://usuario:senha@host-externo-novo.render.com/nome_do_banco

   pg_restore --dbname=%DATABASE_URL_NOVA% --no-owner --no-privileges backup_investimentos.dump

Se aparecer erro de "role does not exist" por causa do dono original
das tabelas, o parametro --no-owner ja resolve isso na maioria dos
casos.

Passo 4: apontar o bot pro banco novo

1. No Render, va no Web Service (o bot) > Environment.
2. Troque o valor de DATABASE_URL para a INTERNAL Database URL do
   banco NOVO (nao a external usada no cmd).
3. Salve - o Render reinicia o bot sozinho.
4. Teste no Telegram: manda /start e confere um relatorio de posicao
   pra ver se os dados vieram certo.

Passo 5: desativar o banco ANTIGO

1. So depois de confirmar que o bot esta lendo certinho do banco novo.
2. No Render, va no banco antigo > Settings > Delete Database.
3. Apague tambem o arquivo backup_investimentos.dump do seu
   computador se ele tiver dados sensiveis, ou guarde em local seguro
   fora do repositorio do GitHub.

Passo 6: limpar as variaveis temporarias do cmd 

   set DATABASE_URL_ANTIGA=
   set DATABASE_URL_NOVA=

Isso evita que as credenciais fiquem expostas na sessao do terminal
depois que voce terminar.



CHECKLIST RAPIDO DE SEGURANCA (releia isso todo mes)


[ ] Nenhum token ou DATABASE_URL escrito direto em arquivo .py
[ ] .gitignore cobre .env e qualquer arquivo de backup/dump
[ ] Variaveis temporarias do cmd (set X=valor) limpas apos o uso
[ ] Banco antigo so e deletado depois de confirmar o novo funcionando
[ ] Arquivo de backup (.dump) nao fica em pasta sincronizada com
    nuvem publica nem sobe pro GitHub

