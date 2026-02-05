# Requisitos Funcionais - Sistema Anki Completo

Este documento descreve todos os requisitos funcionais do sistema Anki, organizados por área funcional.

## 1. Autenticação e Gerenciamento de Usuário

### RF-001: Registro de Usuário
O sistema DEVE permitir que novos usuários se registrem fornecendo:
- Email válido e único
- Senha com critérios de segurança (mínimo de caracteres, complexidade)
- Validação de email antes de ativação da conta

### RF-002: Login e Autenticação
O sistema DEVE:
- Autenticar usuários com email e senha
- Gerar tokens JWT para sessões autenticadas
- Suportar refresh tokens para renovação de acesso
- Invalidar tokens no logout
- Manter sessões ativas por período configurável

### RF-003: Gerenciamento de Perfil
O sistema DEVE permitir que usuários:
- Visualizem informações do perfil
- Alterem senha (com validação da senha atual)
- Configurem preferências globais

## 2. Gerenciamento de Decks

### RF-004: Criação e Edição de Decks
O sistema DEVE permitir:
- Criar novos decks com nome único por usuário
- Renomear decks existentes
- Organizar decks em hierarquia (subdecks)
- Reorganizar decks por drag-and-drop
- Editar opções e configurações do deck

### RF-005: Visualização de Decks
O sistema DEVE exibir:
- Lista hierárquica de todos os decks do usuário
- Contadores de cards por estado (New, Learning, Review) para cada deck
- Estatísticas resumidas de cada deck
- Ordenação alfabética dos decks

### RF-006: Opções de Deck
O sistema DEVE permitir configurar:
- Limite de novos cards por dia
- Limite máximo de reviews por dia
- Learning steps (atrasos entre repetições durante aprendizado)
- Graduating interval (primeiro intervalo após aprender)
- Easy interval (intervalo quando marcado como Easy)
- Relearning steps (para cards esquecidos)
- Minimum interval (intervalo mínimo após relearning)
- Display order (ordem de exibição de cards)
- Burying settings (enterramento de cards relacionados)
- Algoritmo de repetição espaçada (SM-2 ou FSRS)
- Parâmetros FSRS (se habilitado)
- Easy Days (ajuste de intervalos por dia da semana)
- Custom scheduling (código JavaScript customizado)
- Threshold e ações para leeches
- Configurações de áudio
- Configurações de timers
- Per-Deck Daily Limits (Preset, This deck, Today only)
- New Cards Ignore Review Limit (mostrar novos cards mesmo com limite de reviews atingido)
- Limits Start From Top (aplicar limites de decks superiores a subdecks)
- Insertion Order (aleatório ou sequencial para novos cards)
- Day Boundaries (tratamento diferente para steps pequenos vs steps que cruzam day boundary)
- Hard button behavior (comportamento específico em diferentes steps)
- New Card Gather Order (Deck, Deck then random notes, Ascending position, Descending position, Random notes, Random cards)
- New Card Sort Order (Card type then order gathered, Order gathered, Card type then random, Random note then card type, Random)
- New/Review Order (misturar, mostrar antes ou depois)
- Interday Learning/Review Order (misturar, mostrar antes ou depois)
- Review Sort Order (Due date then random, Due date then deck, Deck then due date, Ascending intervals, Descending intervals, Ascending ease, Descending ease, Relative overdueness, Ascending retrievability para FSRS)
- Internal Timer (Maximum answer seconds, padrão 60 segundos)
- On-screen Timer (show on-screen timer, stop on-screen timer on answer)
- Auto Advance (Seconds to show question for, Seconds to show answer for)
- FSRS Simulator (simulação de workload futuro)
- Historical Retention (preencher gaps no histórico de revisões)
- Ignore Cards Reviewed Before (ignorar cards na otimização FSRS)
- Optimize All Presets (otimizar parâmetros FSRS para todos os presets de uma vez)
- Evaluate FSRS Parameters (avaliar qualidade com log loss e RMSE)

### RF-007: Presets de Opções
O sistema DEVE permitir:
- Criar presets de opções de deck
- Aplicar presets a múltiplos decks
- Editar presets (atualiza todos os decks que usam)
- Clonar presets existentes
- Renomear e excluir presets

### RF-008: Exclusão de Decks
O sistema DEVE:
- Solicitar confirmação antes de excluir deck
- Oferecer opção de mover cards antes de excluir
- Criar backup automático antes de exclusão
- Manter histórico de exclusões

## 3. Gerenciamento de Notes e Cards

### RF-009: Criação de Notes
O sistema DEVE permitir:
- Criar notes selecionando note type
- Preencher campos da note conforme note type
- Adicionar múltiplas tags
- Selecionar deck de destino
- Visualizar preview dos cards antes de salvar
- Validar campos obrigatórios

