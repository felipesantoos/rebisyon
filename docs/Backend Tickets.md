# Tickets de Backend - Sistema Anki

## Setup e Infraestrutura

Criar estrutura de diretórios seguindo arquitetura hexagonal
Configurar Docker e docker-compose.yml
Configurar variáveis de ambiente e arquivo .env.example
Configurar logging estruturado com slog
Configurar conexão com PostgreSQL
Configurar conexão com Redis
Criar sistema de migrations com golang-migrate
Implementar health check endpoint
Configurar rate limiting middleware
Implementar request ID middleware
Configurar CORS middleware
Implementar error handling middleware
Criar sistema de configuração via variáveis de ambiente
Configurar graceful shutdown
Implementar connection pooling para PostgreSQL
Configurar Redis para cache e sessões
Criar sistema de jobs em background
Implementar event bus para domain events
Configurar storage adapter (local e S3)
Criar sistema de métricas (Prometheus)
Implementar tracing de requisições

## Autenticação e Autorização

Implementar registro de usuário
Implementar login com JWT
Implementar refresh token
Implementar logout
Implementar verificação de email
Implementar confirmação de email via token
Implementar recuperação de senha
Implementar redefinição de senha
Implementar alteração de senha
Implementar middleware de autenticação
Implementar validação de JWT tokens
Implementar rotação de refresh tokens
Implementar invalidação de tokens no logout
Implementar múltiplas sessões simultâneas
Implementar isolamento de dados por usuário
Implementar validação de ownership de recursos

## Gerenciamento de Usuários

Implementar obtenção de perfil do usuário
Implementar atualização de perfil
Implementar criação de deck Default para novo usuário
Implementar soft delete de usuários
Implementar validação de email único
Implementar validação de unicidade de email no registro
Implementar validação de força de senha (mínimo 8 caracteres, letra e número)
Implementar hash de senha com bcrypt
Implementar tracking de último login

## Decks

Implementar criação de deck
Implementar listagem de decks
Implementar obtenção de deck por ID
Implementar atualização de deck
Implementar exclusão de deck
Implementar hierarquia de decks (subdecks)
Implementar reorganização de decks
Implementar obtenção de opções do deck
Implementar atualização de opções do deck
Implementar criação de preset de opções
Implementar listagem de presets
Implementar atualização de preset
Implementar exclusão de preset
Implementar aplicação de preset a múltiplos decks
Implementar cálculo de estatísticas do deck
Implementar contadores de cards por estado
Implementar validação de nome único de deck
Implementar validação de nome único de deck por nível hierárquico
Implementar validação de deck não pode conter apenas "::"
Implementar mover cards antes de excluir deck
Implementar oferta de mover cards antes de excluir deck
Implementar não excluir deck pai automaticamente ao excluir subdeck
Implementar criação de backup antes de exclusão

## Notes

Implementar criação de note
Implementar listagem de notes
Implementar obtenção de note por ID
Implementar atualização de note
Implementar exclusão de note
Implementar busca simples de notes
Implementar busca avançada com sintaxe Anki
Implementar busca por tags
Implementar busca por deck
Implementar busca por note type
Implementar busca com regular expressions
Implementar busca ignorando acentos
Implementar criação de cópia de note
Implementar endpoint POST /notes/:id/copy (criar cópia de note)
Implementar encontrar duplicatas
Implementar endpoint POST /notes/find-duplicates (encontrar duplicatas)
Implementar detecção de duplicatas baseada no primeiro campo
Implementar duplicatas detectadas pelo primeiro campo ou GUID
Implementar exportar notes selecionadas
Implementar endpoint POST /notes/export (exportar notes selecionadas)
Implementar recuperar exclusões recentes
Implementar endpoint GET /notes/deletions (recuperar exclusões recentes)
Implementar restaurar exclusão
Implementar endpoint POST /notes/deletions/:id/restore (restaurar exclusão)
Implementar geração automática de GUID
Implementar validação de campos obrigatórios
Implementar validação de primeiro campo sempre obrigatório
Implementar atualização automática de cards relacionados

## Cards

Implementar listagem de cards
Implementar obtenção de card por ID
Implementar informações detalhadas do card
Implementar atualização de flag do card
Implementar enterrar card
Implementar desenterrar card
Implementar suspender card
Implementar dessuspender card
Implementar resetar card
Implementar definir data de vencimento
Implementar listar leeches
Implementar reposicionar cards
Implementar endpoint POST /cards/reposition (reposicionar cards)
Implementar obter posição de card
Implementar endpoint GET /cards/:id/position (obter posição de card)
Implementar geração automática de cards baseado em note type
Implementar validação de front template não vazio
Implementar não gerar card se front template resultar em vazio
Implementar card não é gerado se front template resultar em vazio
Implementar conditional replacements no front template controlam geração
Implementar detecção de empty cards
Implementar regeneração de cards ao editar note

## Note Types

Implementar criação de note type
Implementar listagem de note types
Implementar obtenção de note type por ID
Implementar atualização de note type
Implementar exclusão de note type
Implementar clonar note type
Implementar endpoint POST /note-types/:id/clone (clonar note type)
Implementar preview de card
Implementar endpoint POST /note-types/:id/preview (preview de card)
Implementar adicionar campo ao note type
Implementar remover campo do note type
Implementar renomear campo
Implementar reordenar campos
Implementar configurar propriedades do campo
Implementar adicionar card type
Implementar remover card type
Implementar editar front template
Implementar editar back template
Implementar editar styling CSS
Implementar configurar browser appearance
Implementar validação de sintaxe de templates
Implementar detecção de conflitos de templates
Implementar detecção de conflitos de cloze
Implementar configurar deck override para card type
Implementar validação de note type em uso antes de excluir

