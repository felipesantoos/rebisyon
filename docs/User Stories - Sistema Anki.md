# User Stories - Sistema Anki Completo

Este documento contém as user stories (histórias de usuário) do sistema Anki, organizadas por área funcional e priorizadas.

## Formato das User Stories

As user stories seguem o formato padrão:

**Como** [tipo de usuário]  
**Eu quero** [ação/objetivo]  
**Para que** [benefício/valor]

**Critérios de Aceitação:**
- [Critério 1]
- [Critério 2]
- [Critério 3]

**Prioridade:** Alta | Média | Baixa

---

## 1. Autenticação e Gerenciamento de Usuário

### US-001: Registro de Usuário

**Como** um novo usuário  
**Eu quero** me registrar no sistema fornecendo email e senha  
**Para que** eu possa criar minha conta e começar a usar o sistema

**Critérios de Aceitação:**
- Sistema valida que o email é único e válido
- Sistema valida que a senha atende critérios de segurança (mínimo 8 caracteres)
- Sistema envia email de verificação após registro
- Sistema cria deck "Default" automaticamente para o novo usuário
- Sistema exibe mensagem de sucesso após registro

**Prioridade:** Alta

---

### US-002: Login

**Como** um usuário registrado  
**Eu quero** fazer login com email e senha  
**Para que** eu possa acessar minha coleção de cards

**Critérios de Aceitação:**
- Sistema valida credenciais e retorna token JWT
- Sistema retorna refresh token para renovação
- Sistema exibe mensagem de erro se credenciais forem inválidas
- Sistema redireciona para tela principal após login bem-sucedido

**Prioridade:** Alta

---

### US-003: Recuperação de Senha

**Como** um usuário que esqueceu a senha  
**Eu quero** solicitar recuperação de senha por email  
**Para que** eu possa redefinir minha senha e recuperar acesso à conta

**Critérios de Aceitação:**
- Sistema envia email com link de recuperação
- Link expira após período determinado (ex: 1 hora)
- Sistema permite redefinir senha usando token válido
- Sistema valida nova senha antes de aceitar

**Prioridade:** Alta

---

### US-004: Alterar Senha

**Como** um usuário autenticado  
**Eu quero** alterar minha senha atual  
**Para que** eu possa manter minha conta segura

**Critérios de Aceitação:**
- Sistema solicita senha atual para validação
- Sistema valida que nova senha atende critérios de segurança
- Sistema confirma alteração com mensagem de sucesso
- Sistema invalida sessões em outros dispositivos (opcional)

**Prioridade:** Média

---

### US-005: Verificação de Email

**Como** um novo usuário  
**Eu quero** verificar meu email através do link enviado  
**Para que** eu possa ativar minha conta e usar todas as funcionalidades

**Critérios de Aceitação:**
- Sistema envia email com link de verificação
- Link contém token único e seguro
- Sistema ativa conta após verificação bem-sucedida
- Sistema exibe mensagem de confirmação

**Prioridade:** Alta

---

## 2. Gerenciamento de Decks

### US-006: Criar Deck

**Como** um usuário  
**Eu quero** criar um novo deck com nome personalizado  
**Para que** eu possa organizar meus cards por assunto ou matéria

**Critérios de Aceitação:**
- Sistema permite criar deck com nome único por usuário
- Sistema cria deck com opções padrão
- Sistema exibe deck na lista hierárquica
- Sistema permite criar subdecks (hierarquia)

**Prioridade:** Alta

---

### US-007: Visualizar Lista de Decks

**Como** um usuário  
**Eu quero** visualizar todos os meus decks em uma lista hierárquica  
**Para que** eu possa ver rapidamente quantos cards preciso estudar em cada deck

**Critérios de Aceitação:**
- Sistema exibe lista hierárquica de todos os decks
- Sistema mostra contadores de cards (New, Learning, Review) por deck
- Sistema exibe estatísticas resumidas de cada deck
- Sistema permite expandir/colapsar subdecks

**Prioridade:** Alta

---

### US-008: Configurar Opções do Deck

**Como** um usuário  
**Eu quero** configurar opções do deck (limites, algoritmos, etc.)  
**Para que** eu possa personalizar como os cards são estudados

**Critérios de Aceitação:**
- Sistema permite configurar limite de novos cards por dia
- Sistema permite configurar limite máximo de reviews por dia
- Sistema permite escolher algoritmo (SM-2 ou FSRS)
- Sistema permite configurar learning steps
- Sistema salva configurações e aplica imediatamente

**Prioridade:** Alta

---

### US-009: Reorganizar Decks

**Como** um usuário  
**Eu quero** reorganizar meus decks por drag-and-drop  
**Para que** eu possa organizá-los da forma que preferir

**Critérios de Aceitação:**
- Sistema permite arrastar e soltar decks
- Sistema permite criar hierarquia (subdecks)
- Sistema salva nova ordem automaticamente
- Sistema atualiza visualização imediatamente

**Prioridade:** Média

---

### US-010: Excluir Deck

**Como** um usuário  
**Eu quero** excluir um deck que não uso mais  
**Para que** eu possa limpar minha coleção

**Critérios de Aceitação:**
- Sistema solicita confirmação antes de excluir
- Sistema oferece opção de mover cards para outro deck
- Sistema cria backup automático antes de excluir
- Sistema exibe aviso se deck contém muitos cards

**Prioridade:** Média

---

### US-011: Usar Presets de Opções

