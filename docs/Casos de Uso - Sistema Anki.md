# Casos de Uso - Sistema Anki Completo

Este documento descreve todos os casos de uso do sistema Anki, organizados por área funcional.

## 1. Autenticação e Gerenciamento de Usuário

### 1.1 Registro de Usuário
- **UC-001**: Usuário se registra no sistema fornecendo email e senha
- **UC-002**: Sistema valida email único e força de senha
- **UC-003**: Sistema cria conta e perfil inicial do usuário
- **UC-004**: Sistema cria deck "Default" para o novo usuário

### 1.2 Login e Autenticação
- **UC-005**: Usuário faz login com email e senha
- **UC-006**: Sistema valida credenciais e retorna JWT token
- **UC-007**: Usuário renova token de acesso usando refresh token
- **UC-008**: Usuário faz logout invalidando tokens

### 1.3 Gerenciamento de Sessão
- **UC-009**: Sistema mantém sessão ativa enquanto token é válido
- **UC-010**: Sistema expira sessão após período de inatividade
- **UC-011**: Sistema permite múltiplas sessões simultâneas (diferentes dispositivos)

## 2. Gerenciamento de Decks

### 2.1 Criação e Edição de Decks
- **UC-012**: Usuário cria novo deck
- **UC-013**: Usuário renomeia deck existente
- **UC-014**: Usuário move deck para dentro de outro (criar hierarquia)
- **UC-015**: Usuário reorganiza decks por drag-and-drop
- **UC-016**: Usuário edita opções do deck (preset, limites, etc.)

### 2.2 Visualização de Decks
- **UC-017**: Usuário visualiza lista hierárquica de todos os decks
- **UC-018**: Sistema exibe contadores de cards (New, Learning, Review) por deck
- **UC-019**: Usuário visualiza deck específico com seus cards
- **UC-020**: Sistema calcula e exibe estatísticas resumidas do deck

### 2.3 Opções de Deck
- **UC-021**: Usuário configura limite de novos cards por dia
- **UC-022**: Usuário configura limite máximo de reviews por dia
- **UC-023**: Usuário configura learning steps (1m, 10m, 1d)
- **UC-024**: Usuário configura graduating interval
- **UC-025**: Usuário configura easy interval
- **UC-026**: Usuário configura relearning steps para lapses
- **UC-027**: Usuário configura minimum interval após relearning
- **UC-028**: Usuário configura display order (ordem de exibição)
- **UC-029**: Usuário configura burying de siblings
- **UC-030**: Usuário habilita/desabilita FSRS para o deck
- **UC-031**: Usuário otimiza parâmetros FSRS baseado em histórico
- **UC-032**: Usuário configura desired retention (FSRS)
- **UC-033**: Usuário configura Easy Days (ajuste por dia da semana)
- **UC-034**: Usuário configura custom scheduling (JavaScript)
- **UC-035**: Usuário configura threshold de leeches
- **UC-036**: Usuário configura ações para leeches (suspend/tag)
- **UC-037**: Usuário cria/edita presets de opções
- **UC-038**: Usuário aplica preset a múltiplos decks
- **UC-466**: Usuário configura limite de novos cards específico para deck (This deck)
- **UC-467**: Usuário configura limite temporário de novos cards (Today only)
- **UC-468**: Usuário configura limite de reviews específico para deck
- **UC-469**: Usuário habilita opção para novos cards ignorarem limite de reviews
- **UC-470**: Usuário habilita opção para limites de decks superiores se aplicarem a subdecks
- **UC-471**: Usuário configura insertion order (aleatório ou sequencial)
- **UC-472**: Sistema trata steps que cruzam day boundary diferentemente de steps pequenos
- **UC-473**: Sistema aplica comportamento específico do botão Hard em diferentes steps
- **UC-474**: Usuário configura New Card Gather Order como "Deck"
- **UC-475**: Usuário configura New Card Gather Order como "Deck, then random notes"
- **UC-476**: Usuário configura New Card Gather Order como "Ascending position"
- **UC-477**: Usuário configura New Card Gather Order como "Descending position"
- **UC-478**: Usuário configura New Card Gather Order como "Random notes"
- **UC-479**: Usuário configura New Card Gather Order como "Random cards"
- **UC-480**: Usuário configura New Card Sort Order como "Card type, then order gathered"
- **UC-481**: Usuário configura New Card Sort Order como "Order gathered"
- **UC-482**: Usuário configura New Card Sort Order como "Card type, then random"
- **UC-483**: Usuário configura New Card Sort Order como "Random note, then card type"
- **UC-484**: Usuário configura New Card Sort Order como "Random"
- **UC-485**: Usuário configura New/Review Order (misturar, antes ou depois)
- **UC-486**: Usuário configura maximum answer seconds do internal timer
- **UC-487**: Usuário configura on-screen timer (show/stop on answer)
- **UC-488**: Usuário configura "Seconds to show question for" no Auto Advance
- **UC-489**: Usuário configura "Seconds to show answer for" no Auto Advance
- **UC-490**: Usuário simula workload futuro usando FSRS Simulator
- **UC-491**: Usuário configura parâmetros de simulação FSRS (days, additional cards, etc.)
- **UC-492**: Usuário avalia qualidade dos parâmetros FSRS (log loss, RMSE)
- **UC-493**: Usuário configura historical retention para preencher gaps no histórico
- **UC-494**: Usuário configura "Ignore Cards Reviewed Before" para otimização FSRS
- **UC-495**: Usuário otimiza parâmetros FSRS para todos os presets de uma vez
- **UC-496**: Usuário configura "Don't play audio automatically"
- **UC-497**: Usuário configura "Skip question when replaying answer"