## Sistema de Estudo

Implementar overview do deck
Implementar iniciar sessão de estudo
Implementar obter próximo card
Implementar responder card
Implementar finalizar sessão
Implementar obter card anterior
Implementar endpoint GET /study/previous-card (obter card anterior)
Implementar criar cópia durante estudo
Implementar endpoint POST /study/create-copy (criar cópia durante estudo)
Implementar undo de operação
Implementar endpoint POST /study/undo (undo)
Implementar redo de operação
Implementar endpoint POST /study/redo (redo)
Implementar configurar auto-advance
Implementar endpoint POST /study/auto-advance (configurar auto-advance)
Implementar iniciar timebox
Implementar endpoint POST /study/timebox/start (iniciar timebox)
Implementar finalizar timebox
Implementar endpoint POST /study/timebox/end (finalizar timebox)
Implementar cálculo de próximo intervalo
Implementar atualização de estado do card
Implementar registro de revisão
Implementar enterrar siblings automaticamente
Implementar enterrar siblings automaticamente respeitando prioridade
Implementar learning cards têm prioridade sobre reviews
Implementar não enterrar cards em learning (time-critical)
Implementar desenterrar cards automaticamente no próximo dia
Implementar respeitar limites diários
Implementar respeitar ordem de exibição configurada
Implementar aplicar learning steps
Implementar aplicar relearning steps
Implementar respeitar learn ahead limit
Implementar calcular tempo gasto por card

## Algoritmos de Repetição Espaçada

Implementar algoritmo SM-2
Implementar cálculo de intervalo SM-2
Implementar cálculo de intervalo SM-2 com todas as regras específicas
Implementar ajuste de ease factor SM-2
Implementar ajuste de ease factor SM-2 (Again diminui, Easy aumenta)
Implementar aplicação de interval modifier
Implementar aplicação de fuzz factor (±25% do intervalo)
Implementar aplicação de easy bonus
Implementar aplicação de hard interval
Implementar aplicação de new interval após lapse
Implementar respeitar maximum interval
Implementar garantir mínimo de 1 dia entre intervalos
Implementar algoritmo FSRS
Implementar cálculo de intervalo FSRS
Implementar atualização de stability FSRS
Implementar atualização de difficulty FSRS
Implementar cálculo de retrievability FSRS
Implementar otimização de parâmetros FSRS
Implementar avaliação de qualidade dos parâmetros FSRS
Implementar simulação de workload futuro FSRS
Implementar reschedule cards ao mudar desired retention
Implementar historical retention para gaps
Implementar ignorar cards revisados antes de data específica
Implementar otimizar todos os presets de uma vez
Implementar calcular minimum recommended retention

## Media

Implementar upload de media
Implementar obtenção de media por ID
Implementar download de media
Implementar endpoint GET /media/:id/download (download de media)
Implementar exclusão de media
Implementar exclusão de media move para lixeira
Implementar verificar media não utilizada
Implementar endpoint GET /media/check (verificar media não utilizada)
Implementar limpar media não utilizada
Implementar endpoint POST /media/cleanup (limpar media não utilizada)
Implementar geração de hash SHA-256 para deduplicação
Implementar media identificada por hash SHA-256 para deduplicação
Implementar validação de formato e tamanho
Implementar validação de formatos e tamanho máximo de media
Implementar media não utilizada pode ser detectada e excluída
Implementar media usada em templates não é considerada não utilizada
Implementar associação de media a notes
Implementar detecção de referências em templates
Implementar tag notes com media faltante
Implementar esvaziar trash folder de media
Implementar adicionar media manualmente à pasta
Implementar geração de thumbnails para imagens
Implementar validação de integridade de arquivos
Implementar renderização de LaTeX
Implementar renderização de MathJax
Implementar validação de sintaxe LaTeX
Implementar suporte a pacotes LaTeX customizados

## Busca

Implementar busca simples por texto
Implementar busca por campo específico
Implementar busca por tags
Implementar busca por deck
Implementar busca por estado
Implementar busca por propriedades
Implementar busca com operadores lógicos
Implementar busca com regular expressions
Implementar busca ignorando acentos
Implementar busca por flag
Implementar busca por data
Implementar parser de sintaxe Anki
Implementar salvar busca
Implementar endpoint POST /search/saved (salvar busca)
Implementar listar buscas salvas
Implementar endpoint GET /search/saved (listar buscas salvas)
Implementar editar busca salva
Implementar endpoint PUT /search/saved/:id (editar busca salva)
Implementar excluir busca salva
Implementar endpoint DELETE /search/saved/:id (excluir busca salva)
Implementar aplicar busca salva
Implementar busca simples une múltiplos termos com AND
Implementar operadores lógicos OR e NOT na busca
Implementar busca em campo específico requer match exato por padrão
Implementar wildcards podem ser usados para busca parcial
Implementar otimização de queries de busca
Implementar índice full-text para busca

## Estatísticas

Implementar estatísticas do deck
Implementar estatísticas da coleção
Implementar estatísticas do card
Implementar gráfico de reviews por dia
Implementar gráfico de tempo gasto
Implementar distribuição de intervalos
Implementar distribuição de ease factors
Implementar distribuição de stability FSRS
Implementar distribuição de difficulty FSRS
Implementar distribuição de retrievability FSRS
Implementar breakdown por hora do dia
Implementar gráfico de answer buttons
Implementar tabela de true retention
Implementar cálculo de retention
Implementar cálculo de daily load
Implementar daily load soma 1/intervalo para todos os cards
Implementar forecast de cards futuros
Implementar calendário de atividade
Implementar cache de estatísticas
Implementar agregação por período