**Como** um usuário  
**Eu quero** criar e aplicar presets de opções de deck  
**Para que** eu possa aplicar as mesmas configurações a múltiplos decks rapidamente

**Critérios de Aceitação:**
- Sistema permite criar presets personalizados
- Sistema permite aplicar preset a múltiplos decks
- Sistema atualiza todos os decks quando preset é editado
- Sistema permite clonar e renomear presets

**Prioridade:** Média

---

## 3. Gerenciamento de Notes e Cards

### US-012: Criar Note

**Como** um usuário  
**Eu quero** criar uma nova note preenchendo campos  
**Para que** eu possa adicionar novo conteúdo ao meu deck

**Critérios de Aceitação:**
- Sistema permite selecionar note type
- Sistema exibe campos do note type selecionado
- Sistema valida campos obrigatórios antes de salvar
- Sistema gera cards automaticamente baseado no note type
- Sistema exibe preview dos cards antes de salvar

**Prioridade:** Alta

---

### US-013: Editar Note

**Como** um usuário  
**Eu quero** editar uma note existente  
**Para que** eu possa corrigir erros ou atualizar informações

**Critérios de Aceitação:**
- Sistema permite editar todos os campos da note
- Sistema atualiza todos os cards relacionados automaticamente
- Sistema salva alterações e exibe confirmação
- Sistema mantém histórico de alterações (opcional)

**Prioridade:** Alta

---

### US-014: Adicionar Tags

**Como** um usuário  
**Eu quero** adicionar tags às minhas notes  
**Para que** eu possa organizá-las e encontrá-las facilmente

**Critérios de Aceitação:**
- Sistema permite adicionar múltiplas tags
- Sistema sugere tags existentes ao digitar
- Sistema permite criar novas tags
- Sistema exibe tags visualmente na note

**Prioridade:** Alta

---

### US-015: Buscar Notes

**Como** um usuário  
**Eu quero** buscar notes usando texto ou sintaxe avançada  
**Para que** eu possa encontrar rapidamente o conteúdo que procuro

**Critérios de Aceitação:**
- Sistema permite busca simples por texto
- Sistema suporta sintaxe avançada (tags, fields, decks, etc.)
- Sistema permite busca com regular expressions
- Sistema permite ignorar acentos na busca
- Sistema exibe resultados em tempo real

**Prioridade:** Alta

---

### US-016: Visualizar Notes no Browser

**Como** um usuário  
**Eu quero** visualizar notes em modo tabela (browser)  
**Para que** eu possa ver muitas notes de uma vez e gerenciá-las eficientemente

**Critérios de Aceitação:**
- Sistema exibe notes em formato de tabela
- Sistema permite ordenar por colunas (clique no cabeçalho)
- Sistema permite filtrar por múltiplos critérios
- Sistema permite editar note inline (duplo clique)
- Sistema permite selecionar múltiplas notes

**Prioridade:** Alta

---

### US-016A: Configurar Browser

**Como** um usuário  
**Eu quero** configurar colunas e layout do browser  
**Para que** eu possa personalizar a visualização conforme minhas necessidades

**Critérios de Aceitação:**
- Sistema permite escolher quais colunas exibir
- Sistema permite redimensionar colunas
- Sistema permite ordenar por múltiplas colunas
- Sistema salva configuração de colunas
- Sistema permite restaurar configuração padrão

**Prioridade:** Média

---

### US-016B: Exportar Notes do Browser

**Como** um usuário  
**Eu quero** exportar notes selecionadas diretamente do browser  
**Para que** eu possa compartilhar ou fazer backup de subconjuntos específicos

**Critérios de Aceitação:**
- Sistema permite exportar notes selecionadas
- Sistema permite exportar resultados da busca atual
- Sistema suporta formatos .apkg e texto
- Sistema inclui media relacionada
- Sistema exibe preview do que será exportado

**Prioridade:** Média

---

### US-016C: Mover Cards no Browser

**Como** um usuário  
**Eu quero** mover cards selecionados para outro deck diretamente do browser  
**Para que** eu possa reorganizar meus cards eficientemente

**Critérios de Aceitação:**
- Sistema permite selecionar múltiplos cards
- Sistema permite escolher deck de destino
- Sistema move cards mantendo histórico
- Sistema atualiza contadores dos decks
- Sistema exibe confirmação antes de mover

**Prioridade:** Média

---

### US-017: Operações em Lote

**Como** um usuário  
**Eu quero** aplicar operações em lote a múltiplas notes/cards  
**Para que** eu possa gerenciar eficientemente grandes quantidades de conteúdo

**Critérios de Aceitação:**
- Sistema permite selecionar múltiplas notes/cards
- Sistema permite adicionar/remover tags em lote
- Sistema permite mover para outro deck em lote
- Sistema permite suspender/enterrar em lote
- Sistema exibe confirmação antes de operações destrutivas

**Prioridade:** Alta

---

### US-018: Encontrar Duplicatas

**Como** um usuário  
**Eu quero** encontrar notes duplicadas na minha coleção  
**Para que** eu possa remover duplicatas e manter minha coleção organizada

**Critérios de Aceitação:**
- Sistema identifica notes com primeiro campo igual
- Sistema agrupa duplicatas para fácil visualização
- Sistema permite excluir ou mesclar duplicatas
- Sistema permite atualizar duplicatas existentes

**Prioridade:** Média

---

### US-019: Buscar e Substituir

**Como** um usuário  
**Eu quero** buscar e substituir texto em múltiplas notes  
**Para que** eu possa corrigir erros ou atualizar informações em massa

