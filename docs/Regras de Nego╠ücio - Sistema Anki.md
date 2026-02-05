# Regras de Negócio - Sistema Anki Completo

Este documento descreve todas as regras de negócio do sistema Anki, definindo como o sistema deve se comportar em situações específicas.

## 1. Regras de Autenticação e Autorização

### BR-001: Unicidade de Email
- Um email PODE ser usado por apenas uma conta no sistema
- Tentativas de registro com email existente DEVEM ser rejeitadas
- Emails DEVEM ser validados antes de criar conta

### BR-002: Validação de Senha
- Senhas DEVEM ter no mínimo 8 caracteres
- Senhas DEVEM conter pelo menos uma letra e um número
- Senhas DEVEM ser criptografadas antes de armazenar (nunca em texto plano)

### BR-003: Sessões Múltiplas
- Um usuário PODE ter múltiplas sessões ativas simultaneamente (diferentes dispositivos)
- Cada sessão DEVE ter seu próprio token JWT
- Logout em um dispositivo NÃO DEVE afetar outras sessões

### BR-004: Isolamento de Dados
- Usuários SÓ PODEM acessar seus próprios dados
- Tentativas de acesso a dados de outros usuários DEVEM ser rejeitadas
- IDs de recursos DEVEM ser validados contra ownership antes de operações

## 2. Regras de Decks

### BR-005: Hierarquia de Decks
- Decks PODEM ter subdecks (hierarquia)
- Nomes de decks são únicos por nível na hierarquia
- Ao estudar um deck pai, cards de subdecks TAMBÉM são incluídos
- Limites diários de subdecks são independentes, mas total é controlado pelo deck pai

### BR-006: Nomes de Decks
- Nomes de decks NÃO PODEM conter apenas "::" (separador de hierarquia)
- Decks são ordenados alfabeticamente na lista
- Números em nomes são ordenados como strings (ex: "Deck 10" vem antes de "Deck 9")
- Prefixos "-" e "~" podem ser usados para controlar ordem (aparecem primeiro e último)

### BR-007: Deck Default
- Sistema DEVE criar deck "Default" para novos usuários
- Deck "Default" é ocultado se estiver vazio e houver outros decks
- Cards órfãos (sem deck) DEVEM ir para "Default"

### BR-008: Exclusão de Decks
- Ao excluir deck, cards NÃO são excluídos automaticamente
- Sistema DEVE oferecer opção de mover cards antes de excluir
- Exclusão de deck pai NÃO exclui subdecks automaticamente

## 3. Regras de Notes e Cards

### BR-009: Geração de Cards
- Cards são gerados AUTOMATICAMENTE quando note é criada
- Card NÃO é gerado se front template resultar em vazio
- Múltiplos cards são gerados se note type define múltiplos card types
- Cards são regenerados quando note é editada

### BR-010: Unicidade de Notes
- Notes são únicas baseadas no primeiro campo do note type
- Duplicatas são detectadas apenas dentro do mesmo note type
- Sistema AVISA sobre duplicatas, mas permite criar (com confirmação)

### BR-011: Relação Note-Card
- Uma note PODE gerar múltiplos cards
- Cards relacionados (mesma note) são chamados "siblings"
- Edição de note ATUALIZA todos os cards relacionados
- Exclusão de note EXCLUI todos os cards relacionados

### BR-012: Estados de Cards
- Card pode estar em estados: **new**, **learn**, **review**, **relearn**
- **new**: Nunca foi estudado
- **learn**: Em processo de aprendizado (learning steps)
- **review**: Aprendido, aguardando revisão
- **relearn**: Esquecido, em processo de reaprendizado
- Card **young**: Intervalo < 21 dias
- Card **mature**: Intervalo ≥ 21 dias

### BR-013: Campos Obrigatórios
- Primeiro campo do note type é SEMPRE obrigatório
- Outros campos podem ser opcionais (depende do template)
- Sistema NÃO gera card se campos obrigatórios do front template estiverem vazios

## 4. Regras de Repetição Espaçada

### BR-014: Algoritmo SM-2 - Cálculo de Intervalo
- **Again (1)**: Card volta para primeiro learning step (se em learn) ou relearning (se em review)
- **Hard (2)**: 
  - Se em primeiro learning step: delay = média dos dois primeiros steps
  - Se em outros steps: repete o step atual
  - Se em review: novo intervalo = intervalo anterior × hard interval multiplier
- **Good (3)**: 
  - Se em learning: avança para próximo step
  - Se em review: novo intervalo = intervalo anterior × ease factor × interval modifier
- **Easy (4)**: 
  - Se em learning: pula para review com easy interval
  - Se em review: novo intervalo = intervalo anterior × ease factor × easy bonus × interval modifier