## Sincronização

Implementar status de sincronização
Implementar upload de mudanças
Implementar download de mudanças
Implementar sincronização completa
Implementar detecção de mudanças locais
Implementar detecção de mudanças remotas
Implementar mesclagem automática de mudanças
Implementar detecção de conflitos
Implementar detecção de conflitos não mescláveis requer escolha manual
Implementar objeto mais recente vence em conflito mesclável
Implementar resolução de conflitos
Implementar sincronização de media
Implementar rastreamento de USN
Implementar sincronização automática
Implementar sincronização periódica
Implementar sincronização ao abrir/fechar
Implementar versionamento de objetos
Implementar histórico de modificações
Implementar suporte a múltiplos dispositivos
Implementar rastreamento de último sync por dispositivo
Implementar forçar upload
Implementar forçar download

## Importação e Exportação

Implementar importação de texto CSV/TSV
Implementar mapeamento de colunas para campos
Implementar detecção de duplicatas na importação
Implementar importação de deck package APKG
Implementar importação de collection package COLPKG
Implementar importação de media junto com dados
Implementar validação de dados antes de importar
Implementar suporte a headers no arquivo de texto
Implementar suporte a colunas especiais
Implementar escolher comportamento para duplicatas
Implementar exportação de deck como texto
Implementar exportação de deck como APKG
Implementar exportação de coleção como COLPKG
Implementar incluir scheduling information opcional
Implementar scheduling information importada apenas se solicitado
Implementar incluir media nos packages
Implementar remover tags de leech/marked ao exportar
Implementar tags leech e marked removidas ao exportar para compartilhar
Implementar escolher formato de package

## Preferências

Implementar obtenção de preferências
Implementar atualização de preferências
Implementar configuração de idioma
Implementar configuração de tema
Implementar configuração de auto sync
Implementar configuração de horário de início do dia
Implementar configuração de learn ahead limit
Implementar configuração de timebox time limit
Implementar configuração de video driver
Implementar configuração de tamanho da UI
Implementar configuração de modo minimalista
Implementar configuração de redução de movimento
Implementar configuração de comportamento de paste
Implementar configuração de busca
Implementar configuração de default deck behavior
Implementar configuração de show play buttons
Implementar configuração de interrupt audio on answer
Implementar configuração de show remaining count
Implementar configuração de show next review time
Implementar configuração de spacebar answers card
Implementar configuração de ignore accents in search
Implementar configuração de default search text
Implementar configuração de sync audio and images
Implementar configuração de periodically sync media
Implementar configuração de force one way sync
Implementar configuração de self-hosted sync server URL

## Backups

Implementar listagem de backups
Implementar criação de backup manual
Implementar restauração de backup
Implementar exclusão de backup
Implementar download de backup
Implementar backups automáticos periódicos
Implementar backup criado automaticamente a cada 30 minutos
Implementar criar backups automáticos a cada 30 minutos
Implementar manutenção de backups diários semanais e mensais
Implementar backups mantidos por período configurável
Implementar manter backups por pelo menos 30 dias
Implementar limpeza automática de backups antigos
Implementar criação de backup antes de operações destrutivas
Implementar backup criado antes de operações destrutivas
Implementar ao restaurar backup mudanças desde backup são perdidas
Implementar permitir recuperação point-in-time
Implementar criação de backup antes de importar COLPKG
Implementar criação de backup após one-way sync download
Implementar criação de backup após Check Database
Implementar desabilitar auto sync após restaurar backup
Implementar sistema desabilita auto sync após restaurar backup
Implementar exportar backup como COLPKG
Implementar testar restauração de backups regularmente
Implementar backups em múltiplas localizações geográficas

## Filtered Decks

Implementar criação de filtered deck
Implementar listagem de filtered decks
Implementar obtenção de filtered deck por ID
Implementar atualização de filtered deck
Implementar exclusão de filtered deck
Implementar reconstruir filtered deck
Implementar endpoint POST /filtered-decks/:id/rebuild (reconstruir filtered deck)
Implementar filtered deck move cards temporariamente do home deck
Implementar cards retornam ao home deck após estudo
Implementar rebuild reaplica busca e atualiza cards
Implementar rescheduling ajusta intervalos baseado em performance
Implementar aplicar filtros de busca
Implementar configurar limite de cards
Implementar configurar ordem de exibição
Implementar configurar rescheduling
Implementar habilitar segundo filtro
Implementar retornar cards aos home decks
Implementar usar steps do home deck ou customizados
Implementar tipos de custom study
Implementar aumentar limite de novos cards do dia
Implementar aumentar limite de reviews do dia
Implementar estudar cards esquecidos
Implementar estudar cards antecipadamente
Implementar preview de novos cards
Implementar estudar por estado ou tag

## Browser

Implementar configuração do browser
Implementar endpoint GET /browser/config (configuração do browser)
Implementar atualização de configuração do browser
Implementar endpoint PUT /browser/config (atualizar configuração do browser)
Implementar ordenar colunas
Implementar ordenar por múltiplas colunas
Implementar configurar colunas visíveis
Implementar redimensionar colunas
Implementar editar note inline
Implementar aplicar filtros visuais
Implementar buscar e substituir texto em lote
Implementar exportar resultados diretamente
Implementar visualizar cards relacionados
Implementar salvar configuração de colunas
Implementar mover cards selecionados para outro deck
Implementar exportar notes selecionadas
Implementar alternar entre Cards mode e Notes mode
Implementar Sidebar Search Tool
Implementar Sidebar Selection Tool
Implementar salvar buscas atuais na sidebar
Implementar editar items da sidebar
Implementar buscar item na sidebar tree
Implementar aplicar background color baseado em flag/suspended/marked