**Critérios de Aceitação:**
- Sistema permite buscar texto em campo específico ou todos
- Sistema permite substituir com texto novo
- Sistema suporta busca com regex
- Sistema permite preview antes de substituir
- Sistema exibe quantas notes foram afetadas

**Prioridade:** Média

---

### US-020: Recuperar Exclusões

**Como** um usuário  
**Eu quero** recuperar notes excluídas recentemente  
**Para que** eu possa restaurar conteúdo excluído acidentalmente

**Critérios de Aceitação:**
- Sistema mantém log de exclusões recentes
- Sistema permite visualizar exclusões dos últimos 7 dias (configurável)
- Sistema permite restaurar note excluída
- Sistema restaura todos os cards relacionados

**Prioridade:** Média

---

## 4. Sistema de Estudo

### US-021: Iniciar Sessão de Estudo

**Como** um usuário  
**Eu quero** iniciar uma sessão de estudo de um deck  
**Para que** eu possa revisar meus cards

**Critérios de Aceitação:**
- Sistema exibe overview do deck (quantos cards para estudar)
- Sistema permite iniciar sessão com limites personalizados
- Sistema carrega cards baseado em ordem configurada
- Sistema respeita limites diários de novos cards e reviews

**Prioridade:** Alta

---

### US-022: Estudar Card

**Como** um usuário  
**Eu quero** ver a frente do card, mostrar resposta e avaliar meu desempenho  
**Para que** eu possa revisar e fortalecer minha memória

**Critérios de Aceitação:**
- Sistema exibe frente do card primeiro
- Sistema permite mostrar resposta ao clicar
- Sistema exibe 4 botões de avaliação (Again, Hard, Good, Easy)
- Sistema calcula próximo intervalo usando algoritmo configurado
- Sistema atualiza estado do card automaticamente
- Sistema avança para próximo card após avaliação

**Prioridade:** Alta

---

### US-023: Ver Informações do Card

**Como** um usuário  
**Eu quero** ver informações detalhadas de um card durante estudo  
**Para que** eu possa entender melhor o histórico e performance do card

**Critérios de Aceitação:**
- Sistema exibe Card Info Dialog com informações completas
- Sistema mostra histórico de revisões
- Sistema mostra intervalos e ease factor históricos
- Sistema mostra tempo gasto em cada revisão
- Sistema mostra primeira e última revisão

**Prioridade:** Média

---

### US-024: Editar Card Durante Estudo

**Como** um usuário  
**Eu quero** editar uma note durante o estudo  
**Para que** eu possa corrigir erros imediatamente quando os noto

**Critérios de Aceitação:**
- Sistema permite abrir editor de note durante estudo
- Sistema salva alterações e atualiza card atual
- Sistema retorna para sessão de estudo após edição
- Sistema mantém progresso da sessão

**Prioridade:** Média

---

### US-025: Usar Flags Durante Estudo

**Como** um usuário  
**Eu quero** adicionar flags coloridas aos cards durante estudo  
**Para que** eu possa marcá-los para revisão posterior ou organização

**Critérios de Aceitação:**
- Sistema permite adicionar/remover flags (0-7) durante estudo
- Sistema exibe flag visualmente no card
- Sistema permite usar atalhos de teclado para flags
- Sistema permite renomear flags para personalização

**Prioridade:** Média

---

### US-026: Enterrar Card

**Como** um usuário  
**Eu quero** enterrar um card durante estudo  
**Para que** eu possa escondê-lo temporariamente sem suspendê-lo

**Critérios de Aceitação:**
- Sistema permite enterrar card manualmente
- Sistema enterra siblings automaticamente (se configurado)
- Sistema desenterra cards automaticamente no próximo dia
- Sistema exibe contador de cards enterrados no overview

**Prioridade:** Média

---

### US-027: Suspender Card

**Como** um usuário  
**Eu quero** suspender um card durante estudo  
**Para que** eu possa pausar temporariamente cards que não quero revisar

**Critérios de Aceitação:**
- Sistema permite suspender card manualmente
- Sistema remove card da fila de estudo
- Sistema permite dessuspender card posteriormente
- Sistema exibe contador de cards suspensos

**Prioridade:** Média

---

### US-028: Resetar Card

**Como** um usuário  
**Eu quero** resetar um card para estado inicial  
**Para que** eu possa começar a estudá-lo novamente do zero

**Critérios de Aceitação:**
- Sistema permite resetar para "new" (preserva histórico)
- Sistema permite "Forget" (esquece completamente)
- Sistema permite restaurar posição original
- Sistema reseta contadores de lapses e reps

**Prioridade:** Baixa

---

### US-029: Definir Data de Vencimento

**Como** um usuário  
**Eu quero** definir data de vencimento específica para um card  
**Para que** eu possa agendar quando revisá-lo

**Critérios de Aceitação:**
- Sistema permite definir data específica
- Sistema permite definir range de datas (ex: 60-90 dias)
- Sistema converte new cards em review cards ao set due
- Sistema permite reschedule mantendo ou alterando intervalo

**Prioridade:** Baixa

---

### US-029A: Reposicionar Cards

**Como** um usuário  
**Eu quero** reposicionar novos cards na fila de estudo  
**Para que** eu possa controlar a ordem em que aparecerão

**Critérios de Aceitação:**
- Sistema permite reposicionar card para posição específica
- Sistema insere card entre existentes (shift position)
- Sistema permite reposicionar múltiplos cards de uma vez
- Sistema atualiza posições automaticamente
- Sistema mantém ordem relativa de outros cards