### RF-010: Geração Automática de Cards
O sistema DEVE:
- Gerar cards automaticamente baseado no note type
- Criar múltiplos cards quando note type define múltiplos card types
- Validar que front do card não está vazio antes de gerar
- Suportar geração condicional de cards (conditional replacement)
- Detectar e reportar empty cards

### RF-011: Edição de Notes
O sistema DEVE permitir:
- Editar conteúdo de notes existentes
- Atualizar automaticamente todos os cards relacionados
- Alterar note type (com validação de compatibilidade)
- Mover note para outro deck
- Adicionar/remover tags
- Marcar/desmarcar note como "marked"

### RF-012: Visualização e Busca
O sistema DEVE permitir:
- Visualizar notes individuais
- Buscar notes por texto simples
- Buscar usando sintaxe avançada (tags, fields, decks, estados, propriedades)
- Buscar com regular expressions
- Buscar ignorando acentos e caracteres combinados
- Filtrar por múltiplos critérios simultaneamente
- Visualizar em modo tabela (browser)
- Alternar entre visualização de cards e notes

### RF-012A: Browser Avançado
O sistema DEVE permitir no browser:
- Ordenar colunas (clique no cabeçalho)
- Ordenar por múltiplas colunas
- Configurar quais colunas são exibidas
- Redimensionar colunas
- Editar note inline (duplo clique)
- Aplicar filtros visuais (dropdowns)
- Buscar e substituir texto em lote
- Exportar resultados diretamente
- Visualizar cards relacionados (siblings)
- Salvar configuração de colunas
- Mover cards selecionados para outro deck (Change Deck)
- Exportar notes selecionadas (Export Notes)
- Alternar entre Cards mode e Notes mode
- Sidebar Search Tool (busca com modificadores Ctrl, Shift, Alt)
- Sidebar Selection Tool (seleção múltipla e drag-and-drop)
- Salvar buscas atuais na sidebar (Saved Searches)
- Editar items da sidebar (deletar/renomear tags, decks, saved searches)
- Buscar item na sidebar tree
- Aplicar background color baseado em flag/suspended/marked

### RF-013: Operações em Lote
O sistema DEVE permitir:
- Selecionar múltiplas notes/cards
- Aplicar operações em lote (tags, deck, note type, exclusão)
- Encontrar duplicatas de notes
- Editar múltiplos itens simultaneamente
- Alternar marcação de notes (Toggle Mark - marca se desmarcada, desmarca se marcada)
- Limpar tags não utilizadas (Clear Unused Tags)
- Buscar e substituir texto em múltiplas notes (Find and Replace)

### RF-014: Exclusão
O sistema DEVE:
- Solicitar confirmação antes de excluir
- Excluir todos os cards relacionados quando note é excluída
- Registrar exclusões no log de deletions
- Permitir recuperação de exclusões recentes

## 4. Tipos de Nota (Note Types)

### RF-015: Gerenciamento de Note Types
O sistema DEVE permitir:
- Criar novos note types
- Clonar note types existentes
- Editar note types (adicionar/remover campos e card types)
- Renomear note types
- Excluir note types (apenas se não houver notes usando)
- Visualizar lista de todos os note types

### RF-016: Campos
O sistema DEVE permitir:
- Adicionar/remover campos do note type
- Renomear campos
- Reordenar campos
- Configurar propriedades dos campos:
  - Fonte e tamanho para edição
  - Sort field (campo usado para ordenação)
  - Direção de texto (RTL)
  - Editor HTML por padrão
  - Colapsar por padrão
  - Excluir de buscas não qualificadas
  - Sticky (não limpar após adicionar)

### RF-017: Card Types e Templates
O sistema DEVE permitir:
- Adicionar/remover card types
- Editar front template (HTML)
- Editar back template (HTML)
- Editar styling (CSS)
- Configurar browser appearance (template simplificado para listagem)
- Visualizar preview do card enquanto edita
- Validar sintaxe dos templates antes de salvar
- Configurar deck override para card type específico
- Detectar e reportar conflitos de templates
- Detectar e reportar conflitos de cloze deletions
- Avisar sobre riscos de segurança ao habilitar LaTeX
- Avisar sobre riscos de segurança ao usar JavaScript em templates

### RF-018: Tipos de Nota Especiais
O sistema DEVE suportar:
- **Basic**: Front/Back simples (1 card)
- **Basic (and reversed)**: Cria 2 cards (frente→verso, verso→frente)
- **Basic (optional reversed)**: Campo adicional para criar reverso condicionalmente
- **Basic (type in answer)**: Campo de digitação com verificação
- **Cloze**: Deletions com {{c1::texto}}, suporta múltiplos e nested
- **Image Occlusion**: Oclusão de imagens com formas (retângulo, elipse, polígono)

## 5. Sistema de Estudo

### RF-019: Início de Sessão
O sistema DEVE:
- Exibir overview do deck (quantos cards para estudar)
- Permitir iniciar sessão de estudo
- Carregar cards baseado em limites e ordem configurados
- Respeitar limites diários de novos cards e reviews