## Operações em Lote

Implementar operações em lote em múltiplos cards
Implementar adicionar tags em lote
Implementar remover tags em lote
Implementar definir tags em lote
Implementar mudar deck em lote
Implementar mudar note type em lote
Implementar suspender cards em lote
Implementar dessuspender cards em lote
Implementar enterrar cards em lote
Implementar desenterrar cards em lote
Implementar definir flag em lote
Implementar remover flag em lote
Implementar alternar marcação em lote
Implementar excluir em lote
Implementar buscar e substituir texto
Implementar endpoint POST /batch/find-replace (buscar e substituir)
Implementar limpar tags não utilizadas
Implementar endpoint POST /batch/clear-unused-tags (limpar tags não utilizadas)
Implementar validação de ownership antes de operações em lote
Implementar endpoint POST /batch/operations (operações em lote)

## Flags e Leeches

Implementar sistema de flags
Implementar adicionar flag ao card
Implementar remover flag do card
Implementar alterar flag do card
Implementar buscar cards por flag
Implementar renomear flags
Implementar endpoint GET /flags (listar flags)
Implementar endpoint PUT /flags/:number (atualizar nome de flag)
Implementar detecção automática de leeches
Implementar detecção de leeches quando lapses atinge threshold
Implementar alertas periódicos de leeches (metade do threshold)
Implementar adicionar tag leech automaticamente
Implementar suspender card automaticamente quando leech
Implementar alertar usuário sobre leeches
Implementar visualizar lista de leeches
Implementar editar leech
Implementar excluir leech
Implementar suspender leech temporariamente
Implementar configurar threshold de leeches
Implementar configurar ações para leeches

## Shared Decks

Implementar listagem de shared decks
Implementar endpoint GET /shared-decks (listar shared decks)
Implementar obtenção de shared deck por ID
Implementar endpoint GET /shared-decks/:id (obter shared deck)
Implementar download de shared deck
Implementar endpoint POST /shared-decks/:id/download (download de shared deck)
Implementar avaliação de shared deck
Implementar endpoint POST /shared-decks/:id/rate (avaliar shared deck)
Implementar compartilhar deck
Implementar endpoint POST /shared-decks (compartilhar deck)
Implementar busca por categoria
Implementar busca por palavras-chave
Implementar filtrar por featured
Implementar ordenar por popularidade recente ou rating
Implementar visualizar preview do deck
Implementar importar deck compartilhado automaticamente
Implementar rastrear número de downloads
Implementar calcular rating médio
Implementar adicionar descrição e categoria
Implementar adicionar tags
Implementar tornar público ou privado
Implementar exibir estatísticas de downloads e ratings

## Add-ons

Implementar listagem de add-ons
Implementar endpoint GET /add-ons (listar add-ons)
Implementar instalação de add-on
Implementar endpoint POST /add-ons/install (instalar add-on)
Implementar atualização de add-on
Implementar endpoint PUT /add-ons/:id (atualizar add-on)
Implementar desinstalação de add-on
Implementar endpoint DELETE /add-ons/:id (desinstalar add-on)
Implementar add-ons são compartilhados entre perfis mas configurações são por perfil
Implementar habilitar add-on
Implementar desabilitar add-on
Implementar validar compatibilidade de add-ons
Implementar avisar sobre add-ons incompatíveis
Implementar configurar opções de add-ons
Implementar executar add-ons em sandbox
Implementar limitar recursos disponíveis para add-ons
Implementar validar código de add-ons antes de executar
Implementar prevenir acesso a dados de outros usuários
Implementar prevenir modificação de dados críticos sem permissão
Implementar desabilitar add-ons problemáticos automaticamente
Implementar logar ações de add-ons para auditoria

## Manutenção

Implementar verificação de integridade do banco
Implementar endpoint POST /maintenance/check-database (verificar banco)
Implementar verificar se arquivo foi corrompido
Implementar reconstruir estruturas internas
Implementar otimizar arquivo durante verificação
Implementar reportar problemas encontrados
Implementar sugerir restaurar backup se corrupção detectada
Implementar oferecer opção de reparar corrupção
Implementar listar empty cards
Implementar endpoint GET /maintenance/empty-cards (listar empty cards)
Implementar limpar empty cards
Implementar endpoint POST /maintenance/cleanup-empty-cards (limpar empty cards)
Implementar verificar media não utilizada
Implementar otimizar índices do banco
Implementar compactar banco de dados
Implementar endpoint POST /maintenance/optimize (otimizar banco)
Implementar executar verificação em background
Implementar mostrar progresso da verificação
Implementar permitir cancelar verificação
Implementar otimizar verificação para grandes coleções

## Profiles

Implementar criação de profile
Implementar endpoint POST /profiles (criar profile)
Implementar listagem de profiles
Implementar endpoint GET /profiles (listar profiles)
Implementar obtenção de profile por ID
Implementar endpoint GET /profiles/:id (obter profile)
Implementar atualização de profile
Implementar endpoint PUT /profiles/:id (atualizar profile)
Implementar exclusão de profile
Implementar endpoint DELETE /profiles/:id (excluir profile)
Implementar alternar profile
Implementar endpoint POST /profiles/:id/switch (alternar profile)
Implementar apenas um perfil pode sincronizar com conta AnkiWeb
Implementar restaurar backup automático do profile
Implementar fazer downgrade da coleção
Implementar validar apenas um profile sincronizado com AnkiWeb
Implementar manter coleções separadas por profile
Implementar compartilhar add-ons entre profiles
Implementar manter configurações de add-ons por profile
Implementar manter preferências por profile
Implementar backups por profile