**Prioridade:** Baixa

---

### US-030: Usar Undo/Redo

**Como** um usuário  
**Eu quero** desfazer ou refazer operações durante estudo  
**Para que** eu possa corrigir erros acidentais rapidamente

**Critérios de Aceitação:**
- Sistema mantém histórico de operações recentes
- Sistema permite desfazer última operação (Undo)
- Sistema permite refazer operação desfeita (Redo)
- Sistema suporta múltiplos níveis de undo/redo

**Prioridade:** Média

---

### US-031: Criar Cópia Durante Estudo

**Como** um usuário  
**Eu quero** criar uma cópia da note atual durante estudo  
**Para que** eu possa criar variações sem perder a original

**Critérios de Aceitação:**
- Sistema permite criar cópia com um clique
- Sistema copia todos os campos e tags
- Sistema permite escolher deck de destino
- Sistema retorna para sessão de estudo após cópia

**Prioridade:** Baixa

---

### US-032: Ver Card Anterior

**Como** um usuário  
**Eu quero** ver informações do card anterior durante estudo  
**Para que** eu possa revisar o que acabei de estudar

**Critérios de Aceitação:**
- Sistema exibe Previous Card Info
- Sistema mostra frente e verso do card anterior
- Sistema mostra última avaliação e intervalo
- Sistema permite voltar ao card anterior (opcional)

**Prioridade:** Baixa

---

### US-033: Usar Auto-Advance

**Como** um usuário  
**Eu quero** ativar auto-advance durante estudo  
**Para que** os cards avancem automaticamente após tempo configurado

**Critérios de Aceitação:**
- Sistema permite configurar tempo para questão
- Sistema permite configurar tempo para resposta
- Sistema avança automaticamente após tempo
- Sistema permite desativar a qualquer momento

**Prioridade:** Baixa

---

### US-034: Usar Timeboxing

**Como** um usuário  
**Eu quero** usar timeboxing para limitar tempo de estudo  
**Para que** eu possa manter sessões focadas e produtivas

**Critérios de Aceitação:**
- Sistema permite configurar limite de tempo (ex: 25 minutos)
- Sistema exibe notificações periódicas durante timebox
- Sistema mostra estatísticas ao final do timebox
- Sistema permite pausar ou estender timebox

**Prioridade:** Baixa

---

## 5. Tipos de Nota (Note Types)

### US-035: Criar Note Type

**Como** um usuário  
**Eu quero** criar um novo note type personalizado  
**Para que** eu possa estruturar meus cards da forma que preferir

**Critérios de Aceitação:**
- Sistema permite criar note type com nome único
- Sistema permite adicionar campos personalizados
- Sistema permite configurar propriedades de cada campo
- Sistema permite criar múltiplos card types
- Sistema permite editar templates HTML/CSS

**Prioridade:** Alta

---

### US-036: Editar Templates

**Como** um usuário  
**Eu quero** editar templates HTML/CSS dos cards  
**Para que** eu possa personalizar a aparência dos meus cards

**Critérios de Aceitação:**
- Sistema permite editar front template
- Sistema permite editar back template
- Sistema permite editar styling (CSS)
- Sistema exibe preview em tempo real
- Sistema valida sintaxe antes de salvar

**Prioridade:** Alta

---

### US-037: Clonar Note Type

**Como** um usuário  
**Eu quero** clonar um note type existente  
**Para que** eu possa criar variações sem começar do zero

**Critérios de Aceitação:**
- Sistema permite clonar note type com um clique
- Sistema copia todos os campos e templates
- Sistema permite renomear após clonar
- Sistema não afeta o note type original

**Prioridade:** Média

---

### US-038: Preview de Card

**Como** um usuário  
**Eu quero** ver preview de um card enquanto edito templates  
**Para que** eu possa ver como ficará antes de salvar

**Critérios de Aceitação:**
- Sistema exibe preview em tempo real
- Sistema permite usar dados de exemplo
- Sistema renderiza templates corretamente
- Sistema mostra front e back do card

**Prioridade:** Média

---

## 6. Media (Imagens, Áudio, Vídeo)

### US-039: Upload de Media

**Como** um usuário  
**Eu quero** fazer upload de imagens, áudio e vídeo  
**Para que** eu possa enriquecer meus cards com conteúdo multimídia

**Critérios de Aceitação:**
- Sistema permite upload de múltiplos formatos (JPG, PNG, MP3, MP4, etc.)
- Sistema valida formato e tamanho do arquivo
- Sistema permite colar imagem da clipboard
- Sistema suporta drag-and-drop
- Sistema gera hash para detecção de duplicatas

**Prioridade:** Alta

---

### US-040: Associar Media aos Cards

**Como** um usuário  
**Eu quero** associar media aos campos das notes  
**Para que** os arquivos apareçam nos cards durante estudo

**Critérios de Aceitação:**
- Sistema permite associar media a campos específicos
- Sistema detecta referências a media nos templates automaticamente
- Sistema exibe media nos cards durante estudo
- Sistema permite remover associação

**Prioridade:** Alta

---

### US-041: Limpar Media Não Utilizada

**Como** um usuário  
**Eu quero** verificar e remover media não utilizada  
**Para que** eu possa economizar espaço de armazenamento

**Critérios de Aceitação:**
- Sistema identifica media não referenciada em nenhuma note
- Sistema lista media não utilizada com tamanho
- Sistema permite excluir media selecionada
- Sistema exibe confirmação antes de excluir