### RF-020: Revisão de Cards
O sistema DEVE:
- Exibir frente do card primeiro
- Permitir mostrar resposta (Show Answer)
- Exibir verso do card após mostrar resposta
- Permitir avaliar desempenho com 4 botões (Again, Hard, Good, Easy)
- Registrar revisão com timestamp e tempo gasto
- Calcular próximo intervalo usando algoritmo configurado
- Atualizar estado do card (new → learn → review)
- Aplicar algoritmo de repetição espaçada (SM-2 ou FSRS)
- Enterrar siblings automaticamente (se configurado)
- Avançar para próximo card automaticamente

### RF-021: Funcionalidades Durante Estudo
O sistema DEVE permitir:
- Editar card durante estudo
- Adicionar/remover flag do card
- Enterrar card manualmente
- Suspender card
- Resetar card para new
- Definir data de vencimento manualmente
- Visualizar informações detalhadas do card (Card Info)
- Visualizar informações do card anterior (Previous Card Info)
- Criar cópia da note atual (Create Copy)
- Desfazer última operação (Undo)
- Refazer operação desfeita (Redo)
- Exibir timer de resposta (internal e on-screen)
- Registrar tempo gasto em cada card
- Exibir progresso da sessão
- Exibir próximo intervalo previsto nos botões de resposta

### RF-022: Type in Answer
O sistema DEVE:
- Exibir campo de texto para digitação quando template usa {{type:Field}}
- Comparar resposta digitada com resposta correta
- Destacar diferenças (correto/incorreto/faltando)
- Ignorar diacríticos se configurado ({{type:nc:Field}})
- Usar fonte monoespaçada para alinhamento
- Suportar apenas uma comparação por card
- Suportar apenas uma linha de texto

### RF-023: Auto Advance e Timeboxing
O sistema DEVE permitir:
- Ativar/desativar auto advance
- Configurar tempo para mostrar questão
- Configurar tempo para mostrar resposta
- Avançar automaticamente após tempo configurado
- Configurar timeboxing (limite de tempo de estudo)
- Exibir notificações periódicas durante timeboxing
- Mostrar estatísticas ao final do timebox

### RF-024: Áudio e Media Durante Estudo
O sistema DEVE:
- Reproduzir áudio automaticamente (se configurado)
- Exibir botões de replay para repetir áudio
- Interromper áudio ao responder (se configurado)
- Exibir imagens e vídeos nos cards
- Suportar controles de áudio (play, pause, -5s, +5s)
- Permitir gravar voz própria para verificação de pronúncia
- Permitir reproduzir voz própria gravada

## 6. Algoritmos de Repetição Espaçada

### RF-025: SM-2 (SuperMemo 2)
O sistema DEVE:
- Calcular intervalos usando algoritmo SM-2
- Ajustar ease factor baseado na resposta (Again diminui, Easy aumenta)
- Aplicar interval modifier (multiplicador global)
- Aplicar easy bonus (multiplicador extra para Easy)
- Aplicar hard interval (multiplicador para Hard)
- Aplicar new interval após lapse (resetar ou preservar parte)
- Respeitar maximum interval configurado
- Garantir que novo intervalo seja pelo menos 1 dia maior que anterior

### RF-026: FSRS (Free Spaced Repetition Scheduler)
O sistema DEVE:
- Calcular intervalos usando algoritmo FSRS
- Manter e atualizar stability (estabilidade da memória)
- Manter e atualizar difficulty (dificuldade do card)
- Calcular retrievability (probabilidade de recordar)
- Otimizar parâmetros FSRS baseado em histórico de revisões
- Avaliar qualidade dos parâmetros (log loss, RMSE)
- Calcular minimum recommended retention
- Simular workload futuro
- Permitir reschedule cards ao mudar desired retention (opcional)
- Suportar historical retention para preencher gaps no histórico
- Ignorar cards revisados antes de data específica na otimização

### RF-027: Learning Steps
O sistema DEVE:
- Aplicar learning steps para novos cards
- Aplicar relearning steps para lapsed cards
- Converter steps que cruzam day boundary para dias
- Mostrar cards em learning antes de reviews (se configurado)
- Permitir steps vazios (FSRS controla completamente)
- Respeitar learn ahead limit (mostrar cards early se não há mais nada)

## 7. Flags e Leeches

### RF-028: Sistema de Flags
O sistema DEVE:
- Suportar 7 flags coloridas (0-7) para cards
- Aplicar flags a nível de card (não note)
- Permitir buscar cards por flag (flag:1, flag:2, etc.)
- Permitir renomear flags (personalização)
- Exibir flag visualmente no card durante estudo
- Permitir adicionar/remover flag via atalhos de teclado

### RF-029: Sistema de Leeches
O sistema DEVE:
- Detectar automaticamente cards com muitas falhas (threshold configurável)
- Adicionar tag "leech" automaticamente quando threshold é atingido
- Suspender card automaticamente (se configurado nas opções)
- Alertar usuário sobre leeches periodicamente (metade do threshold)
- Permitir visualizar lista de leeches
- Permitir editar, excluir ou suspender leeches manualmente