## Self-Hosted Sync Server

Implementar configuração do servidor self-hosted
Implementar endpoint PUT /sync/server/config (configurar self-hosted server)
Implementar testar conexão com servidor self-hosted
Implementar endpoint POST /sync/server/test (testar conexão self-hosted)
Implementar obter configuração do servidor
Implementar endpoint GET /sync/server/config (obter configuração self-hosted)
Implementar remover configuração do servidor
Implementar endpoint DELETE /sync/server/config (remover configuração self-hosted)
Implementar validar URL do servidor
Implementar validar conexão antes de salvar
Implementar suportar HTTPS e HTTP
Implementar suportar subpath em reverse proxy
Implementar validar que servidor responde corretamente
Implementar configurar múltiplos usuários no servidor
Implementar configurar senhas hasheadas PHC Format
Implementar configurar localização de armazenamento
Implementar configurar acesso público ao servidor
Implementar configurar limites de requisições grandes
Implementar validar autenticação em todas as requisições
Implementar implementar rate limiting no servidor
Implementar validar tamanho de payloads
Implementar implementar timeout em requisições
Implementar logar tentativas de acesso não autorizado

## Templates e Styling

Implementar renderização de templates front
Implementar renderização de templates back
Implementar substituição de field replacements
Implementar processamento de conditional replacements
Implementar processamento de special fields
Implementar processamento de Text-to-Speech
Implementar processamento de Ruby characters
Implementar processamento de type in answer
Implementar processamento de hints
Implementar criar links de dicionário dinâmicos
Implementar processamento de HTML stripping
Implementar suporte a Right-to-Left text
Implementar processamento de múltiplos campos TTS
Implementar renderização de browser appearance
Implementar aplicação de CSS customizado
Implementar suporte a night mode styling
Implementar estilização por card type
Implementar estilização de campos individuais
Implementar estilização específica por plataforma
Implementar instalar fontes customizadas
Implementar fading automático ao mostrar resposta
Implementar scrolling automático para elemento com id=answer
Implementar configurar velocidade de fading
Implementar permitir JavaScript nos templates com avisos

## Funcionalidades Avançadas

Implementar suporte a Cloze deletions
Implementar geração de card para cada número de cloze
Implementar cada número de cloze gera card separado
Implementar suporte a nested cloze deletions
Implementar processamento de hints em cloze
Implementar suporte a múltiplos clozes no mesmo card
Implementar suporte a Type in Answer
Implementar comparação de resposta digitada
Implementar destacar diferenças
Implementar ignorar diacríticos se configurado
Implementar usar fonte monoespaçada
Implementar suporte a apenas uma comparação por card
Implementar suporte a apenas uma linha de texto
Implementar suporte a Text-to-Speech
Implementar detectar vozes disponíveis
Implementar listar todas as vozes disponíveis
Implementar ler campo automaticamente
Implementar ler múltiplos campos e texto estático
Implementar ler apenas cloze deletions
Implementar ajustar velocidade de fala
Implementar escolher voz preferida
Implementar suporte a Ruby Characters Furigana
Implementar renderizar furigana acima do texto
Implementar exibir apenas kana
Implementar exibir apenas kanji
Implementar processar múltiplas anotações ruby
Implementar respeitar espaços para posicionamento
Implementar suporte a Right-to-Left RTL
Implementar renderizar texto RTL corretamente
Implementar permitir configurar direção de texto no campo
Implementar aplicar direção RTL no template
Implementar suporte a RTL no editor
Implementar Unicode Normalization
Implementar normalizar texto para busca consistente
Implementar permitir desabilitar normalização
Implementar garantir compatibilidade entre sistemas
Implementar normalizar ao importar e sincronizar

## WebSocket e Real-time

Implementar conexão WebSocket
Implementar endpoint WS /ws (WebSocket)
Implementar manter conexão ativa com ping
Implementar enviar eventos de sincronização
Implementar enviar eventos de card atualizado
Implementar enviar eventos de note atualizada
Implementar enviar eventos de deck atualizado
Implementar autenticação via WebSocket
Implementar gerenciamento de múltiplas conexões
Implementar reconexão automática
Implementar tratamento de erros em WebSocket

## Performance e Otimização

Implementar paginação em todas as listagens
Implementar cache de queries frequentes
Implementar cache de estatísticas
Implementar cache de overview de decks
Implementar otimização de queries de estudo
Implementar uso eficiente de índices
Implementar lazy loading de media
Implementar lazy loading de cards durante estudo
Implementar lazy loading de estatísticas
Implementar otimização de transferência de dados
Implementar processamento assíncrono de operações pesadas
Implementar não bloquear interface durante operações longas
Implementar mostrar progresso para operações longas
Implementar permitir cancelamento de operações longas
Implementar otimização de queries de busca full-text
Implementar virtual scrolling para grandes datasets
Implementar renderizar apenas itens visíveis
Implementar carregar dados sob demanda ao fazer scroll
Implementar otimizar ordenação e filtros para grandes datasets
Implementar cachear resultados de busca no browser
Implementar permitir cancelar operações longas no browser
Implementar otimização de queries de estudo para milhares de cards
Implementar compressão de respostas gzip brotli
Implementar usar CDN para assets estáticos
Implementar implementar cache de browser apropriado
Implementar minimizar round-trips com batch requests

## Segurança e Validação