### 2.4 Exclusão de Decks
- **UC-039**: Usuário exclui deck (com confirmação)
- **UC-040**: Sistema oferece opção de mover cards antes de excluir
- **UC-041**: Sistema cria backup automático antes de exclusão

### 2.5 Opções de Display Order Avançadas
- **UC-498**: Usuário configura Interday Learning/Review Order (misturar, antes ou depois)
- **UC-499**: Usuário configura Review Sort Order como "Due date, then random"
- **UC-500**: Usuário configura Review Sort Order como "Due date, then deck"
- **UC-501**: Usuário configura Review Sort Order como "Deck, then due date"
- **UC-502**: Usuário configura Review Sort Order como "Ascending intervals"
- **UC-503**: Usuário configura Review Sort Order como "Descending intervals"
- **UC-504**: Usuário configura Review Sort Order como "Ascending ease"
- **UC-505**: Usuário configura Review Sort Order como "Descending ease"
- **UC-506**: Usuário configura Review Sort Order como "Relative overdueness"
- **UC-507**: Usuário configura Review Sort Order como "Ascending retrievability" (FSRS)

## 3. Gerenciamento de Notes e Cards

### 3.1 Criação de Notes
- **UC-042**: Usuário cria nova note selecionando note type
- **UC-043**: Usuário preenche campos da note
- **UC-044**: Usuário adiciona tags à note
- **UC-045**: Usuário seleciona deck de destino
- **UC-046**: Sistema gera cards automaticamente baseado no note type
- **UC-047**: Usuário visualiza preview dos cards antes de salvar
- **UC-048**: Sistema valida campos obrigatórios antes de criar

### 3.2 Edição de Notes
- **UC-049**: Usuário edita note existente
- **UC-050**: Sistema atualiza todos os cards relacionados automaticamente
- **UC-051**: Usuário altera note type (com validação de campos)
- **UC-052**: Usuário move note para outro deck
- **UC-053**: Usuário adiciona/remove tags
- **UC-054**: Usuário marca/desmarca note como "marked"

### 3.3 Visualização e Busca
- **UC-055**: Usuário visualiza note específica
- **UC-056**: Usuário busca notes por texto simples
- **UC-057**: Usuário busca notes usando sintaxe avançada (tags, fields, etc.)
- **UC-058**: Usuário filtra notes por deck
- **UC-059**: Usuário filtra notes por tags
- **UC-060**: Usuário filtra notes por note type
- **UC-061**: Usuário busca notes com regular expressions
- **UC-062**: Usuário busca notes ignorando acentos (nc:)
- **UC-063**: Usuário visualiza notes em modo tabela (browser)
- **UC-064**: Usuário alterna entre visualização de cards e notes no browser

### 3.4 Exclusão
- **UC-065**: Usuário exclui note (exclui todos os cards relacionados)
- **UC-066**: Sistema solicita confirmação antes de excluir
- **UC-067**: Sistema registra exclusão no log de deletions

### 3.5 Operações em Lote
- **UC-068**: Usuário seleciona múltiplas notes
- **UC-069**: Usuário adiciona tag a múltiplas notes
- **UC-070**: Usuário remove tag de múltiplas notes
- **UC-071**: Usuário move múltiplas notes para outro deck
- **UC-072**: Usuário altera note type de múltiplas notes
- **UC-073**: Usuário exclui múltiplas notes
- **UC-074**: Usuário encontra duplicatas de notes
- **UC-430**: Usuário alterna marcação de notes (Toggle Mark - marca se desmarcada, desmarca se marcada)
- **UC-431**: Usuário limpa tags não utilizadas (Clear Unused Tags)
- **UC-432**: Usuário busca e substitui texto em múltiplas notes (Find and Replace)