### BR-015: Algoritmo SM-2 - Ajuste de Ease
- Ease inicial: 2.50 (2500 em permille)
- **Again**: Ease diminui (fórmula: ease × 0.8, mínimo 1.30)
- **Hard**: Ease não muda
- **Good**: Ease não muda
- **Easy**: Ease aumenta (fórmula: ease + 0.15, máximo não definido)

### BR-016: Algoritmo SM-2 - Garantias
- Novo intervalo DEVE ser pelo menos 1 dia maior que intervalo anterior
- Intervalo máximo é respeitado (default: 100 anos)
- Interval modifier é aplicado a TODOS os intervalos

### BR-017: Algoritmo FSRS - Cálculo de Intervalo
- FSRS calcula intervalo baseado em: stability, difficulty, retrievability
- **Again**: Diminui stability, aumenta difficulty
- **Hard**: Mantém ou diminui ligeiramente stability
- **Good**: Aumenta stability baseado em difficulty
- **Easy**: Aumenta stability significativamente
- Intervalo = stability × função de retrievability e desired retention

### BR-018: Algoritmo FSRS - Otimização
- Parâmetros FSRS DEVEM ser otimizados baseados em histórico de revisões
- Otimização requer pelo menos 100 revisões para ser confiável
- Parâmetros são específicos por preset (diferentes decks podem ter parâmetros diferentes)
- Otimização NÃO deve ser feita mais que uma vez por mês

### BR-019: Learning Steps
- Learning steps são aplicados em sequência
- Card avança para próximo step ao responder "Good"
- Card volta para primeiro step ao responder "Again"
- Steps que cruzam day boundary são convertidos para dias
- Cards em learning têm prioridade sobre reviews (mostrados primeiro)

### BR-020: Day Boundary
- Próximo dia começa no horário configurado (default: 4AM)
- Cards que cruzam day boundary são convertidos para dias
- Sistema considera timezone do usuário
- Cards que se tornam due após day boundary aparecem no próximo dia

### BR-021: Fuzz Factor
- Intervalos de review recebem "fuzz" aleatório (±25% do intervalo)
- Fuzz previne que cards introduzidos juntos sempre apareçam juntos
- Fuzz NÃO pode ser desabilitado
- Learning cards recebem até 5 minutos de delay extra (aleatório)

## 5. Regras de Estudo

### BR-022: Ordem de Exibição
- Cards são mostrados na ordem configurada (display order)
- Ordem padrão: learning cards primeiro, depois reviews, depois novos
- Cards em learning são mostrados na ordem que ficam due
- Reviews são ordenados por due date (mais antigos primeiro)

### BR-023: Limites Diários
- Limite de novos cards é aplicado POR DIA
- Limite de reviews é aplicado POR DIA
- Limites são resetados no início do próximo dia
- Se estudar menos que o limite, não acumula para o próximo dia
- Limites de subdecks são independentes, mas total é limitado pelo deck pai

### BR-024: Learn Ahead Limit
- Cards em learning PODEM ser mostrados até X minutos antes do due (default: 20min)
- Isso só acontece se NÃO houver outros cards para estudar
- Se learn ahead = 0, sistema espera tempo completo antes de mostrar

### BR-025: Burying de Siblings
- Ao estudar um card, siblings PODEM ser enterrados automaticamente
- Burying é configurável separadamente para: new siblings, review siblings, interday learning siblings
- Cards em learning NÃO são enterrados (time-critical)
- Cards enterrados são desenterrados no próximo dia
- Siblings são enterrados mesmo se estiverem em decks diferentes

### BR-026: Prioridade de Burying
- Ordem de prioridade: learning > review > new
- Sibling com maior prioridade é mostrado primeiro
- Siblings com menor prioridade NÃO podem enterrar os de maior prioridade

## 6. Regras de Flags

### BR-027: Sistema de Flags
- Cards PODEM ter uma flag (0-7), onde 0 = sem flag
- Flags são a nível de CARD, não note
- Flags PODEM ser renomeadas pelo usuário
- Flags são visíveis durante estudo
- Flags PODEM ser usadas em buscas (flag:1, flag:2, etc.)

### BR-028: Flags e Siblings
- Flagging um card NÃO afeta seus siblings
- Cada card tem sua própria flag independente

## 7. Regras de Leeches

### BR-029: Detecção de Leeches
- Card é marcado como leech quando número de lapses atinge threshold (default: 8)
- Lapse = quando card em review é respondido como "Again"
- Sistema adiciona tag "leech" automaticamente
- Sistema PODE suspender card automaticamente (se configurado)