Implementar validação de todos os inputs
Implementar sanitização de dados antes de salvar
Implementar validação de templates antes de renderizar
Implementar validação de JavaScript custom scheduling em sandbox
Implementar validação de sintaxe de busca antes de executar
Implementar validação de formato de arquivos importados
Implementar proteção contra SQL injection
Implementar proteger contra SQL injection usar prepared statements
Implementar proteção contra XSS em templates
Implementar proteger contra XSS sanitizar inputs CSP headers
Implementar proteção contra CSRF
Implementar proteger contra CSRF tokens CSRF
Implementar proteger contra clickjacking X-Frame-Options
Implementar criptografar dados sensíveis em trânsito TLS 1.2+
Implementar criptografar dados sensíveis em repouso opcional
Implementar criptografar senhas com hash seguro
Implementar criptografar senhas usando algoritmos seguros bcrypt argon2
Implementar não armazenar senhas em texto plano
Implementar validar tokens JWT
Implementar usar JWT com expiração adequada 15 minutos para access token
Implementar sanitizar outputs para prevenir injection
Implementar garantir que usuários só acessem seus próprios dados
Implementar validar ownership de recursos antes de operações
Implementar logar tentativas de acesso não autorizado
Implementar rate limiting em todas as APIs
Implementar rate limiting 100 req/min por IP 1000 req/min por usuário
Implementar rate limiting por usuário
Implementar rate limiting por IP
Implementar retornar headers apropriados de rate limit
Implementar permitir configurar limites
Implementar timeout em requisições
Implementar implementar timeout em requisições 30s padrão
Implementar limitar tamanho de payloads
Implementar limitar tamanho de payloads 10MB para JSON 100MB para media
Implementar validar tipos de arquivo em uploads
Implementar escanear uploads por malware opcional
Implementar não compartilhar dados entre usuários
Implementar permitir exclusão completa de conta e dados
Implementar cumprir LGPD GDPR
Implementar logar acessos a dados pessoais
Implementar anonimizar dados em logs

## Logging e Debugging

Implementar registrar todas as operações importantes
Implementar registrar erros com stack traces
Implementar manter log de sincronização
Implementar manter log de deletions
Implementar usar logging estruturado JSON
Implementar rotacionar logs para evitar crescimento excessivo
Implementar permitir configurar nível de log
Implementar incluir contexto relevante user ID request ID
Implementar ter níveis de log apropriados
Implementar acessar debug console
Implementar exibir informações de debug
Implementar executar código de debug
Implementar visualizar estado interno do sistema
Implementar exportar informações de debug para suporte

## Testes

Implementar testes unitários para lógica de negócio
Implementar testes unitários para algoritmos de repetição espaçada
Implementar testes unitários para validações e transformações
Implementar testes de integração para APIs
Implementar testes de integração para banco de dados
Implementar testes de integração para sincronização
Implementar testes end-to-end para fluxos principais
Implementar testes de carga load testing
Implementar testes de stress stress testing
Implementar benchmarks para operações críticas
Implementar monitoramento de performance em produção
Implementar permitir mock de dependências externas
Implementar ter interfaces para facilitar testes
Implementar suportar testes em ambiente isolado
Implementar ter dados de teste reproduzíveis
Implementar cobertura mínima de 80% para código crítico

## Documentação

Implementar documentação da arquitetura
Implementar documentação da API OpenAPI Swagger
Implementar documentação de instalação e deploy
Implementar guias de desenvolvimento
Implementar diagramas de arquitetura e fluxos
Implementar documentar todos os endpoints
Implementar documentar modelos de dados
Implementar documentar códigos de erro
Implementar fornecer exemplos de requisições e respostas
Implementar manter changelog detalhado
Implementar documentar breaking changes
Implementar fornecer migração de dados entre versões

## Migrations e Schema SQL

Implementar migrations para todas as tabelas do schema
Implementar criar enums card_state review_type theme_type scheduler_type
Implementar criar tabela users com todos os campos e índices
Implementar criar tabela decks com todos os campos e índices
Implementar criar tabela note_types com todos os campos e índices
Implementar criar tabela notes com todos os campos e índices
Implementar criar tabela cards com todos os campos e índices
Implementar criar tabela reviews com todos os campos e índices
Implementar criar tabela media com todos os campos e índices
Implementar criar tabela note_media com todos os campos e índices
Implementar criar tabela sync_meta com todos os campos e índices
Implementar criar tabela user_preferences com todos os campos e índices
Implementar criar tabela backups com todos os campos e índices
Implementar criar tabela filtered_decks com todos os campos e índices
Implementar criar tabela deck_options_presets com todos os campos e índices
Implementar criar tabela deletions_log com todos os campos e índices
Implementar criar tabela saved_searches com todos os campos e índices
Implementar criar tabela flag_names com todos os campos e índices
Implementar criar tabela browser_config com todos os campos e índices
Implementar criar tabela undo_history com todos os campos e índices
Implementar criar tabela shared_decks com todos os campos e índices
Implementar criar tabela shared_deck_ratings com todos os campos e índices
Implementar criar tabela add_ons com todos os campos e índices
Implementar criar tabela check_database_log com todos os campos e índices
Implementar criar tabela profiles com todos os campos e índices
Implementar criar triggers para atualizar updated_at automaticamente
Implementar criar trigger para gerar GUID automaticamente para notes
Implementar criar trigger para logar exclusões de notes
Implementar criar funções para calcular due cards
Implementar criar funções para calcular new cards
Implementar criar funções para calcular learning cards
Implementar criar views deck_statistics
Implementar criar views card_info_extended
Implementar criar views empty_cards
Implementar criar views leeches
Implementar criar índices compostos para performance
Implementar criar índices parciais para registros ativos
Implementar criar constraints adicionais check constraints
Implementar configurar autovacuum para tabelas grandes
Implementar habilitar Row Level Security RLS
Implementar criar políticas de isolamento por usuário
Implementar criar tabela schema_migrations para versionamento