**Prioridade:** Baixa

---

## 7. Busca Avançada

### US-042: Buscar com Sintaxe Avançada

**Como** um usuário  
**Eu quero** usar sintaxe avançada para buscar notes  
**Para que** eu possa fazer buscas complexas e precisas

**Critérios de Aceitação:**
- Sistema suporta busca por deck (deck:name)
- Sistema suporta busca por tag (tag:name)
- Sistema suporta busca por campo (front:text, back:text)
- Sistema suporta busca por flag (flag:1)
- Sistema suporta busca por estado (is:new, is:due)
- Sistema suporta operadores lógicos (AND, OR, NOT)

**Prioridade:** Alta

---

### US-043: Salvar Buscas

**Como** um usuário  
**Eu quero** salvar buscas frequentes  
**Para que** eu possa reutilizá-las rapidamente sem redigitar

**Critérios de Aceitação:**
- Sistema permite salvar busca com nome personalizado
- Sistema lista buscas salvas
- Sistema permite executar busca salva com um clique
- Sistema permite editar ou excluir buscas salvas

**Prioridade:** Média

---

## 8. Estatísticas

### US-044: Ver Estatísticas do Deck

**Como** um usuário  
**Eu quero** ver estatísticas detalhadas de um deck  
**Para que** eu possa acompanhar meu progresso e performance

**Critérios de Aceitação:**
- Sistema exibe gráficos de reviews por dia
- Sistema exibe gráficos de retention
- Sistema exibe distribuição de intervalos
- Sistema exibe estatísticas de tempo gasto
- Sistema permite filtrar por período (dias, semanas, meses)

**Prioridade:** Alta

---

### US-045: Ver Estatísticas da Coleção

**Como** um usuário  
**Eu quero** ver estatísticas gerais da minha coleção completa  
**Para que** eu possa ter uma visão geral do meu progresso

**Critérios de Aceitação:**
- Sistema exibe total de decks, notes e cards
- Sistema exibe total de reviews
- Sistema exibe retention geral
- Sistema exibe gráficos agregados de todos os decks

**Prioridade:** Média

---

### US-046: Ver Estatísticas do Card

**Como** um usuário  
**Eu quero** ver estatísticas detalhadas de um card específico  
**Para que** eu possa entender o histórico e performance individual

**Critérios de Aceitação:**
- Sistema exibe total de revisões
- Sistema exibe primeira e última revisão
- Sistema exibe histórico de intervalos e ease
- Sistema exibe tempo médio por revisão
- Sistema exibe gráfico de performance ao longo do tempo

**Prioridade:** Baixa

---

## 9. Sincronização

### US-047: Sincronizar Coleção

**Como** um usuário  
**Eu quero** sincronizar minha coleção com o servidor  
**Para que** eu possa acessá-la de múltiplos dispositivos

**Critérios de Aceitação:**
- Sistema detecta mudanças locais e remotas
- Sistema mescla mudanças automaticamente quando possível
- Sistema sincroniza media junto com dados
- Sistema resolve conflitos quando necessário
- Sistema exibe status de sincronização

**Prioridade:** Alta

---

### US-048: Sincronização Automática

**Como** um usuário  
**Eu quero** que minha coleção sincronize automaticamente  
**Para que** eu não precise fazer isso manualmente

**Critérios de Aceitação:**
- Sistema sincroniza automaticamente ao abrir/fechar (se configurado)
- Sistema sincroniza periodicamente em background
- Sistema sincroniza media em background
- Sistema exibe notificação se sincronização falhar

**Prioridade:** Média

---

### US-049: Resolver Conflitos de Sincronização

**Como** um usuário  
**Eu quero** resolver conflitos quando há mudanças conflitantes  
**Para que** eu possa escolher qual versão manter

**Critérios de Aceitação:**
- Sistema detecta conflitos não mescláveis
- Sistema exibe opções (manter local, manter remoto, mesclar manualmente)
- Sistema permite escolher por objeto (note, card, deck)
- Sistema exibe preview das diferenças

**Prioridade:** Média

---

## 10. Importação e Exportação

### US-050: Importar Deck

**Como** um usuário  
**Eu quero** importar um deck de arquivo (.apkg)  
**Para que** eu possa usar decks criados por outros ou de outras fontes

**Critérios de Aceitação:**
- Sistema permite importar arquivo .apkg
- Sistema importa notes, cards, media e note types
- Sistema detecta e atualiza duplicatas (se configurado)
- Sistema exibe resumo do que foi importado
- Sistema permite escolher deck de destino

**Prioridade:** Alta

---

### US-051: Importar de Texto

**Como** um usuário  
**Eu quero** importar notes de arquivo de texto (CSV, TSV)  
**Para que** eu possa criar muitos cards rapidamente

**Critérios de Aceitação:**
- Sistema suporta formatos CSV e TSV
- Sistema permite mapear colunas para campos
- Sistema detecta headers automaticamente
- Sistema permite configurar separador
- Sistema atualiza duplicatas se configurado

**Prioridade:** Média

---

### US-052: Exportar Deck

**Como** um usuário  
**Eu quero** exportar um deck como arquivo (.apkg)  
**Para que** eu possa compartilhá-lo ou fazer backup

**Critérios de Aceitação:**
- Sistema permite exportar deck completo
- Sistema inclui notes, cards, media e note types
- Sistema permite incluir/excluir scheduling information
- Sistema gera arquivo .apkg compatível com Anki