### 3.6 Browser (Navegação e Visualização)
- **UC-395**: Usuário ordena colunas no browser (clique no cabeçalho)
- **UC-396**: Usuário ordena por múltiplas colunas no browser
- **UC-397**: Usuário configura quais colunas são exibidas no browser
- **UC-398**: Usuário redimensiona colunas no browser
- **UC-399**: Usuário edita note inline no browser (duplo clique)
- **UC-400**: Usuário aplica filtros visuais no browser (dropdowns)
- **UC-401**: Usuário busca e substitui texto em lote no browser
- **UC-402**: Usuário exporta resultados do browser diretamente
- **UC-403**: Usuário visualiza cards relacionados (siblings) no browser
- **UC-404**: Usuário salva configuração de colunas do browser
- **UC-433**: Usuário move cards selecionados para outro deck no browser (Change Deck)
- **UC-434**: Usuário exporta notes selecionadas do browser (Export Notes)
- **UC-508**: Usuário alterna entre Cards mode e Notes mode no browser
- **UC-509**: Usuário usa Sidebar Search Tool com modificadores (Ctrl, Shift, Alt)
- **UC-510**: Usuário usa Sidebar Selection Tool para seleção múltipla e drag-and-drop
- **UC-511**: Usuário salva busca atual na sidebar (Saved Searches)
- **UC-512**: Usuário edita items da sidebar (deletar/renomear tags, decks, saved searches)
- **UC-513**: Usuário busca item na sidebar tree
- **UC-514**: Sistema aplica background color baseado em flag/suspended/marked

## 4. Tipos de Nota (Note Types)

### 4.1 Gerenciamento de Note Types
- **UC-075**: Usuário cria novo note type
- **UC-076**: Usuário clona note type existente
- **UC-077**: Usuário edita note type (adiciona/remove campos)
- **UC-078**: Usuário renomeia note type
- **UC-079**: Usuário exclui note type (apenas se não houver notes usando)
- **UC-080**: Usuário visualiza lista de todos os note types

### 4.2 Campos
- **UC-081**: Usuário adiciona campo ao note type
- **UC-082**: Usuário remove campo do note type
- **UC-083**: Usuário renomeia campo
- **UC-084**: Usuário reordena campos
- **UC-085**: Usuário configura propriedades do campo (fonte, tamanho, RTL, etc.)
- **UC-086**: Usuário define campo como sort field
- **UC-087**: Usuário marca campo como sticky (não limpa após adicionar)

### 4.3 Card Types e Templates
- **UC-088**: Usuário adiciona card type ao note type
- **UC-089**: Usuário remove card type
- **UC-090**: Usuário edita front template do card
- **UC-091**: Usuário edita back template do card
- **UC-092**: Usuário edita styling (CSS) do card
- **UC-093**: Usuário configura browser appearance (template simplificado)
- **UC-094**: Usuário visualiza preview do card enquanto edita
- **UC-095**: Sistema valida sintaxe dos templates antes de salvar
- **UC-405**: Usuário configura deck override para card type específico
- **UC-406**: Sistema detecta e reporta conflitos de templates
- **UC-407**: Sistema detecta e reporta conflitos de cloze deletions
- **UC-408**: Sistema avisa sobre riscos de segurança ao habilitar LaTeX
- **UC-409**: Sistema avisa sobre riscos de segurança ao usar JavaScript em templates

### 4.4 Tipos de Nota Especiais
- **UC-096**: Usuário cria note tipo Basic (Front/Back)
- **UC-097**: Usuário cria note tipo Basic (and reversed) - 2 cards
- **UC-098**: Usuário cria note tipo Basic (optional reversed)
- **UC-099**: Usuário cria note tipo Basic (type in answer)
- **UC-100**: Usuário cria note tipo Cloze
- **UC-101**: Usuário cria note tipo Image Occlusion

## 5. Sistema de Estudo

### 5.1 Início de Sessão de Estudo
- **UC-102**: Usuário seleciona deck para estudar
- **UC-103**: Sistema exibe overview do deck (quantos cards para estudar)
- **UC-104**: Usuário inicia sessão de estudo
- **UC-105**: Sistema carrega cards para estudo baseado em limites e ordem

### 5.2 Revisão de Cards
- **UC-106**: Sistema exibe frente do card
- **UC-107**: Usuário tenta lembrar a resposta
- **UC-108**: Usuário clica "Show Answer" ou pressiona Space
- **UC-109**: Sistema exibe verso do card
- **UC-110**: Usuário avalia seu desempenho (Again, Hard, Good, Easy)
- **UC-111**: Sistema registra revisão e calcula próximo intervalo
- **UC-112**: Sistema atualiza estado do card (new → learn → review)
- **UC-113**: Sistema aplica algoritmo de repetição espaçada (SM-2 ou FSRS)
- **UC-114**: Sistema enterra siblings automaticamente (se configurado)
- **UC-115**: Sistema avança para próximo card

### 5.3 Funcionalidades Durante Estudo
- **UC-116**: Usuário edita card durante estudo
- **UC-117**: Usuário adiciona/remove flag do card
- **UC-118**: Usuário enterra card manualmente
- **UC-119**: Usuário suspende card
- **UC-120**: Usuário reseta card para new
- **UC-121**: Usuário define data de vencimento manualmente
- **UC-122**: Usuário visualiza informações detalhadas do card (Card Info)
- **UC-123**: Sistema exibe timer de resposta
- **UC-124**: Sistema registra tempo gasto em cada card
- **UC-125**: Sistema exibe progresso da sessão
- **UC-126**: Sistema exibe próximo intervalo previsto nos botões
- **UC-386**: Usuário visualiza informações do card anterior (Previous Card Info)
- **UC-387**: Usuário cria cópia da note atual (Create Copy)
- **UC-388**: Usuário desfaz última operação (Undo)
- **UC-389**: Usuário refaz operação desfeita (Redo)