## Requisitos Não Funcionais - Escalabilidade

Implementar suporte a múltiplas instâncias do backend (load balancing)
Implementar sistema stateless exceto sessões WebSocket
Implementar permitir adicionar novos servidores sem downtime
Implementar distribuir carga uniformemente entre instâncias
Implementar suportar até 1.000.000 de cards por coleção
Implementar suportar até 100.000 cards por deck
Implementar suportar até 10GB de media por usuário
Implementar suportar até 500.000 notes por coleção
Implementar suportar até 10.000 decks por usuário
Implementar suportar mínimo de 1.000 usuários simultâneos
Implementar suportar crescimento de 10% ao mês sem refatoração
Implementar usar storage escalável S3 object storage
Implementar suportar crescimento ilimitado de media
Implementar compressão de media quando apropriado
Implementar deduplicação de media mesmo hash

## Requisitos Não Funcionais - Disponibilidade e Confiabilidade

Implementar 99.9% de disponibilidade máximo 43 minutos downtime por mês
Implementar ter uptime de 99.5% máximo 3.6 horas de downtime por mês
Implementar notificar usuários com 24h de antecedência de manutenção
Implementar recuperar de falhas em menos de 5 minutos
Implementar recuperar de falhas em menos de 10 minutos
Implementar continuar funcionando mesmo se alguns componentes falharem
Implementar circuit breakers para serviços externos
Implementar fallbacks para operações críticas
Implementar não perder dados mesmo em caso de falha
Implementar garantir consistência transacional ACID
Implementar validar integridade referencial
Implementar detectar e corrigir corrupção de dados
Implementar manter logs de auditoria para operações críticas
Implementar ter redundância de componentes críticos
Implementar ter failover automático quando possível
Implementar manter serviços essenciais durante manutenção
Implementar comunicar interrupções aos usuários
Implementar ter redundância de storage para dados de sincronização

## Requisitos Não Funcionais - Segurança Avançada

✅ Implementar implementar refresh tokens com rotação
Implementar implementar hashing seguro para media SHA-256
Implementar validar e sanitizar todos os inputs
Implementar implementar CORS apropriadamente
Implementar validar todos os parâmetros de entrada
Implementar retornar erros genéricos não expor detalhes internos
Implementar cumprir LGPD GDPR direito ao esquecimento
Implementar permitir acesso aos dados pessoais
Implementar permitir correção de dados
Implementar permitir exclusão completa de dados
Implementar notificar sobre uso de dados
Implementar ter política de privacidade clara

## Requisitos Não Funcionais - Performance

Implementar otimizar para baixa latência
Implementar otimizar tamanho de imagens
Implementar usar memória eficientemente
Implementar não vazar memória memory leaks
Implementar limitar uso de memória por requisição
Implementar otimizar operações computacionalmente intensivas
Implementar distribuir carga entre processos threads
Implementar monitorar uso de CPU
Implementar comprimir dados quando apropriado
Implementar limpar dados temporários regularmente
Implementar otimizar tamanho de banco de dados
Implementar minimizar tamanho de payloads
Implementar otimizar transferência de media
Implementar suportar download resumable retomar downloads
Implementar validar integridade de packages baixados
Implementar otimizar verificação para grandes coleções chunking
Implementar completar simulação de 365 dias em menos de 5 segundos para coleções com até 10.000 cards
Implementar otimizar simulação para grandes coleções chunking aproximações
Implementar executar simulação em background não bloquear UI
Implementar mostrar progresso da simulação
Implementar permitir cancelar simulação
Implementar cachear resultados de simulação para mesma configuração

## Requisitos Não Funcionais - Monitoramento e Observabilidade

Implementar coletar métricas de performance latência throughput
Implementar coletar métricas de negócio cards estudados usuários ativos
Implementar coletar métricas de erro taxa de erro tipos de erro
Implementar coletar métricas de recursos CPU memória storage
Implementar monitorar saúde do sistema health checks
Implementar alertar sobre problemas críticos
Implementar ter dashboards de monitoramento
Implementar rastrear requisições end-to-end tracing
Implementar alertar sobre erros críticos imediatamente
Implementar alertar sobre degradação de performance
Implementar alertar sobre problemas de disponibilidade
Implementar ter diferentes níveis de severidade
Implementar manter logs de sincronização para troubleshooting

## Requisitos Não Funcionais - Internacionalização e Localização

Implementar suportar múltiplos idiomas na interface
Implementar permitir mudança de idioma sem recarregar página
Implementar suportar RTL Right-to-Left para árabe hebraico
Implementar manter traduções atualizadas
Implementar suportar diferentes formatos de data hora
Implementar suportar diferentes formatos numéricos
Implementar suportar diferentes fusos horários
Implementar adaptar para convenções locais

## Requisitos Não Funcionais - Compatibilidade e Integração

Implementar fornecer API REST completa e bem documentada
Implementar suportar webhooks para eventos
Implementar permitir integrações de terceiros
Implementar manter compatibilidade de API versionamento
Implementar importar decks do Anki APKG sem perda de dados
Implementar importar coleções do Anki COLPKG
Implementar manter compatibilidade de formato ao exportar
Implementar suportar importação de scheduling data do Anki
Implementar funcionar em Chrome Firefox Safari Edge últimas 2 versões
Implementar funcionar via web em qualquer sistema operacional
Implementar adaptar UI para diferentes tamanhos de tela
Implementar suportar dispositivos móveis responsive design

## Requisitos Não Funcionais - Qualidade de Código