**Prioridade:** Alta

---

### US-053: Exportar Coleção

**Como** um usuário  
**Eu quero** exportar minha coleção completa (.colpkg)  
**Para que** eu possa fazer backup completo

**Critérios de Aceitação:**
- Sistema exporta todos os decks, notes, cards e media
- Sistema inclui todas as configurações
- Sistema gera arquivo .colpkg
- Sistema permite incluir/excluir scheduling

**Prioridade:** Média

---

## 11. Preferências Globais

### US-054: Configurar Preferências

**Como** um usuário  
**Eu quero** configurar preferências globais do sistema  
**Para que** eu possa personalizar a experiência de uso

**Critérios de Aceitação:**
- Sistema permite configurar idioma da interface
- Sistema permite configurar tema (light/dark/auto)
- Sistema permite configurar tamanho da UI
- Sistema permite configurar comportamento de paste
- Sistema salva preferências e aplica imediatamente

**Prioridade:** Média

---

### US-055: Configurar Sincronização

**Como** um usuário  
**Eu quero** configurar opções de sincronização  
**Para que** eu possa controlar como e quando sincronizar

**Critérios de Aceitação:**
- Sistema permite ativar/desativar auto sync
- Sistema permite configurar sync on open/close
- Sistema permite configurar sync periódico de media
- Sistema permite configurar servidor de sync customizado

**Prioridade:** Média

---

## 12. Backups

### US-056: Criar Backup Manual

**Como** um usuário  
**Eu quero** criar um backup manual da minha coleção  
**Para que** eu possa ter uma cópia de segurança quando necessário

**Critérios de Aceitação:**
- Sistema permite criar backup a qualquer momento
- Sistema inclui todos os dados e media
- Sistema gera arquivo .colpkg
- Sistema exibe tamanho e data do backup

**Prioridade:** Alta

---

### US-057: Restaurar Backup

**Como** um usuário  
**Eu quero** restaurar um backup anterior  
**Para que** eu possa recuperar minha coleção se algo der errado

**Critérios de Aceitação:**
- Sistema lista todos os backups disponíveis
- Sistema permite restaurar backup específico
- Sistema cria backup antes de restaurar (se configurado)
- Sistema desabilita auto sync após restaurar
- Sistema exibe confirmação antes de restaurar

**Prioridade:** Alta

---

### US-058: Backups Automáticos

**Como** um usuário  
**Eu quero** que o sistema crie backups automaticamente  
**Para que** eu tenha proteção sem precisar lembrar

**Critérios de Aceitação:**
- Sistema cria backup automático periodicamente (configurável)
- Sistema mantém backups diários, semanais e mensais
- Sistema limpa backups antigos automaticamente
- Sistema cria backup antes de operações destrutivas

**Prioridade:** Média

---

## 13. Filtered Decks

### US-059: Criar Filtered Deck

**Como** um usuário  
**Eu quero** criar um filtered deck com critérios personalizados  
**Para que** eu possa estudar cards específicos de forma focada

**Critérios de Aceitação:**
- Sistema permite definir filtro de busca
- Sistema permite definir segundo filtro (opcional)
- Sistema permite configurar limite de cards
- Sistema permite escolher ordem (due, random, intervals, etc.)
- Sistema permite configurar se reschedule cards

**Prioridade:** Média

---

### US-060: Reconstruir Filtered Deck

**Como** um usuário  
**Eu quero** reconstruir um filtered deck  
**Para que** os cards sejam atualizados conforme os filtros

**Critérios de Aceitação:**
- Sistema aplica filtros novamente
- Sistema adiciona cards que passaram a atender critérios
- Sistema remove cards que não atendem mais
- Sistema retorna cards aos home decks quando removidos
- Sistema exibe quantos cards foram adicionados/removidos

**Prioridade:** Média

---

## 14. Flags e Leeches

### US-061: Usar Flags

**Como** um usuário  
**Eu quero** usar flags coloridas para organizar cards  
**Para que** eu possa categorizá-los visualmente

**Critérios de Aceitação:**
- Sistema suporta 7 flags coloridas (0-7)
- Sistema permite renomear flags para personalização
- Sistema exibe flags visualmente nos cards
- Sistema permite buscar cards por flag

**Prioridade:** Média

---

### US-062: Gerenciar Leeches

**Como** um usuário  
**Eu quero** ver e gerenciar cards identificados como leeches  
**Para que** eu possa focar em cards problemáticos

**Critérios de Aceitação:**
- Sistema detecta automaticamente cards com muitas falhas
- Sistema adiciona tag "leech" automaticamente
- Sistema suspende card automaticamente (se configurado)
- Sistema permite visualizar lista de leeches
- Sistema permite editar, excluir ou suspender leeches manualmente

**Prioridade:** Média

---

## 15. Shared Decks

### US-063: Buscar Decks Compartilhados

**Como** um usuário  
**Eu quero** buscar decks compartilhados na biblioteca  
**Para que** eu possa encontrar conteúdo criado por outros usuários

**Critérios de Aceitação:**
- Sistema permite buscar por categoria
- Sistema permite buscar por palavras-chave
- Sistema exibe resultados com informações (downloads, rating)
- Sistema permite filtrar por featured
- Sistema permite ordenar por popularidade, recente, rating

**Prioridade:** Média

---

### US-064: Baixar Deck Compartilhado

**Como** um usuário  
**Eu quero** baixar e importar um deck compartilhado  
**Para que** eu possa usar conteúdo criado por outros