### 5.4 Type in Answer
- **UC-127**: Usuário digita resposta no campo de texto
- **UC-128**: Sistema compara resposta digitada com resposta correta
- **UC-129**: Sistema destaca diferenças (correto/incorreto/faltando)
- **UC-130**: Sistema ignora diacríticos se configurado (type:nc)

### 5.5 Auto Advance e Timeboxing
- **UC-131**: Usuário ativa auto advance
- **UC-132**: Sistema avança automaticamente após tempo configurado
- **UC-133**: Usuário configura timeboxing (limite de tempo)
- **UC-134**: Sistema exibe notificações periódicas durante timeboxing
- **UC-135**: Sistema mostra estatísticas ao final do timebox

### 5.6 Áudio e Media Durante Estudo
- **UC-136**: Sistema reproduz áudio automaticamente (se configurado)
- **UC-137**: Usuário clica botão replay para repetir áudio
- **UC-138**: Sistema interrompe áudio ao responder (se configurado)
- **UC-139**: Sistema exibe imagens e vídeos nos cards
- **UC-390**: Usuário retrocede áudio em 5 segundos (-5s)
- **UC-391**: Usuário avança áudio em 5 segundos (+5s)
- **UC-392**: Usuário pausa/reproduz áudio
- **UC-393**: Usuário grava própria voz para verificação de pronúncia
- **UC-394**: Usuário reproduz própria voz gravada

## 6. Algoritmos de Repetição Espaçada

### 6.1 SM-2 (SuperMemo 2)
- **UC-140**: Sistema calcula intervalo usando algoritmo SM-2
- **UC-141**: Sistema ajusta ease factor baseado na resposta
- **UC-142**: Sistema aplica interval modifier
- **UC-143**: Sistema aplica easy bonus
- **UC-144**: Sistema aplica hard interval
- **UC-145**: Sistema aplica new interval após lapse
- **UC-146**: Sistema respeita maximum interval

### 6.2 FSRS (Free Spaced Repetition Scheduler)
- **UC-147**: Sistema calcula intervalo usando algoritmo FSRS
- **UC-148**: Sistema atualiza stability e difficulty do card
- **UC-149**: Sistema calcula retrievability
- **UC-150**: Sistema otimiza parâmetros FSRS baseado em histórico
- **UC-151**: Sistema avalia qualidade dos parâmetros (log loss, RMSE)
- **UC-152**: Sistema calcula minimum recommended retention
- **UC-153**: Sistema simula workload futuro
- **UC-154**: Sistema reschedule cards ao mudar desired retention (opcional)

### 6.3 Learning Steps
- **UC-155**: Sistema aplica learning steps para novos cards
- **UC-156**: Sistema aplica relearning steps para lapsed cards
- **UC-157**: Sistema converte steps que cruzam day boundary para dias
- **UC-158**: Sistema mostra cards em learning antes de reviews (se configurado)

## 7. Flags e Leeches

### 7.1 Sistema de Flags
- **UC-159**: Usuário adiciona flag colorida (0-7) ao card
- **UC-160**: Usuário remove flag do card
- **UC-161**: Usuário altera flag do card
- **UC-162**: Usuário busca cards por flag (flag:1, flag:2, etc.)
- **UC-163**: Usuário renomeia flags (personalização)
- **UC-164**: Sistema exibe flag visualmente no card durante estudo

### 7.2 Sistema de Leeches
- **UC-165**: Sistema detecta automaticamente cards com muitas falhas
- **UC-166**: Sistema adiciona tag "leech" automaticamente
- **UC-167**: Sistema suspende card automaticamente (se configurado)
- **UC-168**: Sistema alerta usuário sobre leeches periodicamente
- **UC-169**: Usuário visualiza lista de leeches
- **UC-170**: Usuário edita leech para melhorar memorização
- **UC-171**: Usuário exclui leech se não for importante
- **UC-172**: Usuário suspende leech temporariamente

## 8. Media (Imagens, Áudio, Vídeo)

### 8.1 Upload de Media
- **UC-173**: Usuário faz upload de imagem
- **UC-174**: Usuário faz upload de áudio
- **UC-175**: Usuário faz upload de vídeo
- **UC-176**: Sistema valida formato e tamanho do arquivo
- **UC-177**: Sistema gera hash para detecção de duplicatas
- **UC-178**: Sistema armazena media de forma segura
- **UC-179**: Usuário cola imagem da clipboard

### 8.2 Gerenciamento de Media
- **UC-180**: Sistema associa media aos campos das notes
- **UC-181**: Usuário visualiza media nos cards
- **UC-182**: Sistema verifica media não utilizada
- **UC-183**: Usuário exclui media não utilizada
- **UC-184**: Sistema restaura media excluída acidentalmente
- **UC-185**: Sistema sincroniza media entre dispositivos
- **UC-515**: Sistema tag notes que referenciam media faltante
- **UC-516**: Usuário esvazia trash folder de media
- **UC-517**: Usuário adiciona media manualmente à pasta de media