Implementar código limpo seguir boas práticas e padrões
Implementar código documentado comentários docstrings
Implementar seguir convenções de código Go TypeScript
Implementar código organizado em módulos reutilizáveis
Implementar separar claramente backend e frontend
Implementar usar arquitetura em camadas domain repository service api
Implementar manter baixo acoplamento entre componentes
Implementar permitir substituição de componentes
Implementar seguir princípios SOLID
Implementar usar versionamento semântico SemVer
Implementar manter changelog detalhado
Implementar documentar breaking changes
Implementar seguir style guides Go TypeScript
Implementar usar linters golangci-lint ESLint
Implementar usar formatters gofmt Prettier
Implementar ter code review obrigatório
Implementar manter código DRY Don't Repeat Yourself
Implementar permitir refatoração contínua
Implementar manter dívida técnica baixa
Implementar remover código morto regularmente
Implementar melhorar código existente

## Requisitos Não Funcionais - Configuração e Secrets

Implementar ter valores padrão sensatos
Implementar validar configuração na inicialização
Implementar documentar todas as opções de configuração
Implementar nunca commitar secrets no código
Implementar usar gerenciamento de secrets Vault AWS Secrets Manager
Implementar rotacionar secrets regularmente
Implementar ter diferentes secrets por ambiente

## Requisitos Não Funcionais - Disaster Recovery

Implementar plano de disaster recovery documentado
Implementar procedimentos de recuperação testados
Implementar backup de dados em múltiplas localizações
Implementar tempo de recuperação objetivo RTO menos de 4 horas
Implementar ponto de recuperação objetivo RPO menos de 1 hora

## Requisitos Não Funcionais - Acessibilidade

Implementar suportar navegação completa por teclado
Implementar ser compatível com leitores de tela ARIA labels
Implementar manter contraste mínimo de 4.5:1 para texto
Implementar fornecer textos alternativos para imagens
Implementar suportar zoom até 200% sem quebrar layout
Implementar seguir WCAG 2.1 Level AA
Implementar cumprir requisitos de acessibilidade WCAG 2.1 AA
Implementar ser acessível para pessoas com deficiência
Implementar fornecer alternativas para conteúdo não textual
Implementar fornecer atalhos para todas as ações principais
Implementar atalhos consistentes com padrões da plataforma
Implementar documentação de atalhos acessível

## Requisitos Não Funcionais - Usabilidade

Implementar exibir mensagens de erro claras e acionáveis
Implementar não usar jargão técnico para usuários finais
Implementar fornecer sugestões para resolver problemas
Implementar logar detalhes técnicos para desenvolvedores
Implementar fornecer tooltips para funcionalidades complexas
Implementar ter documentação acessível dentro da aplicação
Implementar fornecer exemplos e tutoriais
Implementar ter busca na documentação
Implementar manual do usuário completo
Implementar tutoriais e guias
Implementar FAQ Perguntas Frequentes
Implementar vídeos tutoriais opcional
Implementar help contextual
Implementar mostrar feedback imediato para ações do usuário
Implementar usar loading states apropriados
Implementar implementar optimistic updates quando possível
Implementar pre-carregar dados prováveis
Implementar manter design system consistente
Implementar usar componentes reutilizáveis
Implementar manter paleta de cores consistente
Implementar seguir princípios de design hierarquia espaçamento
Implementar confirmar ações destrutivas
Implementar mostrar mensagens de sucesso erro claras
Implementar fornecer progresso para operações longas
Implementar permitir desfazer ações quando apropriado

## Requisitos Não Funcionais - Deploy e Infraestrutura

Implementar ser deployável em diferentes ambientes dev staging prod
Implementar usar containers Docker para isolamento
Implementar suportar deploy em cloud providers AWS GCP Azure
Implementar minimizar dependências externas
Implementar usar versões específicas de dependências
Implementar manter dependências atualizadas security patches
Implementar documentar todas as dependências

## Requisitos Não Funcionais - Performance de UI

Implementar implementar virtual scrolling para grandes datasets 10.000+ itens
Implementar renderizar apenas itens visíveis na viewport
Implementar carregar dados sob demanda ao fazer scroll
Implementar otimizar ordenação e filtros para grandes datasets
Implementar cachear resultados de busca no browser
Implementar permitir cancelar operações longas no browser
Implementar manter histórico limitado máximo 50 operações ou 5MB
Implementar armazenar apenas diferenças deltas para economizar memória
Implementar executar undo redo em menos de 100ms
Implementar limpar histórico antigo automaticamente
Implementar não manter histórico de operações irreversíveis
Implementar renderizar equações LaTeX de forma assíncrona
Implementar cachear imagens LaTeX geradas mesmo hash
Implementar renderizar MathJax sem bloquear UI
Implementar limitar tempo de renderização timeout
Implementar usar web workers para processamento pesado quando possível
Implementar reproduzir áudio sem bloquear UI
Implementar suportar múltiplos áudios simultâneos
Implementar cachear áudio gerado quando possível
Implementar limitar tamanho de áudio gerado
Implementar interromper áudio rapidamente menos de 50ms
Implementar servir shared decks via CDN
Implementar cachear decks populares
Implementar comprimir packages antes de servir
Implementar usar CDN para distribuição de shared decks
Implementar cachear shared decks populares
Implementar comprimir packages de decks compartilhados

## Requisitos Não Funcionais - Preferências e Sincronização

Implementar preferências são por usuário não por dispositivo
Implementar preferências são sincronizadas entre dispositivos
Implementar preferências de deck são por deck ou preset
Implementar subdecks herdam opções do deck pai exceto limites diários

## Requisitos Não Funcionais - Manutenção e Verificação

Implementar executar verificação em background
Implementar não bloquear outras operações durante verificação
Implementar mostrar progresso da verificação
Implementar permitir cancelar verificação