## 8. Media (Imagens, Áudio, Vídeo)

### RF-030: Upload de Media
O sistema DEVE:
- Permitir upload de imagens (formatos suportados: JPG, PNG, GIF, WebP, etc.)
- Permitir upload de áudio (formatos suportados: MP3, OGG, WAV, etc.)
- Permitir upload de vídeo (formatos suportados: MP4, WebM, etc.)
- Validar formato e tamanho do arquivo
- Gerar hash para detecção de duplicatas
- Armazenar media de forma segura
- Permitir colar imagem da clipboard
- Suportar drag-and-drop de arquivos

### RF-031: Gerenciamento de Media
O sistema DEVE:
- Associar media aos campos das notes
- Exibir media nos cards durante estudo
- Verificar media não utilizada
- Permitir excluir media não utilizada
- Restaurar media excluída acidentalmente
- Sincronizar media entre dispositivos
- Gerar thumbnails para imagens
- Validar integridade de arquivos de media
- Tag notes que referenciam media faltante
- Esvaziar trash folder de media
- Permitir adicionar media manualmente à pasta de media
- Verificar encoding de nomes de arquivo ao adicionar manualmente

### RF-032: LaTeX e MathJax
O sistema DEVE:
- Suportar renderização de equações LaTeX
- Gerar imagens de equações LaTeX no servidor
- Renderizar MathJax no navegador (client-side)
- Suportar pacotes LaTeX customizados
- Validar sintaxe LaTeX antes de gerar
- Suportar inline e display math
- Suportar mhchem para equações químicas
- Permitir customizar preamble LaTeX

## 9. Templates e Styling