### BR-030: Alertas de Leeches
- Após threshold inicial, alertas são dados a cada metade do threshold (ex: 8, 12, 16, 20...)
- Alertas são dados mesmo se card já foi suspenso
- Usuário DEVE ser notificado sobre leeches

### BR-031: Tratamento de Leeches
- Leeches PODEM ser editados para melhorar memorização
- Leeches PODEM ser excluídos se não forem importantes
- Leeches PODEM ser suspensos temporariamente
- Sistema NÃO remove automaticamente tag "leech" após edição

## 8. Regras de Media

### BR-032: Unicidade de Media
- Media é identificada por hash (SHA-256)
- Media com mesmo hash é compartilhada (não duplicada)
- Sistema detecta duplicatas automaticamente

### BR-033: Validação de Media
- Formatos suportados: JPG, PNG, GIF, WebP, MP3, OGG, WAV, MP4, WebM
- Tamanho máximo por arquivo: 100MB
- Sistema valida tipo MIME do arquivo
- Arquivos inválidos são rejeitados

### BR-034: Limpeza de Media
- Media não utilizada PODE ser detectada e excluída
- Media usada em templates (prefixo "_") NÃO é considerada não utilizada
- Exclusão de media move arquivo para lixeira (pode ser restaurado)
- Media excluída é removida do servidor após sincronização completa

## 9. Regras de Templates