**Critérios de Aceitação:**
- Sistema permite visualizar preview do deck
- Sistema exibe informações (número de cards, note types)
- Sistema permite baixar e importar com um clique
- Sistema importa automaticamente após download
- Sistema permite escolher deck de destino

**Prioridade:** Média

---

### US-065: Compartilhar Meu Deck

**Como** um usuário  
**Eu quero** compartilhar meu deck na biblioteca pública  
**Para que** outros usuários possam se beneficiar do meu conteúdo

**Critérios de Aceitação:**
- Sistema permite fazer upload do deck
- Sistema permite adicionar descrição e categoria
- Sistema permite adicionar tags
- Sistema permite tornar público ou privado
- Sistema exibe estatísticas (downloads, ratings)

**Prioridade:** Baixa

---

### US-066: Avaliar Deck Compartilhado

**Como** um usuário  
**Eu quero** avaliar um deck compartilhado  
**Para que** eu possa ajudar outros usuários a encontrar bons decks

**Critérios de Aceitação:**
- Sistema permite dar rating (1-5 estrelas)
- Sistema permite adicionar comentário
- Sistema permite editar avaliação posteriormente
- Sistema calcula rating médio automaticamente

**Prioridade:** Baixa

---

## 16. Add-ons

### US-067: Instalar Add-on

**Como** um usuário  
**Eu quero** instalar add-ons para estender funcionalidades  
**Para que** eu possa personalizar o sistema conforme minhas necessidades

**Critérios de Aceitação:**
- Sistema permite buscar add-ons disponíveis
- Sistema permite instalar pelo código
- Sistema valida compatibilidade com versão atual
- Sistema permite habilitar/desabilitar add-ons
- Sistema permite configurar opções do add-on

**Prioridade:** Baixa

---

### US-068: Gerenciar Add-ons

**Como** um usuário  
**Eu quero** gerenciar meus add-ons instalados  
**Para que** eu possa mantê-los atualizados e organizados

**Critérios de Aceitação:**
- Sistema lista todos os add-ons instalados
- Sistema permite atualizar add-ons
- Sistema permite desinstalar add-ons
- Sistema avisa sobre add-ons incompatíveis após atualização

**Prioridade:** Baixa

---

## 17. Manutenção

### US-069: Verificar Integridade do Banco

**Como** um usuário  
**Eu quero** verificar a integridade do meu banco de dados  
**Para que** eu possa detectar e corrigir problemas

**Critérios de Aceitação:**
- Sistema executa verificação completa
- Sistema reconstrói estruturas internas se necessário
- Sistema otimiza banco durante verificação
- Sistema reporta problemas encontrados
- Sistema sugere restaurar backup se corrupção for detectada

**Prioridade:** Média

---

### US-070: Limpar Empty Cards

**Como** um usuário  
**Eu quero** encontrar e limpar cards vazios  
**Para que** eu possa manter minha coleção limpa

**Critérios de Aceitação:**
- Sistema identifica cards com front vazio
- Sistema lista empty cards antes de limpar
- Sistema permite selecionar quais excluir
- Sistema exibe confirmação antes de excluir

**Prioridade:** Baixa

---

### US-071: Otimizar Banco de Dados

**Como** um usuário  
**Eu quero** otimizar meu banco de dados  
**Para que** o sistema funcione mais rápido

**Critérios de Aceitação:**
- Sistema otimiza índices
- Sistema compacta banco de dados
- Sistema exibe tempo de execução
- Sistema exibe espaço liberado

**Prioridade:** Baixa

---

## 18. Funcionalidades Avançadas

### US-072: Usar FSRS

**Como** um usuário avançado  
**Eu quero** usar o algoritmo FSRS ao invés de SM-2  
**Para que** eu possa ter melhor otimização de intervalos

**Critérios de Aceitação:**
- Sistema permite habilitar FSRS por deck
- Sistema permite otimizar parâmetros FSRS baseado em histórico
- Sistema exibe qualidade dos parâmetros (log loss, RMSE)
- Sistema permite configurar desired retention
- Sistema permite reschedule cards ao mudar parâmetros

**Prioridade:** Média

---

### US-073: Usar Custom Scheduling

**Como** um usuário avançado  
**Eu quero** usar JavaScript customizado para scheduling  
**Para que** eu possa ter controle total sobre os intervalos

**Critérios de Aceitação:**
- Sistema permite inserir código JavaScript
- Sistema valida código antes de salvar
- Sistema executa código em sandbox seguro
- Sistema exibe avisos de segurança
- Sistema permite desabilitar se necessário

**Prioridade:** Baixa

---

### US-074: Usar Text-to-Speech (TTS)

**Como** um usuário  
**Eu quero** que o sistema leia os campos dos cards automaticamente  
**Para que** eu possa estudar enquanto faço outras atividades

**Critérios de Aceitação:**
- Sistema detecta vozes disponíveis no sistema operacional
- Sistema suporta sintaxe {{tts lang:Field}}
- Sistema permite escolher voz preferida
- Sistema permite ajustar velocidade de fala
- Sistema funciona em Windows, macOS, iOS

**Prioridade:** Baixa

---

### US-075: Usar Ruby Characters (Furigana)

**Como** um usuário estudando japonês  
**Eu quero** exibir furigana acima dos kanji  
**Para que** eu possa ler textos japoneses mais facilmente

**Critérios de Aceitação:**
- Sistema renderiza furigana acima do texto
- Sistema suporta sintaxe Texto[Ruby]
- Sistema permite exibir apenas kana ou apenas kanji
- Sistema suporta múltiplas anotações ruby no mesmo campo