### RF-033: Sistema de Templates
O sistema DEVE:
- Renderizar templates front e back dos cards
- Substituir field replacements ({{FieldName}})
- Processar conditional replacements ({{#Field}}...{{/Field}})
- Processar special fields ({{FrontSide}}, {{Tags}}, {{Deck}}, {{CardFlag}}, {{Type}})
- Processar Text-to-Speech ({{tts lang:Field}}, {{tts-voices:}})
- Processar Ruby characters ({{furigana:Field}}, {{kana:Field}}, {{kanji:Field}})
- Processar type in answer ({{type:Field}}, {{type:nc:Field}})
- Processar hints ({{hint:Field}})
- Criar links de dicionário dinâmicos
- Processar HTML stripping ({{text:Field}})
- Suportar Right-to-Left (RTL) text
- Processar múltiplos campos TTS
- Renderizar browser appearance simplificado

### RF-034: Styling
O sistema DEVE:
- Aplicar CSS customizado aos cards
- Suportar night mode styling
- Permitir estilização por card type
- Suportar estilização de campos individuais
- Suportar estilização específica por plataforma (CSS classes)
- Permitir instalar fontes customizadas
- Suportar fading automático ao mostrar resposta (configurável em milliseconds)
- Suportar scrolling automático para elemento com id=answer
- Permitir configurar velocidade de fading (default 100ms, 0 para desabilitar)
- Permitir JavaScript nos templates (com avisos de segurança)

## 10. Busca e Filtros

### RF-035: Busca Simples
O sistema DEVE permitir:
- Buscar por texto simples em todos os campos
- Buscar palavras completas (w:)
- Buscar com wildcards (*, _)
- Buscar com operadores lógicos (AND, OR, NOT)
- Buscar com agrupamento (parênteses)

### RF-036: Busca Avançada
O sistema DEVE permitir:
- Buscar em campo específico (front:dog)
- Buscar por tags (tag:vocab)
- Buscar por deck (deck:french)
- Buscar por estado (is:new, is:due, is:review, is:learn, is:suspended, is:buried)
- Buscar por propriedades (prop:ivl>=10, prop:due=-1, prop:lapses>3)
- Buscar com regular expressions (re:\d{3})
- Buscar ignorando acentos (nc:uber)
- Buscar por flag (flag:1)
- Buscar por data (added:7, rated:1, edited:7, introduced:365)
- Buscar por note type (note:basic)
- Buscar por card type (card:forward)
- Buscar por preset (preset:"Default")
- Buscar por custom data (has-cd:v, prop:cdn:d>5)

### RF-037: Saved Searches
O sistema DEVE permitir:
- Salvar buscas para uso futuro
- Aplicar saved searches rapidamente
- Editar saved searches
- Excluir saved searches
- Usar saved searches em filtered decks

## 11. Filtered Decks (Custom Study)

### RF-038: Criação de Filtered Decks
O sistema DEVE permitir:
- Criar filtered deck com busca customizada
- Criar filtered deck via Custom Study (presets)
- Configurar limite de cards no filtered deck
- Configurar ordem de exibição
- Configurar rescheduling (ativar/desativar)
- Habilitar segundo filtro (para duas buscas diferentes)

### RF-039: Tipos de Custom Study
O sistema DEVE suportar:
- Aumentar limite de novos cards do dia
- Aumentar limite de reviews do dia
- Estudar cards esquecidos (forgotten cards)
- Estudar cards antecipadamente (review ahead)
- Fazer preview de novos cards
- Estudar por estado ou tag

### RF-040: Gerenciamento de Filtered Decks
O sistema DEVE permitir:
- Reconstruir filtered deck (rebuild)
- Esvaziar filtered deck (retorna cards aos home decks)
- Excluir filtered deck
- Retornar cards aos home decks automaticamente após estudo
- Usar steps do home deck ou steps customizados

## 12. Estatísticas e Relatórios

### RF-041: Estatísticas do Deck
O sistema DEVE exibir:
- Gráfico de reviews por dia/semana/mês
- Gráfico de tempo gasto
- Distribuição de intervalos
- Distribuição de ease factors
- Distribuição de stability (FSRS)
- Distribuição de difficulty (FSRS)
- Distribuição de retrievability (FSRS)
- Breakdown por hora do dia
- Gráfico de answer buttons (Again, Hard, Good, Easy)
- Tabela de true retention
- Estatísticas de hoje (reviews, tempo, again count, etc.)

### RF-042: Estatísticas da Coleção
O sistema DEVE exibir:
- Contagem de cards (mature, young, new, suspended)
- Forecast de cards futuros (Future Due)
- Calendário de atividade
- Daily load estimado
- Gráficos agregados de toda a coleção
- Estatísticas por período (12 meses, toda história, vida do deck)

### RF-043: Estatísticas do Card
O sistema DEVE exibir:
- Informações detalhadas de card específico
- Histórico completo de revisões
- Intervalos anteriores
- Ease factor histórico
- Tempo gasto em cada revisão
- Posição na fila (para novos cards)

### RF-044: Exportação de Estatísticas
O sistema DEVE permitir:
- Exportar estatísticas como PDF
- Incluir todos os gráficos no PDF
- Personalizar período das estatísticas exportadas

## 13. Sincronização

### RF-045: Sincronização Básica
O sistema DEVE:
- Sincronizar coleção com servidor
- Detectar mudanças locais e remotas
- Mesclar mudanças automaticamente quando possível
- Sincronizar media junto com dados
- Sincronizar automaticamente ao abrir/fechar (se configurado)
- Sincronizar periodicamente (se configurado)

### RF-046: Resolução de Conflitos
O sistema DEVE:
- Detectar conflitos não mescláveis
- Solicitar escolha do usuário (local vs remoto) quando necessário
- Forçar sincronização unidirecional quando necessário
- Avisar sobre operações que requerem full sync
- Preservar dados quando possível

### RF-047: Sincronização Multi-dispositivo
O sistema DEVE:
- Suportar acesso de múltiplos dispositivos
- Manter sincronização entre dispositivos
- Rastrear último sync por dispositivo
- Permitir forçar upload ou download
- Suportar servidor de sync customizado (self-hosted)

### RF-047A: Self-Hosted Sync Server
O sistema DEVE permitir:
- Instalar servidor de sync self-hosted (From a Packaged Build, With Pip, With Cargo, From source, With Docker)
- Configurar múltiplos usuários no servidor (SYNC_USER1, SYNC_USER2, etc.)
- Configurar senhas hasheadas (PHC Format)
- Configurar localização de armazenamento (SYNC_BASE)
- Configurar acesso público ao servidor (SYNC_HOST, SYNC_PORT)
- Configurar cliente para usar servidor self-hosted
- Configurar reverse proxy para servidor (HTTPS, subpath)
- Configurar limites de requisições grandes (MAX_SYNC_PAYLOAD_MEGS)

## 14. Importação e Exportação

### RF-048: Importação
O sistema DEVE permitir:
- Importar arquivo de texto (CSV, TSV) com separadores configuráveis
- Mapear colunas para campos
- Detectar e atualizar duplicatas (baseado em primeiro campo ou GUID)
- Importar deck package (.apkg)
- Importar collection package (.colpkg)
- Importar de Mnemosyne (.db)
- Importar de SuperMemo (.xml)
- Importar media junto com dados
- Validar dados antes de importar
- Suportar headers no arquivo de texto (separator, html, tags, columns, etc.)
- Suportar colunas especiais (notetype column, deck column, tags column, guid column)
- Permitir escolher comportamento para duplicatas (ignorar, atualizar, criar novo)

### RF-048A: Decks Compartilhados
O sistema DEVE permitir:
- Acessar biblioteca de decks compartilhados (Shared Decks)
- Buscar decks compartilhados por categoria ou palavras-chave
- Visualizar informações e preview de deck compartilhado
- Baixar deck compartilhado (.apkg)
- Importar deck compartilhado automaticamente após download

### RF-049: Exportação
O sistema DEVE permitir:
- Exportar deck como texto (com HTML preservado)
- Exportar deck como package (.apkg)
- Exportar coleção completa (.colpkg)
- Incluir scheduling information (opcional)
- Incluir media nos packages
- Remover tags de leech/marked ao exportar para compartilhar
- Escolher formato de package (compatível com versões antigas ou otimizado)

## 15. Preferências Globais

### RF-050: Aparência
O sistema DEVE permitir configurar:
- Idioma da interface
- Tema (dark/light/auto)
- Tamanho da UI
- Video driver (software/OpenGL/ANGLE/auto)
- Modo minimalista
- Redução de movimento
- Reset de tamanhos de janelas
- Distractions (hide top and bottom bar during reviews, enable minimalist mode, reduce motion, switching between native styling and Anki theme)

### RF-051: Comportamento
O sistema DEVE permitir configurar:
- Horário de início do próximo dia
- Learn ahead limit
- Timebox time limit
- Comportamento de paste (manter ou remover formatação)
- Configurações de busca (ignorar acentos, etc.)
- Default deck behavior (current deck vs note type based)

### RF-052: Sincronização
O sistema DEVE permitir configurar:
- Auto sync on open/close
- Sincronização periódica de media
- Servidor de sync customizado
- Forçar sincronização unidirecional no próximo sync
- Sincronizar audio e imagens também

### RF-053: Editor
O sistema DEVE permitir configurar:
- Paste clipboard images as PNG (vs JPG)
- Paste without Shift strips formatting
- Default deck selection behavior (When adding, default to current deck ou Change deck depending on note type)
- Default search text (personalizar texto de busca inicial no browser)

### RF-054: Review
O sistema DEVE permitir configurar:
- Mostrar botões de replay em cards com áudio
- Interromper áudio atual ao responder
- Mostrar contador de cards restantes
- Mostrar próximo tempo de revisão acima dos botões
- Spacebar/Enter também responde card
- Don't play audio automatically (não reproduzir áudio automaticamente)
- Skip question when replaying answer (pular áudio da questão ao usar replay)

## 16. Backups

### RF-055: Backups Automáticos
O sistema DEVE:
- Criar backup automático periodicamente (configurável, padrão 30 minutos)
- Manter backups diários, semanais e mensais (configurável)
- Limpar backups antigos automaticamente (após 2 dias, manter configurável)
- Criar backup antes de operações destrutivas
- Criar backup antes de importar .colpkg
- Criar backup após one-way sync download
- Criar backup após Check Database

### RF-056: Backups Manuais
O sistema DEVE permitir:
- Criar backup manual a qualquer momento
- Visualizar lista de backups disponíveis
- Restaurar backup específico
- Desabilitar auto sync após restaurar backup
- Excluir backup antigo
- Exportar backup como .colpkg

## 17. Text-to-Speech (TTS)

### RF-057: Configuração TTS
O sistema DEVE:
- Detectar vozes disponíveis no sistema operacional
- Listar todas as vozes disponíveis ({{tts-voices:}})
- Suportar múltiplas vozes por idioma
- Permitir especificar velocidade de fala

### RF-058: Uso de TTS
O sistema DEVE:
- Ler campo automaticamente durante estudo ({{tts lang:Field}})
- Ler múltiplos campos e texto estático ([anki:tts]...[/anki:tts])
- Ler apenas cloze deletions (cloze-only filter)
- Ajustar velocidade de fala (speed parameter)
- Escolher voz preferida da lista
- Funcionar em Windows, macOS, iOS (vozes do sistema)
- Suportar vozes via add-ons no Linux

## 18. Ruby Characters (Furigana)

### RF-059: Suporte a Furigana
O sistema DEVE:
- Renderizar furigana acima do texto ({{furigana:Field}})
- Exibir apenas kana ({{kana:Field}})
- Exibir apenas kanji ({{kanji:Field}})
- Processar múltiplas anotações ruby no mesmo campo
- Respeitar espaços para posicionamento correto
- Suportar sintaxe: Texto[Ruby]

## 19. Right-to-Left (RTL)

### RF-060: Suporte RTL
O sistema DEVE:
- Renderizar texto RTL corretamente
- Permitir configurar direção de texto no campo
- Aplicar direção RTL no template (dir=rtl)
- Suportar RTL no editor
- Suportar RTL em toda a interface quando necessário

## 20. Unicode Normalization

### RF-061: Normalização
O sistema DEVE:
- Normalizar texto para busca consistente por padrão
- Permitir desabilitar normalização (para preservar variantes)
- Garantir compatibilidade entre sistemas operacionais
- Normalizar ao importar e sincronizar

## 21. Siblings e Burying

### RF-062: Burying Automático
O sistema DEVE:
- Enterrar siblings automaticamente durante estudo
- Enterrar new siblings se configurado
- Enterrar review siblings se configurado
- Enterrar interday learning siblings se configurado
- NÃO enterrar cards em learning (time-critical)
- Respeitar ordem de prioridade (learning > review > new)
- Desenterrar automaticamente no próximo dia

### RF-063: Burying Manual
O sistema DEVE permitir:
- Enterrar card manualmente
- Desenterrar cards enterrados
- Visualizar contador de cards enterrados no overview
- Desenterrar todos os cards enterrados de uma vez

## 22. Card Generation Logic

### RF-064: Geração de Cards
O sistema DEVE:
- Gerar cards baseado em templates do note type
- NÃO gerar cards com front vazio
- Gerar cards condicionalmente ({{#Field}})
- Detectar empty cards
- Permitir limpar empty cards
- Regenerar cards quando note é editada
- Validar templates antes de gerar
- Criar card vazio usando primeiro template se nenhum card for gerado (permite adicionar material incompleto)
- Exibir mensagem quando card está vazio durante estudo
- Listar empty cards antes de limpar (com confirmação)

### RF-065: Cloze Cards
O sistema DEVE:
- Gerar card para cada número de cloze (c1, c2, etc.)
- Suportar nested cloze deletions (até 3 níveis)
- Detectar empty cloze cards
- Processar hints em cloze ({{c1::texto::hint}})
- Suportar múltiplos clozes no mesmo card (mesmo número)

## 23. Operações Avançadas

### RF-066: Reposicionamento
O sistema DEVE permitir:
- Reposicionar novos cards na fila
- Inserir cards entre existentes (shift position)
- Reposicionar múltiplos cards de uma vez
- Visualizar posição atual dos cards

### RF-067: Reset e Set Due
O sistema DEVE permitir:
- Resetar card para new (preserva histórico)
- Resetar card completamente (Forget - esquece histórico)
- Resetar card restaurando posição original
- Resetar contadores de lapses e reps
- Definir data de vencimento específica
- Definir range de datas (60-90 dias)
- Converter new cards em review cards ao set due
- Reschedule cards mantendo ou alterando intervalo
- Aplicar rescheduling quando range inclui "!" (altera intervalo de review cards)

## 24. Performance e Otimização

### RF-068: Otimização de Queries
O sistema DEVE:
- Otimizar queries de estudo (suportar milhares de cards)
- Usar índices eficientemente
- Implementar paginação em todas as listagens
- Cachear queries frequentes
- Otimizar queries de busca full-text

### RF-069: Background Jobs
O sistema DEVE:
- Executar otimização de banco em background
- Executar limpeza de media em background
- Executar geração de estatísticas em background
- Executar sincronização de media em background
- Não bloquear interface durante operações pesadas

### RF-070: Lazy Loading
O sistema DEVE:
- Carregar media sob demanda (lazy loading)
- Carregar cards sob demanda durante estudo
- Carregar estatísticas sob demanda
- Otimizar transferência de dados

## 25. Segurança e Validação

### RF-071: Validação
O sistema DEVE:
- Validar todos os inputs do usuário
- Sanitizar dados antes de salvar
- Validar templates antes de renderizar
- Validar JavaScript custom scheduling (sandbox)
- Validar sintaxe de busca antes de executar
- Validar formato de arquivos importados

### RF-072: Segurança
O sistema DEVE:
- Implementar rate limiting em todas as APIs
- Validar autenticação em todas as requisições
- Proteger contra SQL injection
- Proteger contra XSS em templates
- Proteger contra CSRF
- Criptografar senhas (hash seguro)
- Validar tokens JWT
- Sanitizar outputs para prevenir injection

### RF-073: Permissões
O sistema DEVE:
- Garantir que usuários só acessem seus próprios dados
- Validar ownership de recursos antes de operações
- Implementar autorização baseada em roles (se aplicável)
- Logar tentativas de acesso não autorizado

## 26. Logging e Debugging

### RF-074: Logging
O sistema DEVE:
- Registrar todas as operações importantes
- Registrar erros com stack traces
- Manter log de sincronização
- Manter log de deletions (deleted.txt)
- Usar logging estruturado
- Rotacionar logs para evitar crescimento excessivo
- Permitir configurar nível de log

### RF-075: Debugging
O sistema DEVE permitir:
- Acessar debug console (Ctrl+Shift+;)
- Exibir informações de debug
- Executar código de debug
- Visualizar estado interno do sistema
- Exportar informações de debug para suporte

## 27. Manutenção e Verificação

### RF-084: Verificação de Integridade
O sistema DEVE permitir:
- Executar verificação de integridade do banco (Check Database)
- Verificar se arquivo foi corrompido
- Reconstruir estruturas internas durante verificação
- Otimizar arquivo durante verificação
- Reportar problemas encontrados na verificação
- Sugerir restaurar backup se corrupção for detectada
- Oferecer opção de reparar corrupção se backup estiver muito antigo

### RF-085: Limpeza e Otimização
O sistema DEVE permitir:
- Verificar e listar empty cards para limpeza
- Verificar e listar media não utilizada
- Otimizar índices do banco de dados
- Compactar banco de dados após operações grandes

## 28. Sistema de Add-ons

### RF-086: Gerenciamento de Add-ons
O sistema DEVE permitir:
- Acessar gerenciador de add-ons (Add-on Manager)
- Buscar add-ons disponíveis
- Instalar add-on pelo código
- Desinstalar add-on
- Habilitar/desabilitar add-on
- Atualizar add-ons instalados
- Validar compatibilidade de add-ons com versão atual
- Avisar sobre add-ons incompatíveis após atualização
- Configurar opções de add-ons (quando disponível)

## 29. API REST

### RF-087: Documentação da API
O sistema DEVE:
- Fornecer documentação OpenAPI/Swagger
- Documentar todos os endpoints
- Documentar modelos de dados
- Documentar códigos de erro
- Fornecer exemplos de requisições e respostas

### RF-088: Versionamento
O sistema DEVE:
- Suportar versionamento de API
- Manter compatibilidade com versões anteriores
- Deprecar endpoints com aviso prévio
- Documentar mudanças entre versões

### RF-089: Rate Limiting
O sistema DEVE:
- Implementar rate limiting por usuário
- Implementar rate limiting por IP
- Retornar headers apropriados (X-RateLimit-*)
- Permitir configurar limites

### RF-090: Webhooks
O sistema DEVE:
- Suportar webhooks para eventos importantes
- Permitir configurar URLs de webhook
- Validar assinatura de webhooks
- Retry webhooks falhados

## 30. Compatibilidade

### RF-091: Compatibilidade com Anki
O sistema DEVE:
- Manter estrutura de dados compatível com Anki quando possível
- Suportar importação de decks do Anki (.apkg)
- Suportar importação de coleções do Anki (.colpkg)
- Manter compatibilidade de formato quando exportar

### RF-092: Multi-plataforma
O sistema DEVE:
- Funcionar em diferentes navegadores (Chrome, Firefox, Safari, Edge)
- Suportar diferentes sistemas operacionais (via web)
- Adaptar UI para diferentes tamanhos de tela
- Suportar dispositivos móveis (responsive design)

## 31. Acessibilidade

### RF-093: Acessibilidade
O sistema DEVE:
- Suportar navegação por teclado
- Suportar leitores de tela
- Manter contraste adequado
- Fornecer textos alternativos para imagens
- Suportar atalhos de teclado para ações principais

## 32. Internacionalização

### RF-094: i18n
O sistema DEVE:
- Suportar múltiplos idiomas
- Permitir tradução da interface
- Suportar diferentes formatos de data/hora
- Suportar diferentes formatos numéricos
- Manter traduções atualizadas

## 33. Profiles (Perfis)

### RF-095: Gerenciamento de Profiles
O sistema DEVE permitir:
- Criar novos perfis de usuário
- Renomear perfis existentes
- Deletar perfis
- Alternar entre perfis
- Restaurar backup automático do perfil
- Fazer downgrade da coleção para versão anterior do Anki
- Validar que apenas um perfil pode ser sincronizado com uma conta AnkiWeb
- Manter coleções separadas por perfil
- Compartilhar add-ons entre perfis (mas não configurações)

## Resumo

Total de requisitos funcionais identificados: **96 requisitos principais**

Estes requisitos funcionais cobrem todas as funcionalidades do sistema, desde operações básicas até funcionalidades avançadas, garantindo que o sistema replique completamente as capacidades do Anki original enquanto adiciona melhorias como API REST completa e arquitetura moderna.

### Requisitos Adicionados Recentemente:
- Browser avançado (RF-012A) - expandido com Table Modes, Sidebar Tools, Saved Searches
- Funcionalidades durante estudo expandidas (Previous Card Info, Create Copy, Undo/Redo)
- Operações em lote expandidas (Toggle Mark, Clear Unused Tags, Find and Replace)
- Templates expandidos (Deck Override, conflitos, avisos de segurança)
- Styling expandido (fading, scrolling, font installation)
- Geração de cards expandida (empty cards, mensagens)
- Reset e Set Due expandido (Forget, rescheduling com "!")
- Decks compartilhados (RF-048A)
- Manutenção e verificação (RF-084, RF-085)
- Sistema de add-ons (RF-086)
- Opções de Deck Avançadas (RF-006 expandido) - Per-Deck Daily Limits, Display Order detalhado, Timers, FSRS Simulator
- Gerenciamento de Media expandido (RF-031) - tag notes, trash folder, adição manual
- Preferências de Review expandidas (RF-054) - opções de áudio detalhadas
- Editor expandido (RF-053) - Default deck behavior, Default search text
- Aparência expandida (RF-050) - Distractions, Video driver auto
- Sincronização expandida (RF-052) - Sincronizar audio e imagens
- Self-Hosted Sync Server (RF-047A) - configuração completa do servidor
- Profiles (RF-095) - gerenciamento completo de perfis