### 8.3 LaTeX e MathJax
- **UC-186**: Usuário adiciona equação LaTeX ao card
- **UC-187**: Sistema gera imagem da equação LaTeX
- **UC-188**: Sistema renderiza MathJax no navegador
- **UC-189**: Sistema suporta pacotes LaTeX customizados
- **UC-190**: Sistema valida sintaxe LaTeX antes de gerar

## 9. Templates e Styling

### 9.1 Templates
- **UC-191**: Sistema renderiza template front do card
- **UC-192**: Sistema renderiza template back do card
- **UC-193**: Sistema substitui field replacements ({{FieldName}})
- **UC-194**: Sistema processa conditional replacements ({{#Field}})
- **UC-195**: Sistema processa special fields ({{FrontSide}}, {{Tags}})
- **UC-196**: Sistema processa Text-to-Speech ({{tts lang:Field}})
- **UC-197**: Sistema processa Ruby characters ({{furigana:Field}})
- **UC-198**: Sistema processa type in answer ({{type:Field}})
- **UC-199**: Sistema aplica styling CSS ao card
- **UC-200**: Sistema aplica night mode styling

### 9.2 Funcionalidades Especiais de Templates
- **UC-201**: Sistema processa hints ({{hint:Field}})
- **UC-202**: Sistema cria links de dicionário dinâmicos
- **UC-203**: Sistema processa HTML stripping ({{text:Field}})
- **UC-204**: Sistema suporta Right-to-Left (RTL) text
- **UC-205**: Sistema processa múltiplos campos TTS
- **UC-206**: Sistema renderiza browser appearance simplificado
- **UC-410**: Sistema aplica fading automático ao mostrar resposta
- **UC-411**: Sistema faz scroll automático para elemento com id=answer
- **UC-412**: Usuário configura velocidade de fading (milliseconds)
- **UC-413**: Usuário instala fontes customizadas para uso nos cards
- **UC-414**: Sistema aplica CSS específico por plataforma (mobile, desktop)
- **UC-415**: Sistema renderiza JavaScript nos templates (com avisos de segurança)

## 10. Busca e Filtros

### 10.1 Busca Simples
- **UC-207**: Usuário busca por texto simples
- **UC-208**: Sistema busca em todos os campos
- **UC-209**: Sistema busca palavras completas (w:)
- **UC-210**: Sistema busca com wildcards (*, _)

### 10.2 Busca Avançada
- **UC-211**: Usuário busca em campo específico (front:dog)
- **UC-212**: Usuário busca por tags (tag:vocab)
- **UC-213**: Usuário busca por deck (deck:french)
- **UC-214**: Usuário busca por estado (is:new, is:due, is:review)
- **UC-215**: Usuário busca por propriedades (prop:ivl>=10)
- **UC-216**: Usuário busca com operadores lógicos (AND, OR, NOT)
- **UC-217**: Usuário busca com regular expressions (re:\d{3})
- **UC-218**: Usuário busca ignorando acentos (nc:uber)
- **UC-219**: Usuário busca por flag (flag:1)
- **UC-220**: Usuário busca por data (added:7, rated:1)

### 10.3 Filtros e Saved Searches
- **UC-221**: Usuário salva busca para uso futuro
- **UC-222**: Usuário aplica saved search
- **UC-223**: Usuário edita saved search
- **UC-224**: Usuário exclui saved search
- **UC-225**: Sistema usa saved search para filtered decks

## 11. Filtered Decks (Custom Study)

### 11.1 Criação de Filtered Decks
- **UC-226**: Usuário cria filtered deck com busca customizada
- **UC-227**: Sistema cria filtered deck via Custom Study (presets)
- **UC-228**: Usuário configura limite de cards no filtered deck
- **UC-229**: Usuário configura ordem de exibição
- **UC-230**: Usuário configura rescheduling (ativar/desativar)

### 11.2 Tipos de Custom Study
- **UC-231**: Usuário aumenta limite de novos cards do dia
- **UC-232**: Usuário aumenta limite de reviews do dia
- **UC-233**: Usuário estuda cards esquecidos (forgotten cards)
- **UC-234**: Usuário estuda cards antecipadamente (review ahead)
- **UC-235**: Usuário faz preview de novos cards
- **UC-236**: Usuário estuda por estado ou tag

### 11.3 Gerenciamento de Filtered Decks
- **UC-237**: Usuário reconstrói filtered deck (rebuild)
- **UC-238**: Usuário esvazia filtered deck (retorna cards aos home decks)
- **UC-239**: Usuário exclui filtered deck
- **UC-240**: Sistema retorna cards aos home decks automaticamente

## 12. Estatísticas e Relatórios

### 12.1 Estatísticas do Deck
- **UC-241**: Usuário visualiza estatísticas de deck específico
- **UC-242**: Sistema exibe gráfico de reviews por dia
- **UC-243**: Sistema exibe gráfico de tempo gasto
- **UC-244**: Sistema exibe distribuição de intervalos
- **UC-245**: Sistema exibe distribuição de ease factors
- **UC-246**: Sistema exibe distribuição de stability (FSRS)
- **UC-247**: Sistema exibe distribuição de difficulty (FSRS)
- **UC-248**: Sistema exibe distribuição de retrievability (FSRS)
- **UC-249**: Sistema exibe breakdown por hora do dia
- **UC-250**: Sistema exibe gráfico de answer buttons
- **UC-251**: Sistema exibe tabela de true retention

### 12.2 Estatísticas da Coleção
- **UC-252**: Usuário visualiza estatísticas de toda a coleção
- **UC-253**: Sistema exibe contagem de cards (mature, young, new, suspended)
- **UC-254**: Sistema exibe forecast de cards futuros (Future Due)
- **UC-255**: Sistema exibe calendário de atividade
- **UC-256**: Sistema calcula daily load estimado

### 12.3 Estatísticas do Card
- **UC-257**: Usuário visualiza informações detalhadas de card específico
- **UC-258**: Sistema exibe histórico completo de revisões
- **UC-259**: Sistema exibe intervalos anteriores
- **UC-260**: Sistema exibe ease factor histórico
- **UC-261**: Sistema exibe tempo gasto em cada revisão

### 12.4 Exportação de Estatísticas
- **UC-262**: Usuário exporta estatísticas como PDF
- **UC-263**: Sistema inclui todos os gráficos no PDF

## 13. Sincronização

### 13.1 Sincronização Básica
- **UC-264**: Usuário sincroniza coleção com servidor
- **UC-265**: Sistema detecta mudanças locais e remotas
- **UC-266**: Sistema mescla mudanças automaticamente
- **UC-267**: Sistema sincroniza media junto com dados
- **UC-268**: Sistema sincroniza automaticamente ao abrir/fechar (se configurado)

### 13.2 Resolução de Conflitos
- **UC-269**: Sistema detecta conflitos não mescláveis
- **UC-270**: Sistema solicita escolha do usuário (local vs remoto)
- **UC-271**: Sistema força sincronização unidirecional quando necessário
- **UC-272**: Sistema avisa sobre operações que requerem full sync

### 13.3 Sincronização Multi-dispositivo
- **UC-273**: Usuário acessa coleção de múltiplos dispositivos
- **UC-274**: Sistema mantém sincronização entre dispositivos
- **UC-275**: Sistema rastreia último sync por dispositivo
- **UC-276**: Sistema permite forçar upload ou download

### 13.4 Self-Hosted Sync Server
- **UC-528**: Administrador instala servidor de sync self-hosted
- **UC-529**: Administrador configura múltiplos usuários no servidor
- **UC-530**: Administrador configura senhas hasheadas
- **UC-531**: Administrador configura localização de armazenamento
- **UC-532**: Administrador configura acesso público ao servidor
- **UC-533**: Usuário configura cliente para usar servidor self-hosted
- **UC-534**: Administrador configura reverse proxy para servidor
- **UC-535**: Administrador configura limites de requisições grandes

## 14. Importação e Exportação

### 14.1 Importação
- **UC-277**: Usuário importa arquivo de texto (CSV, TSV)
- **UC-278**: Sistema mapeia colunas para campos
- **UC-279**: Sistema detecta e atualiza duplicatas
- **UC-280**: Usuário importa deck package (.apkg)
- **UC-281**: Sistema importa collection package (.colpkg)
- **UC-282**: Sistema importa de Mnemosyne (.db)
- **UC-283**: Sistema importa de SuperMemo (.xml)
- **UC-284**: Sistema importa media junto com dados
- **UC-285**: Sistema valida dados antes de importar
- **UC-437**: Usuário acessa biblioteca de decks compartilhados (Shared Decks)
- **UC-438**: Usuário busca decks compartilhados por categoria ou palavras-chave
- **UC-439**: Usuário visualiza informações e preview de deck compartilhado
- **UC-440**: Usuário baixa deck compartilhado (.apkg)
- **UC-441**: Sistema importa deck compartilhado automaticamente após download

### 14.2 Exportação
- **UC-286**: Usuário exporta deck como texto
- **UC-287**: Usuário exporta deck como package (.apkg)
- **UC-288**: Usuário exporta coleção completa (.colpkg)
- **UC-289**: Sistema inclui scheduling information (opcional)
- **UC-290**: Sistema inclui media nos packages
- **UC-291**: Sistema remove tags de leech/marked ao exportar para compartilhar

## 15. Preferências Globais

### 15.1 Aparência
- **UC-292**: Usuário configura idioma da interface
- **UC-293**: Usuário configura tema (dark/light/auto)
- **UC-294**: Usuário configura tamanho da UI
- **UC-295**: Usuário configura video driver
- **UC-296**: Usuário ativa/desativa modo minimalista
- **UC-297**: Usuário configura redução de movimento

### 15.2 Comportamento
- **UC-298**: Usuário configura horário de início do próximo dia
- **UC-299**: Usuário configura learn ahead limit
- **UC-300**: Usuário configura timebox time limit
- **UC-301**: Usuário configura comportamento de paste
- **UC-302**: Usuário configura busca (ignorar acentos, etc.)
- **UC-518**: Usuário reseta tamanhos e localizações de janelas
- **UC-519**: Usuário configura "Show play buttons on cards with audio"
- **UC-520**: Usuário configura "Interrupt current audio when answering"
- **UC-521**: Usuário configura "Show remaining card count"
- **UC-522**: Usuário configura "Show next review time above answer buttons"
- **UC-523**: Usuário configura "Spacebar (or enter) also answers card"
- **UC-524**: Usuário configura "Paste clipboard images as PNG"
- **UC-525**: Usuário configura "Default deck" (interação note types/decks)
- **UC-526**: Usuário configura "Default search text" no browser
- **UC-527**: Usuário configura "On next sync, force changes in one direction"

### 15.3 Sincronização
- **UC-303**: Usuário configura auto sync on open/close
- **UC-304**: Usuário configura sincronização periódica de media
- **UC-305**: Usuário configura servidor de sync customizado

## 16. Backups

### 16.1 Backups Automáticos
- **UC-306**: Sistema cria backup automático periodicamente
- **UC-307**: Sistema mantém backups diários, semanais e mensais
- **UC-308**: Sistema limpa backups antigos automaticamente
- **UC-309**: Sistema cria backup antes de operações destrutivas
- **UC-310**: Sistema cria backup antes de importar .colpkg

### 16.2 Backups Manuais
- **UC-311**: Usuário cria backup manual
- **UC-312**: Usuário visualiza lista de backups disponíveis
- **UC-313**: Usuário restaura backup específico
- **UC-314**: Sistema desabilita auto sync após restaurar backup
- **UC-315**: Usuário exclui backup antigo

## 17. Text-to-Speech (TTS)

### 17.1 Configuração TTS
- **UC-316**: Sistema detecta vozes disponíveis no sistema
- **UC-317**: Usuário configura idioma e voz para TTS
- **UC-318**: Sistema lista todas as vozes disponíveis ({{tts-voices:}})

### 17.2 Uso de TTS
- **UC-319**: Sistema lê campo automaticamente durante estudo
- **UC-320**: Sistema lê múltiplos campos e texto estático
- **UC-321**: Sistema lê apenas cloze deletions (cloze-only filter)
- **UC-322**: Sistema ajusta velocidade de fala (speed)
- **UC-323**: Sistema escolhe voz preferida da lista

## 18. Ruby Characters (Furigana)

### 18.1 Suporte a Furigana
- **UC-324**: Sistema renderiza furigana acima do texto ({{furigana:Field}})
- **UC-325**: Sistema exibe apenas kana ({{kana:Field}})
- **UC-326**: Sistema exibe apenas kanji ({{kanji:Field}})
- **UC-327**: Sistema processa múltiplas anotações ruby no mesmo campo
- **UC-328**: Sistema respeita espaços para posicionamento correto

## 19. Right-to-Left (RTL)

### 19.1 Suporte RTL
- **UC-329**: Sistema renderiza texto RTL corretamente
- **UC-330**: Usuário configura direção de texto no campo
- **UC-331**: Sistema aplica direção RTL no template (dir=rtl)
- **UC-332**: Sistema suporta RTL no editor

## 20. Unicode Normalization

### 20.1 Normalização
- **UC-333**: Sistema normaliza texto para busca consistente
- **UC-334**: Sistema preserva variantes Unicode se desabilitado
- **UC-335**: Sistema garante compatibilidade entre sistemas

## 21. Siblings e Burying

### 21.1 Burying Automático
- **UC-336**: Sistema enterra siblings automaticamente durante estudo
- **UC-337**: Sistema enterra new siblings se configurado
- **UC-338**: Sistema enterra review siblings se configurado
- **UC-339**: Sistema enterra interday learning siblings se configurado
- **UC-340**: Sistema não enterra cards em learning (time-critical)

### 21.2 Burying Manual
- **UC-341**: Usuário enterra card manualmente
- **UC-342**: Usuário desenterra cards enterrados
- **UC-343**: Sistema desenterra cards automaticamente no próximo dia
- **UC-344**: Sistema exibe contador de cards enterrados no overview

## 22. Card Generation Logic

### 22.1 Geração de Cards
- **UC-345**: Sistema gera cards baseado em templates do note type
- **UC-346**: Sistema não gera cards com front vazio
- **UC-347**: Sistema gera cards condicionalmente ({{#Field}})
- **UC-348**: Sistema detecta empty cards
- **UC-349**: Usuário limpa empty cards
- **UC-350**: Sistema regenera cards quando note é editada
- **UC-416**: Sistema cria card vazio usando primeiro template se nenhum card for gerado
- **UC-417**: Sistema exibe mensagem quando card está vazio durante estudo
- **UC-418**: Sistema lista empty cards antes de limpar (confirmação)

### 22.2 Cloze Cards
- **UC-351**: Sistema gera card para cada número de cloze (c1, c2, etc.)
- **UC-352**: Sistema suporta nested cloze deletions
- **UC-353**: Sistema detecta empty cloze cards
- **UC-354**: Sistema processa hints em cloze ({{c1::texto::hint}})

## 23. Operações Avançadas

### 23.1 Reposicionamento
- **UC-355**: Usuário reposiciona novos cards na fila
- **UC-356**: Sistema insere cards entre existentes (shift position)
- **UC-357**: Usuário reposiciona múltiplos cards de uma vez

### 23.2 Reset e Set Due
- **UC-358**: Usuário reseta card para new (preserva histórico)
- **UC-359**: Usuário reseta card restaurando posição original
- **UC-360**: Usuário reseta contadores de lapses e reps
- **UC-361**: Usuário define data de vencimento específica
- **UC-362**: Usuário define range de datas (60-90 dias)
- **UC-363**: Sistema converte new cards em review cards ao set due
- **UC-435**: Usuário usa "Forget" para resetar card completamente (esquece histórico)
- **UC-436**: Sistema aplica rescheduling quando range inclui "!" (altera intervalo)

## 24. Performance e Otimização

### 24.1 Otimização de Queries
- **UC-364**: Sistema otimiza queries de estudo (milhares de cards)
- **UC-365**: Sistema usa índices eficientemente
- **UC-366**: Sistema implementa paginação em listagens
- **UC-367**: Sistema cacheia queries frequentes

### 24.2 Background Jobs
- **UC-368**: Sistema executa otimização de banco em background
- **UC-369**: Sistema executa limpeza de media em background
- **UC-370**: Sistema executa geração de estatísticas em background

## 25. Segurança e Validação

### 25.1 Validação
- **UC-371**: Sistema valida todos os inputs do usuário
- **UC-372**: Sistema sanitiza dados antes de salvar
- **UC-373**: Sistema valida templates antes de renderizar
- **UC-374**: Sistema valida JavaScript custom scheduling (sandbox)

### 25.2 Segurança
- **UC-375**: Sistema implementa rate limiting
- **UC-376**: Sistema valida autenticação em todas as requisições
- **UC-377**: Sistema protege contra SQL injection
- **UC-378**: Sistema protege contra XSS em templates

## 26. Logging e Debugging

### 26.1 Logging
- **UC-379**: Sistema registra todas as operações importantes
- **UC-380**: Sistema registra erros com stack traces
- **UC-381**: Sistema mantém log de sincronização
- **UC-382**: Sistema mantém log de deletions

### 26.2 Debugging
- **UC-383**: Usuário acessa debug console
- **UC-384**: Sistema exibe informações de debug
- **UC-385**: Sistema permite executar código de debug

## 27. Manutenção e Verificação

### 27.1 Verificação de Integridade
- **UC-419**: Usuário executa verificação de integridade do banco (Check Database)
- **UC-420**: Sistema verifica se arquivo foi corrompido
- **UC-421**: Sistema reconstrói estruturas internas durante verificação
- **UC-422**: Sistema otimiza arquivo durante verificação
- **UC-423**: Sistema reporta problemas encontrados na verificação
- **UC-424**: Sistema sugere restaurar backup se corrupção for detectada
- **UC-425**: Sistema oferece opção de reparar corrupção se backup estiver muito antigo

### 27.2 Limpeza e Otimização
- **UC-426**: Sistema verifica e lista empty cards para limpeza
- **UC-427**: Sistema verifica e lista media não utilizada
- **UC-428**: Sistema otimiza índices do banco de dados
- **UC-429**: Sistema compacta banco de dados após operações grandes

## 28. Extensibilidade e Plugins

### 28.1 Sistema de Add-ons
- **UC-442**: Usuário acessa gerenciador de add-ons (Add-on Manager)
- **UC-443**: Usuário busca add-ons disponíveis
- **UC-444**: Usuário instala add-on pelo código
- **UC-445**: Usuário desinstala add-on
- **UC-446**: Usuário habilita/desabilita add-on
- **UC-447**: Usuário atualiza add-ons instalados
- **UC-448**: Sistema valida compatibilidade de add-ons com versão atual
- **UC-449**: Sistema avisa sobre add-ons incompatíveis após atualização
- **UC-450**: Usuário configura opções de add-ons (quando disponível)

## 29. Profiles (Perfis)

### 29.1 Gerenciamento de Profiles
- **UC-536**: Usuário cria novo perfil
- **UC-537**: Usuário renomeia perfil existente
- **UC-538**: Usuário deleta perfil
- **UC-539**: Usuário alterna entre perfis
- **UC-540**: Usuário restaura backup automático do perfil
- **UC-541**: Usuário faz downgrade da coleção para versão anterior do Anki
- **UC-542**: Sistema valida que apenas um perfil pode ser sincronizado com uma conta AnkiWeb

## Resumo

Total de casos de uso identificados: **542**

Estes casos de uso cobrem todas as funcionalidades principais do sistema Anki, desde operações básicas de CRUD até funcionalidades avançadas como FSRS, TTS, Ruby characters, sincronização multi-dispositivo, browser avançado, manutenção, verificação de integridade, decks compartilhados, sistema de add-ons, opções avançadas de deck, perfis de usuário e servidor de sync self-hosted.