**Prioridade:** Baixa

---

### US-076: Usar Type in Answer

**Como** um usuário  
**Eu quero** digitar a resposta ao invés de apenas mostrar  
**Para que** eu possa praticar escrita e ortografia

**Critérios de Aceitação:**
- Sistema exibe campo de texto quando template usa {{type:Field}}
- Sistema compara resposta digitada com resposta correta
- Sistema destaca diferenças (correto/incorreto/faltando)
- Sistema ignora diacríticos se configurado ({{type:nc:Field}})
- Sistema usa fonte monoespaçada para alinhamento

**Prioridade:** Média

---

### US-077: Usar LaTeX/MathJax

**Como** um usuário estudando matemática  
**Eu quero** usar LaTeX ou MathJax nos meus cards  
**Para que** eu possa exibir fórmulas matemáticas corretamente

**Critérios de Aceitação:**
- Sistema renderiza LaTeX como imagens
- Sistema renderiza MathJax no navegador
- Sistema suporta sintaxe \[...\] e \(...\)
- Sistema exibe avisos de segurança ao habilitar LaTeX
- Sistema processa LaTeX em background

**Prioridade:** Média

---

## 19. Performance e Usabilidade

### US-078: Navegação Rápida

**Como** um usuário  
**Eu quero** que o sistema responda rapidamente às minhas ações  
**Para que** eu possa estudar de forma fluida sem interrupções

**Critérios de Aceitação:**
- Sistema carrega próximo card em < 100ms
- Sistema salva respostas em < 500ms
- Sistema busca notes em < 300ms
- Sistema não trava durante operações

**Prioridade:** Alta

---

### US-079: Suporte a Coleções Grandes

**Como** um usuário com muitos cards  
**Eu quero** que o sistema funcione bem mesmo com 100.000+ cards  
**Para que** eu possa continuar usando conforme minha coleção cresce

**Critérios de Aceitação:**
- Sistema usa paginação em todas as listagens
- Sistema usa virtual scrolling no browser
- Sistema otimiza queries para grandes volumes
- Sistema cacheia resultados frequentes
- Sistema carrega dados sob demanda

**Prioridade:** Alta

---

### US-080: Acessibilidade

**Como** um usuário com necessidades especiais  
**Eu quero** que o sistema seja acessível  
**Para que** eu possa usá-lo independente de minhas limitações

**Critérios de Aceitação:**
- Sistema suporta navegação por teclado
- Sistema suporta leitores de tela
- Sistema mantém contraste adequado
- Sistema fornece textos alternativos para imagens
- Sistema suporta atalhos de teclado para ações principais

**Prioridade:** Média

---

## 20. Multi-dispositivo

### US-081: Acessar de Múltiplos Dispositivos

**Como** um usuário  
**Eu quero** acessar minha coleção de múltiplos dispositivos  
**Para que** eu possa estudar em qualquer lugar

**Critérios de Aceitação:**
- Sistema sincroniza entre dispositivos automaticamente
- Sistema mantém sessões ativas em múltiplos dispositivos
- Sistema resolve conflitos quando há mudanças simultâneas
- Sistema funciona em desktop, mobile e web

**Prioridade:** Alta

---

## Resumo de Prioridades

### Prioridade Alta (MVP - Minimum Viable Product)
- US-001 a US-005: Autenticação e perfil
- US-006 a US-008: Decks básicos
- US-012 a US-016: Notes e busca básica
- US-021 a US-022: Sistema de estudo básico
- US-035 a US-036: Note types básicos
- US-039 a US-040: Media básico
- US-042: Busca avançada
- US-044: Estatísticas do deck
- US-047: Sincronização
- US-050, US-052: Importação/Exportação básica
- US-056 a US-057: Backups
- US-078 a US-079: Performance
- US-081: Multi-dispositivo

**Total: 29 user stories de alta prioridade**

### Prioridade Média
- US-004, US-009 a US-011: Funcionalidades de decks
- US-016A a US-016C: Configuração e operações do browser
- US-017 a US-020: Operações avançadas de notes
- US-023 a US-027: Funcionalidades durante estudo
- US-030: Undo/Redo
- US-037 a US-038: Note types avançados
- US-043: Buscas salvas
- US-045: Estatísticas da coleção
- US-048 a US-049: Sincronização avançada
- US-051, US-053: Importação/Exportação avançada
- US-054 a US-055: Preferências
- US-058: Backups automáticos
- US-059 a US-060: Filtered decks
- US-061 a US-062: Flags e leeches
- US-069: Manutenção
- US-072, US-076 a US-077: Funcionalidades avançadas
- US-080: Acessibilidade

**Total: 38 user stories de média prioridade**

### Prioridade Baixa (Nice to Have)
- US-028 a US-029, US-029A: Reset, set due e reposicionamento
- US-031 a US-034: Funcionalidades opcionais de estudo
- US-041: Limpeza de media
- US-046: Estatísticas do card
- US-063 a US-066: Shared decks
- US-067 a US-068: Add-ons
- US-070 a US-071: Manutenção avançada
- US-073 a US-075: Funcionalidades especializadas

**Total: 18 user stories de baixa prioridade**

---

**Total Geral: 89 user stories**

Este documento cobre todas as funcionalidades principais do sistema Anki, desde operações básicas até funcionalidades avançadas, organizadas por prioridade para facilitar o planejamento de desenvolvimento.