### BR-035: Renderização de Templates
- Templates são renderizados como HTML
- Field replacements ({{FieldName}}) são substituídos pelo conteúdo do campo
- Conditional replacements ({{#Field}}) só mostram conteúdo se campo não estiver vazio
- Special fields são substituídos por valores especiais ({{FrontSide}}, {{Tags}}, etc.)

### BR-036: Geração de Cards Baseada em Templates
- Card NÃO é gerado se front template resultar em vazio após substituições
- Conditional replacements no front template controlam geração de cards
- Back template PODE estar vazio (card ainda é gerado)

### BR-037: Cloze Deletions
- Cada número de cloze (c1, c2, etc.) gera um card separado
- Múltiplos clozes com mesmo número geram um único card
- Cloze nested é suportado (até 3 níveis)
- Cloze com hint: {{c1::texto::hint}} mostra hint no lugar do texto

### BR-038: Type in Answer
- Apenas UM campo pode ter type in answer por card
- Type in answer suporta apenas uma linha
- Comparação é case-insensitive por padrão
- Diacríticos podem ser ignorados (type:nc)

## 10. Regras de Busca

### BR-039: Sintaxe de Busca
- Busca simples: múltiplos termos são unidos com AND
- Operador OR: "dog or cat" encontra notes com qualquer um
- Operador NOT: "-cat" exclui notes com "cat"
- Agrupamento: parênteses controlam precedência

### BR-040: Busca por Campo
- Busca em campo específico requer match exato por padrão
- Wildcards (*, _) podem ser usados para busca parcial
- Busca em campo é case-sensitive

### BR-041: Busca por Estado
- is:new = cards nunca estudados
- is:learn = cards em learning
- is:review = cards em review (inclui due e não due)
- is:due = cards que devem ser estudados hoje
- is:suspended = cards suspensos
- is:buried = cards enterrados

### BR-042: Busca por Propriedades
- prop:ivl>=10 = intervalo maior ou igual a 10 dias
- prop:due=-1 = cards que venceram ontem
- prop:lapses>3 = mais de 3 lapses
- prop:reps<10 = menos de 10 revisões

### BR-043: Busca com Regular Expressions
- Busca com "re:" usa regular expressions
- Case-insensitive por padrão
- Suporta sintaxe completa de regex (conforme crate regex)

## 11. Regras de Sincronização

### BR-044: Sincronização Bidirecional
- Mudanças locais e remotas são mescladas automaticamente quando possível
- Reviews e edições de notes PODEM ser mescladas
- Mudanças em estrutura (note types, decks) requerem escolha manual

### BR-045: Detecção de Conflitos
- Conflitos são detectados quando mesma entidade é modificada em ambos os lados
- Conflitos não mescláveis requerem escolha do usuário (local vs remoto)
- Sistema AVISA antes de operações que causam conflitos

### BR-046: Versionamento
- Cada objeto (note, card, deck) tem timestamp de modificação
- Objeto mais recente vence em caso de conflito mesclável
- Sistema mantém histórico de modificações para resolução de conflitos

### BR-047: Sincronização de Media
- Media é sincronizada separadamente dos dados
- Deletions de media só sincronizam após media estar completamente sincronizada
- Media não utilizada localmente é restaurada se ainda existir no servidor

## 12. Regras de Importação/Exportação

### BR-048: Detecção de Duplicatas na Importação
- Duplicatas são detectadas pelo primeiro campo (ou GUID se fornecido)
- Se GUID fornecido e existir, note é atualizada (não duplicada)
- Se primeiro campo igual e mesmo note type, note é atualizada (se configurado)
- Duplicatas podem ser ignoradas, atualizadas ou criadas como novas

### BR-049: Importação de Scheduling
- Scheduling information é importada apenas se explicitamente solicitado
- Ao importar deck compartilhado, scheduling é removido por padrão
- Scheduling importado pode ter intervalos grandes (do autor original)

### BR-050: Exportação para Compartilhamento
- Ao exportar para compartilhar, tags "leech" e "marked" são removidas
- Scheduling information pode ser incluída ou removida
- Media é sempre incluída em packages

## 13. Regras de Filtered Decks

### BR-051: Criação de Filtered Decks
- Filtered deck é criado com busca e configurações
- Cards são movidos temporariamente do home deck para filtered deck
- Cards retornam ao home deck após estudo (ou quando deck é esvaziado)

### BR-052: Rebuild de Filtered Decks
- Rebuild reaplica busca e atualiza cards no filtered deck
- Cards que não atendem mais à busca retornam ao home deck
- Cards que agora atendem são adicionados ao filtered deck

### BR-053: Rescheduling em Filtered Decks
- Se rescheduling habilitado: intervalos são ajustados baseados em performance
- Se rescheduling desabilitado: cards retornam com intervalos inalterados
- Review ahead usa algoritmo especial que considera quanto antes está sendo revisado

## 14. Regras de Estatísticas

### BR-054: Cálculo de Retention
- True retention = porcentagem de cards lembrados quando due
- Apenas primeira revisão do dia conta para cada card
- Again = Fail, Hard/Good/Easy = Pass
- Mature cards = intervalo ≥ 21 dias

### BR-055: Daily Load
- Daily load = soma de 1/intervalo para todos os cards
- Cards com intervalo < 1 dia contam como 1
- Representa média de cards due por dia

### BR-056: Estatísticas por Período
- Estatísticas podem ser calculadas para: 12 meses, toda história, vida do deck
- Estatísticas de hoje são sempre mostradas (não afetadas por período)
- Gráficos são agregados por dia/semana/mês conforme período

## 15. Regras de Backups

### BR-057: Backups Automáticos
- Backup é criado automaticamente a cada 30 minutos (configurável)
- Backup é criado antes de operações destrutivas
- Backups são mantidos por 2 dias, depois alguns são mantidos (diários, semanais, mensais)

### BR-058: Retenção de Backups
- Backups diários: mantidos por 7 dias (configurável)
- Backups semanais: mantidos por 4 semanas (configurável)
- Backups mensais: mantidos por 12 meses (configurável)
- Backups mais antigos são excluídos automaticamente

### BR-059: Restauração de Backups
- Ao restaurar backup, mudanças desde o backup são PERDIDAS
- Sistema desabilita auto sync após restaurar
- Usuário DEVE confirmar antes de restaurar

## 16. Regras de Preferências

### BR-060: Preferências Globais
- Preferências são por usuário (não por dispositivo)
- Preferências são sincronizadas entre dispositivos
- Mudanças em preferências são aplicadas imediatamente

### BR-061: Preferências de Deck
- Preferências de deck são por deck (ou preset)
- Subdecks herdam opções do deck pai (exceto limites diários)
- Mudanças em preset afetam todos os decks que usam o preset

## 17. Regras de Text-to-Speech

### BR-062: TTS em Templates
- {{tts lang:Field}} lê o campo no idioma especificado
- Múltiplas vozes podem ser especificadas (primeira disponível é usada)
- Velocidade pode ser ajustada (speed parameter)
- TTS funciona apenas em clientes desktop/mobile (não em web)

### BR-063: TTS e Cloze
- {{tts:cloze-only:Field}} lê apenas as partes ocultas do cloze
- TTS normal lê todo o campo incluindo clozes

## 18. Regras de Ruby Characters

### BR-064: Sintaxe de Furigana
- Formato: Texto[Ruby]
- Múltiplas anotações no mesmo campo são suportadas
- Espaços são necessários para separar anotações adjacentes
- Filtros: furigana (mostra tudo), kana (só ruby), kanji (só texto)

## 19. Regras de Unicode

### BR-065: Normalização Unicode
- Texto é normalizado para NFC por padrão
- Normalização garante busca consistente entre sistemas
- Normalização pode ser desabilitada (preserva variantes)
- Normalização afeta busca, mas não exibição

## 20. Regras de Card Generation

### BR-066: Geração Condicional
- {{#Field}}...{{/Field}} só inclui conteúdo se Field não estiver vazio
- {{^Field}}...{{/Field}} só inclui conteúdo se Field estiver vazio
- Conditional replacements no front template controlam geração de cards
- Múltiplas condições podem ser aninhadas

### BR-067: Empty Cards
- Cards com front vazio são chamados "empty cards"
- Empty cards NÃO são excluídos automaticamente (previne perda acidental)
- Empty cards PODEM ser limpos manualmente (Tools > Empty Cards)
- Sistema AVISA sobre empty cards
- Se nenhum card for gerado de uma note, sistema cria card vazio usando primeiro template
- Card vazio exibe mensagem durante estudo indicando que está vazio
- Empty cards são listados antes de limpar (com confirmação)

## 21. Regras de Operações em Cards

### BR-068: Reset de Card
- Reset move card para fim da fila de novos cards
- Reset preserva histórico de revisões
- Reset pode restaurar posição original (se configurado)
- Reset pode zerar contadores de lapses e reps (se configurado)
- "Forget" reseta card completamente (esquece histórico, remove todas as revisões)
- Forget move card para new state sem preservar nada

### BR-069: Set Due Date
- Set due converte new card em review card
- Set due pode definir data específica ou range
- Range gera datas aleatórias dentro do range
- Com "!" no final do range, intervalo é alterado (não apenas data)
- Rescheduling com "!" altera intervalo de review cards (não apenas due date)
- Rescheduling com "!" adiciona entrada de review ao histórico

### BR-070: Suspend e Bury
- Suspended cards NÃO aparecem em estudo até serem unsuspended
- Buried cards NÃO aparecem até próximo dia ou serem unburied
- Card NÃO pode estar suspended E buried simultaneamente
- Suspender card enterrado o desenterra automaticamente

## 22. Regras de FSRS Avançado

### BR-071: Desired Retention
- Desired retention controla probabilidade de lembrar quando due
- Default: 90% (0.90)
- Valores altos (>97%) aumentam workload drasticamente
- Valores baixos (< mínimo recomendado) aumentam esquecimento

### BR-072: Reschedule Cards on Change
- Ao mudar desired retention ou parâmetros, cards PODEM ser rescheduled
- Rescheduling altera due dates imediatamente
- Rescheduling adiciona entrada de review a cada card
- Rescheduling NÃO é recomendado na primeira vez que habilita FSRS

### BR-073: Historical Retention
- Quando histórico está incompleto, FSRS assume retention padrão (90%)
- Historical retention pode ser ajustado se retention real era diferente
- Usado apenas quando histórico está incompleto (ignore cards reviewed before)

## 23. Regras de Easy Days

### BR-074: Ajuste por Dia da Semana
- Easy Days ajusta intervalos baseado no dia da semana
- Ajuste é aplicado após cálculo do intervalo
- Todos os dias como "Reduced" ou "Minimum" = mesmo que "Normal"
- Mudanças em Easy Days NÃO afetam intervalos existentes (apenas futuros)

## 24. Regras de Custom Scheduling

### BR-075: JavaScript Customizado
- Custom scheduling permite código JavaScript para controlar intervalos
- Código é executado em sandbox (segurança)
- Código tem acesso a estados de scheduling
- Código é global (aplica a todos os presets)

## 25. Regras de Siblings

### BR-076: Identificação de Siblings
- Cards são siblings se foram gerados da mesma note
- Siblings podem estar em decks diferentes
- Siblings são identificados pela note ID

### BR-077: Burying de Siblings
- Burying de siblings é configurável por tipo (new, review, interday learning)
- Siblings são enterrados mesmo em decks diferentes
- Cards em learning NÃO são enterrados (time-critical)
- Siblings enterrados são desenterrados no próximo dia

## 26. Regras de Media e LaTeX

### BR-078: LaTeX Security
- LaTeX pode conter comandos maliciosos
- Sistema BLOQUEIA geração de LaTeX por padrão
- Usuário DEVE habilitar explicitamente geração de LaTeX
- Sistema AVISA sobre riscos de segurança ao habilitar

### BR-079: Media em Templates
- Media referenciada em templates (prefixo "_") NÃO é considerada não utilizada
- Media em campos é detectada automaticamente
- Media em templates NÃO é detectada (performance)

## 27. Regras de Busca Avançada

### BR-080: Busca com Ignorar Acentos
- Busca com "nc:" ignora caracteres combinados
- Mais lenta que busca normal
- Útil para idiomas com acentos

### BR-081: Busca por Object IDs
- nid:123 busca note com ID 123
- cid:123,456 busca cards com IDs 123 ou 456
- Útil para desenvolvimento e debugging

## 28. Regras de Importação

### BR-082: Headers em Arquivos de Texto
- Headers começam com "#" e definem comportamento de importação
- Headers suportados: separator, html, tags, columns, notetype, deck, etc.
- Headers DEVEM estar no início do arquivo

### BR-083: Mapeamento de Colunas
- Colunas são mapeadas para campos na ordem
- Colunas especiais (notetype, deck, tags, guid) não contam como campos regulares
- Primeira coluna regular mapeia para primeiro campo, etc.

## 29. Regras de Exportação

### BR-084: Formato de Exportação
- Exportação como texto preserva HTML
- Exportação como package inclui scheduling (opcional)
- Exportação para compartilhar remove tags de leech/marked
- Collection package substitui coleção inteira ao importar

## 30. Regras de Performance

### BR-085: Limites de Operações
- Queries de estudo são limitadas a 10.000 cards por vez
- Busca retorna máximo de 10.000 resultados
- Paginação é obrigatória para listagens grandes
- Operações longas são executadas em background

### BR-086: Cache
- Estatísticas são cacheadas por 5 minutos
- Overview de decks é cacheado por 1 minuto
- Cache é invalidado quando dados relevantes mudam

## 31. Regras de Browser

### BR-087: Operações no Browser
- Browser pode exibir cards ou notes (modo alternável)
- Ordenação é aplicada por coluna (clique no cabeçalho)
- Ordenação múltipla é suportada (shift+clique)
- Filtros visuais são aplicados em tempo real
- Configuração de colunas é salva por usuário

### BR-088: Busca e Substituição no Browser
- Find and Replace opera apenas em notes selecionadas
- Substituição é case-sensitive por padrão
- Substituição pode usar regular expressions
- Sistema AVISA sobre número de substituições antes de aplicar
- Substituição pode ser desfeita (undo)

### BR-089: Exportação do Browser
- Exportação do browser inclui apenas notes/cards selecionados
- Se nenhum selecionado, exporta todos os resultados da busca atual
- Formato de exportação segue preferências do usuário

## 32. Regras de Operações em Lote

### BR-090: Toggle Mark
- Toggle Mark verifica estado da note atual (marcada ou não)
- Se note atual está marcada: desmarca todas as selecionadas
- Se note atual NÃO está marcada: marca todas as selecionadas
- Operação é aplicada a todas as notes selecionadas simultaneamente

### BR-091: Clear Unused Tags
- Tags não utilizadas são identificadas por busca
- Sistema lista todas as tags não utilizadas antes de limpar
- Limpeza remove tags apenas da sidebar (não afeta notes)
- Tags podem ser restauradas se forem adicionadas novamente

## 33. Regras de Templates e Conflitos

### BR-092: Deck Override
- Deck Override permite que card type específico vá para deck diferente
- Override tem precedência sobre deck selecionado no Add Notes
- Override é aplicado apenas aos cards gerados do card type específico
- Override pode ser removido (volta ao comportamento padrão)

### BR-093: Conflitos de Templates
- Conflitos de templates são detectados quando múltiplos card types geram mesmo card
- Sistema AVISA sobre conflitos antes de salvar
- Conflitos podem ser resolvidos editando templates
- Conflitos não impedem salvamento, mas podem causar comportamento inesperado

### BR-094: Conflitos de Cloze
- Conflitos de cloze ocorrem quando mesmo número é usado em contextos incompatíveis
- Sistema detecta clozes nested incorretamente
- Sistema AVISA sobre conflitos antes de gerar cards
- Conflitos podem ser resolvidos renumerando clozes

## 34. Regras de Styling e Comportamento

### BR-095: Fading e Scrolling
- Fading é aplicado automaticamente ao mostrar resposta (default: 100ms)
- Fading pode ser desabilitado (0ms)
- Scrolling automático procura elemento com id=answer
- Se id=answer não existir, scrolling é desabilitado
- Velocidade de fading é configurável por usuário

### BR-096: Fontes Customizadas
- Fontes podem ser instaladas pelo usuário
- Fontes são armazenadas localmente (não sincronizadas)
- Fontes são referenciadas por nome no CSS
- Sistema valida existência da fonte antes de usar

## 35. Regras de Funcionalidades Durante Estudo

### BR-097: Previous Card Info
- Previous Card Info mostra informações do card estudado anteriormente
- Informações incluem: intervalo, ease, histórico recente
- Previous Card Info só está disponível se houver card anterior na sessão
- Informações são resetadas ao iniciar nova sessão

### BR-098: Create Copy
- Create Copy cria duplicata da note atual
- Cópia é criada no mesmo deck por padrão
- Cópia mantém todos os campos e tags
- Cópia gera novos cards (não compartilha cards com original)
- Cópia pode ser editada independentemente

### BR-099: Undo/Redo
- Undo reverte última operação realizada
- Redo refaz operação desfeita
- Histórico é limitado (máximo 50 operações ou 5MB)
- Histórico é limpo ao fechar aplicação
- Operações irreversíveis (exclusão permanente) não podem ser desfeitas

## 36. Regras de Shared Decks

### BR-100: Download de Shared Decks
- Shared decks são baixados como packages (.apkg)
- Download remove scheduling information por padrão
- Download remove tags de leech/marked por padrão
- Media é sempre incluída no download
- Sistema valida integridade do package após download

### BR-101: Compartilhamento de Decks
- Decks podem ser compartilhados publicamente
- Autor mantém controle sobre deck compartilhado
- Atualizações do autor são refletidas no deck compartilhado
- Sistema rastreia número de downloads e avaliações

## 37. Regras de Add-ons

### BR-102: Instalação de Add-ons
- Add-ons são instalados por código único
- Sistema valida compatibilidade antes de instalar
- Add-ons incompatíveis são bloqueados
- Sistema AVISA sobre add-ons incompatíveis após atualização

### BR-103: Segurança de Add-ons
- Add-ons são executados em sandbox isolado
- Add-ons NÃO podem acessar dados de outros usuários
- Add-ons NÃO podem modificar dados críticos sem permissão
- Sistema limita recursos disponíveis para add-ons (CPU, memória, tempo)
- Ações de add-ons são logadas para auditoria

### BR-104: Desabilitação de Add-ons
- Add-ons problemáticos podem ser desabilitados automaticamente
- Sistema detecta add-ons que causam crashes ou performance ruim
- Usuário pode desabilitar add-ons manualmente
- Add-ons desabilitados não são executados

## 38. Regras de Manutenção

### BR-105: Check Database
- Check Database verifica integridade do banco de dados
- Verificação é executada em background (não bloqueia sistema)
- Verificação reconstrói estruturas internas se necessário
- Verificação otimiza arquivo se necessário
- Se corrupção for detectada, sistema sugere restaurar backup
- Se backup estiver muito antigo, sistema oferece opção de reparar

### BR-106: Limpeza e Otimização
- Empty cards são listados antes de limpar (com confirmação)
- Media não utilizada é listada antes de excluir
- Otimização de índices é executada em background
- Compactação de banco é executada após operações grandes

## 39. Regras de Profiles

### BR-107: Criação e Gerenciamento de Profiles
- Usuário PODE criar múltiplos perfis
- Cada perfil tem sua própria coleção isolada (decks, notes, cards)
- Nomes de perfis são únicos por usuário
- Perfis PODEM ser renomeados e deletados
- Exclusão de perfil exclui toda a coleção do perfil (com confirmação)

### BR-108: Sincronização de Profiles
- Apenas UM perfil por usuário PODE sincronizar com uma conta AnkiWeb
- Sistema VALIDA que apenas um perfil está sincronizado antes de permitir sincronização
- Add-ons são compartilhados entre perfis (mas configurações são por perfil)
- Preferências são por perfil (não compartilhadas)

### BR-109: Alternância de Profiles
- Usuário PODE alternar entre perfis a qualquer momento
- Ao alternar perfil, sistema salva estado atual e carrega novo perfil
- Backups são por perfil (cada perfil tem seus próprios backups)

## 40. Regras de Per-Deck Daily Limits

### BR-110: Per-Deck Daily Limits
- Per-Deck Daily Limits pode ser: "preset", "this_deck" ou "today_only"
- "preset": Usa limite do preset compartilhado
- "this_deck": Usa limite específico deste deck (não compartilhado com preset)
- "today_only": Limite temporário apenas para hoje (reseta amanhã)
- Limites de subdecks são independentes, mas total é controlado pelo deck pai (se "limits_start_from_top" estiver habilitado)

### BR-111: New Cards Ignore Review Limit
- Se habilitado, novos cards são mostrados mesmo quando limite de reviews foi atingido
- Isso permite estudar novos cards mesmo após completar reviews do dia
- Aplicado apenas a novos cards (não a cards em learning)

### BR-112: Limits Start From Top
- Se habilitado, limites de decks superiores também se aplicam a subdecks
- Total de cards estudados em subdecks não pode exceder limite do deck pai
- Se desabilitado, cada deck tem limites completamente independentes

## 41. Regras de Display Order Avançado

### BR-113: New Card Gather Order
- Controla como novos cards são coletados antes de ordenação
- Opções: "deck", "deck_then_random_notes", "ascending_position", "descending_position", "random_notes", "random_cards"
- "deck": Por ordem de deck na hierarquia
- "random_notes": Notas aleatórias (todos os cards da mesma note juntos)
- "random_cards": Cards completamente aleatórios

### BR-114: New Card Sort Order
- Controla ordem final de novos cards após gather
- Opções: "card_type_then_order_gathered", "order_gathered", "card_type_then_random", "random_note_then_card_type", "random"
- Aplicado após gather order

### BR-115: Review Sort Order
- Controla ordem de cards em review
- Opções: "due_then_random", "due_then_deck", "deck_then_due", "ascending_intervals", "descending_intervals", "ascending_ease", "descending_ease", "relative_overdueness", "ascending_retrievability" (FSRS)
- "ascending_retrievability" só disponível com FSRS habilitado

### BR-116: Interday Learning/Review Order
- Controla ordem entre cards em learning interday e reviews
- Opções: "mix", "before", "after"
- "mix": Mistura learning e reviews
- "before": Learning antes de reviews
- "after": Learning depois de reviews

## 42. Regras de Timers e Auto Advance

### BR-117: Internal Timer
- Internal timer limita tempo máximo para responder (default: 60 segundos)
- Se tempo exceder, card é marcado como "Again" automaticamente
- Timer é opcional (pode ser desabilitado)

### BR-118: On-screen Timer
- On-screen timer exibe contador visual durante estudo
- Pode ser configurado para parar ao mostrar resposta
- Útil para monitorar tempo gasto em cada card

### BR-119: Auto Advance
- Auto advance avança automaticamente após tempo configurado
- Requer configuração de "Seconds to show question for" e/ou "Seconds to show answer for"
- Se ambos configurados, avança após mostrar resposta pelo tempo configurado

## 43. Regras de FSRS Avançado

### BR-120: FSRS Simulator
- FSRS Simulator permite simular workload futuro
- Simulação considera parâmetros FSRS atuais e histórico de revisões
- Simulação pode incluir cards adicionais (novos cards por dia)
- Simulação mostra projeção de cards due por dia

### BR-121: Historical Retention
- Historical retention preenche gaps no histórico de revisões
- Usado quando histórico está incompleto (antes de data específica)
- Permite otimização FSRS mais precisa mesmo com histórico incompleto

### BR-122: Ignore Cards Reviewed Before
- Permite ignorar cards revisados antes de data específica na otimização FSRS
- Útil quando histórico antigo não é representativo (ex: mudança de estratégia)
- Data é especificada como timestamp em milissegundos

### BR-123: Optimize All Presets
- Permite otimizar parâmetros FSRS para todos os presets de uma vez
- Otimização é aplicada a cada preset baseado em seu próprio histórico
- Presets sem histórico suficiente não são otimizados

### BR-124: Evaluate FSRS Parameters
- Avalia qualidade dos parâmetros FSRS usando métricas (log loss, RMSE)
- Log loss: Mede quão bem o modelo prediz resultados reais
- RMSE: Root Mean Squared Error dos intervalos
- Valores menores indicam melhor qualidade

## 44. Regras de Self-Hosted Sync Server

### BR-125: Configuração do Servidor
- Self-hosted sync server permite usar servidor próprio ao invés de AnkiWeb
- Servidor pode ser instalado via: Packaged Build, Pip, Cargo, Source, Docker
- Servidor requer configuração de múltiplos usuários (SYNC_USER1, SYNC_USER2, etc.)
- Senhas DEVEM ser hasheadas (PHC Format)

### BR-126: Configuração do Cliente
- Cliente DEVE ser configurado com URL do servidor self-hosted
- URL pode incluir subpath se servidor estiver atrás de reverse proxy
- Cliente valida conexão antes de permitir sincronização
- Sistema suporta HTTPS e HTTP (não recomendado)

### BR-127: Segurança do Servidor
- Servidor DEVE validar autenticação em todas as requisições
- Servidor DEVE implementar rate limiting
- Servidor DEVE validar tamanho de payloads (MAX_SYNC_PAYLOAD_MEGS)
- Servidor PODE ser configurado com reverse proxy para HTTPS

## Resumo

Total de regras de negócio identificadas: **127 regras principais**

Estas regras de negócio definem o comportamento específico do sistema em todas as situações, garantindo consistência e previsibilidade. Elas complementam os requisitos funcionais e não funcionais, fornecendo detalhes sobre como as funcionalidades devem se comportar em casos específicos.

As regras são essenciais para:
- **Desenvolvimento**: Implementação correta das funcionalidades
- **Testes**: Validação do comportamento esperado
- **Documentação**: Referência para usuários e desenvolvedores
- **Manutenção**: Entendimento do comportamento do sistema
