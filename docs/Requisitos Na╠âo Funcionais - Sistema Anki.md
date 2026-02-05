# Requisitos Não Funcionais - Sistema Anki Completo

Este documento descreve todos os requisitos não funcionais do sistema Anki, focando em aspectos de qualidade, performance, segurança e usabilidade.

## 1. Performance

### RNF-001: Tempo de Resposta da API
O sistema DEVE responder a requisições da API em:
- **Operações simples (GET)**: < 200ms para 95% das requisições
- **Operações de escrita (POST/PUT)**: < 500ms para 95% das requisições
- **Operações complexas (estatísticas, busca)**: < 2s para 95% das requisições
- **Upload de media**: Suportar uploads de até 100MB em < 30s

### RNF-002: Tempo de Carregamento do Frontend
O sistema DEVE carregar:
- **Página inicial**: < 1s em conexão 4G
- **Tela de estudo**: < 500ms após selecionar deck
- **Próximo card**: < 100ms após resposta
- **Busca**: < 300ms para resultados
- **Browser**: < 1s para carregar 10.000 cards/notes
- **Browser com virtual scrolling**: Renderizar apenas itens visíveis

### RNF-003: Throughput
O sistema DEVE suportar:
- **Requisições simultâneas**: Mínimo de 100 requisições/segundo por usuário
- **Sessões de estudo simultâneas**: Múltiplas sessões por usuário sem degradação
- **Sincronização**: Suportar sincronização de até 10.000 cards em < 30s

### RNF-004: Otimização de Queries
O sistema DEVE:
- Usar índices apropriados em todas as queries frequentes
- Otimizar queries de estudo para coleções com 100.000+ cards
- Implementar paginação em todas as listagens (máximo 100 itens por página)
- Cachear resultados de queries frequentes (estatísticas, overview)

### RNF-005: Processamento Assíncrono
O sistema DEVE:
- Executar operações pesadas em background (otimização, limpeza de media)
- Não bloquear interface durante operações longas
- Mostrar progresso para operações que levam > 1s
- Permitir cancelamento de operações longas
- Executar Check Database em background (não bloquear sistema)
- Processar LaTeX/MathJax de forma assíncrona
- Processar TTS sem bloquear UI

## 2. Escalabilidade

### RNF-006: Escalabilidade Horizontal
O sistema DEVE:
- Suportar múltiplas instâncias do backend (load balancing)
- Ser stateless (exceto sessões WebSocket)
- Permitir adicionar novos servidores sem downtime
- Distribuir carga uniformemente entre instâncias

### RNF-007: Escalabilidade de Dados
O sistema DEVE suportar:
- **Por usuário**: Até 1.000.000 de cards por coleção
- **Por deck**: Até 100.000 cards por deck
- **Media**: Até 10GB de media por usuário
- **Notes**: Até 500.000 notes por coleção
- **Decks**: Até 10.000 decks por usuário (incluindo hierarquia)

### RNF-008: Escalabilidade de Usuários
O sistema DEVE suportar:
- **Usuários simultâneos**: Mínimo de 1.000 usuários simultâneos
- **Usuários totais**: Escalar para 100.000+ usuários
- **Crescimento**: Suportar crescimento de 10% ao mês sem refatoração

### RNF-009: Escalabilidade de Storage
O sistema DEVE:
- Usar storage escalável (S3, object storage)
- Suportar crescimento ilimitado de media
- Implementar compressão de media quando apropriado
- Implementar deduplicação de media (mesmo hash)

## 3. Disponibilidade e Confiabilidade

### RNF-010: Disponibilidade
O sistema DEVE ter:
- **Uptime**: 99.9% de disponibilidade (máximo 43 minutos de downtime por mês)
- **Planejamento de manutenção**: Notificar usuários com 24h de antecedência
- **Recuperação**: Recuperar de falhas em < 5 minutos

### RNF-011: Tolerância a Falhas
O sistema DEVE:
- Continuar funcionando mesmo se alguns componentes falharem
- Implementar circuit breakers para serviços externos
- Ter fallbacks para operações críticas
- Não perder dados mesmo em caso de falha

### RNF-012: Backup e Recuperação
O sistema DEVE:
- Criar backups automáticos a cada 30 minutos (configurável)
- Manter backups por pelo menos 30 dias
- Permitir recuperação point-in-time
- Testar restauração de backups regularmente
- Ter backups em múltiplas localizações geográficas

### RNF-013: Integridade de Dados
O sistema DEVE:
- Garantir consistência transacional (ACID)
- Validar integridade referencial
- Detectar e corrigir corrupção de dados
- Manter logs de auditoria para operações críticas

## 4. Segurança

### RNF-014: Autenticação e Autorização
O sistema DEVE:
- Usar JWT com expiração adequada (15 minutos para access token)
- Implementar refresh tokens com rotação
- Validar tokens em todas as requisições autenticadas
- Implementar logout que invalida tokens
- Suportar múltiplas sessões simultâneas por usuário

### RNF-015: Proteção de Dados
O sistema DEVE:
- Criptografar senhas usando algoritmos seguros (bcrypt, argon2)
- Criptografar dados sensíveis em trânsito (TLS 1.2+)
- Criptografar dados sensíveis em repouso (opcional, mas recomendado)
- Não armazenar senhas em texto plano
- Implementar hashing seguro para media (SHA-256)

### RNF-016: Prevenção de Ataques
O sistema DEVE:
- Implementar rate limiting (100 req/min por IP, 1000 req/min por usuário)
- Proteger contra SQL injection (usar prepared statements)
- Proteger contra XSS (sanitizar inputs, CSP headers)
- Proteger contra CSRF (tokens CSRF)
- Proteger contra clickjacking (X-Frame-Options)
- Validar e sanitizar todos os inputs
- Implementar CORS apropriadamente

### RNF-017: Segurança de API
O sistema DEVE:
- Validar todos os parâmetros de entrada
- Retornar erros genéricos (não expor detalhes internos)
- Implementar timeout em requisições (30s padrão)
- Limitar tamanho de payloads (10MB para JSON, 100MB para media)
- Validar tipos de arquivo em uploads
- Escanear uploads por malware (opcional)

### RNF-018: Privacidade
O sistema DEVE:
- Não compartilhar dados entre usuários
- Permitir exclusão completa de conta e dados
- Cumprir LGPD/GDPR (direito ao esquecimento)
- Logar acessos a dados pessoais
- Anonimizar dados em logs

## 5. Usabilidade

### RNF-019: Interface do Usuário
O sistema DEVE ter:
- **Design intuitivo**: Novos usuários devem conseguir usar sem treinamento
- **Consistência**: Interface consistente em todas as páginas
- **Feedback visual**: Feedback imediato para todas as ações
- **Navegação clara**: Fácil navegação entre seções
- **Responsividade**: Funcionar bem em diferentes tamanhos de tela

### RNF-020: Acessibilidade
O sistema DEVE:
- Suportar navegação completa por teclado
- Ser compatível com leitores de tela (ARIA labels)
- Manter contraste mínimo de 4.5:1 para texto
- Fornecer textos alternativos para imagens
- Suportar zoom até 200% sem quebrar layout
- Seguir WCAG 2.1 Level AA

### RNF-021: Atalhos de Teclado
O sistema DEVE fornecer:
- Atalhos para todas as ações principais
- Atalhos consistentes com padrões da plataforma
- Documentação de atalhos acessível
- Possibilidade de customizar atalhos (futuro)

### RNF-022: Mensagens de Erro
O sistema DEVE:
- Exibir mensagens de erro claras e acionáveis
- Não usar jargão técnico para usuários finais
- Fornecer sugestões para resolver problemas
- Logar detalhes técnicos para desenvolvedores

### RNF-023: Help e Documentação
O sistema DEVE:
- Fornecer tooltips para funcionalidades complexas
- Ter documentação acessível dentro da aplicação
- Fornecer exemplos e tutoriais
- Ter busca na documentação

## 6. Compatibilidade

### RNF-024: Navegadores
O sistema DEVE funcionar em:
- **Chrome**: Últimas 2 versões
- **Firefox**: Últimas 2 versões
- **Safari**: Últimas 2 versões
- **Edge**: Últimas 2 versões
- **Mobile browsers**: Chrome Mobile, Safari iOS

### RNF-025: Sistemas Operacionais
O sistema DEVE:
- Funcionar via web em qualquer sistema operacional
- Adaptar UI para diferentes plataformas quando apropriado
- Suportar diferentes formatos de data/hora
- Suportar diferentes layouts de teclado

### RNF-026: Dispositivos
O sistema DEVE:
- Funcionar em desktop (1920x1080+)
- Funcionar em tablets (768px+)
- Funcionar em smartphones (375px+)
- Adaptar layout responsivamente
- Otimizar para touch em dispositivos móveis

### RNF-027: Compatibilidade com Anki
O sistema DEVE:
- Importar decks do Anki (.apkg) sem perda de dados
- Importar coleções do Anki (.colpkg)
- Manter compatibilidade de formato ao exportar
- Suportar importação de scheduling data do Anki

## 7. Manutenibilidade

### RNF-028: Código
O sistema DEVE ter:
- **Código limpo**: Seguir boas práticas e padrões
- **Documentação**: Código documentado (comentários, docstrings)
- **Testes**: Cobertura mínima de 80% para código crítico
- **Padrões**: Seguir convenções de código (Go, TypeScript)
- **Modularidade**: Código organizado em módulos reutilizáveis

### RNF-029: Arquitetura
O sistema DEVE:
- Separar claramente backend e frontend
- Usar arquitetura em camadas (domain, repository, service, api)
- Manter baixo acoplamento entre componentes
- Permitir substituição de componentes
- Seguir princípios SOLID

### RNF-030: Versionamento
O sistema DEVE:
- Usar versionamento semântico (SemVer)
- Manter changelog detalhado
- Documentar breaking changes
- Fornecer migração de dados entre versões

### RNF-031: Logging
O sistema DEVE:
- Usar logging estruturado (JSON)
- Ter níveis de log apropriados (DEBUG, INFO, WARN, ERROR)
- Logar todas as operações importantes
- Rotacionar logs automaticamente
- Permitir configurar nível de log

## 8. Testabilidade

### RNF-032: Testes Unitários
O sistema DEVE ter:
- Testes unitários para toda lógica de negócio
- Testes para algoritmos de repetição espaçada
- Testes para validações e transformações
- Cobertura mínima de 80% para código crítico

### RNF-033: Testes de Integração
O sistema DEVE ter:
- Testes de integração para APIs
- Testes de integração para banco de dados
- Testes de integração para sincronização
- Testes end-to-end para fluxos principais

### RNF-034: Testes de Performance
O sistema DEVE ter:
- Testes de carga (load testing)
- Testes de stress (stress testing)
- Benchmarks para operações críticas
- Monitoramento de performance em produção

### RNF-035: Testabilidade
O sistema DEVE:
- Permitir mock de dependências externas
- Ter interfaces para facilitar testes
- Suportar testes em ambiente isolado
- Ter dados de teste reproduzíveis

## 9. Portabilidade

### RNF-036: Deploy
O sistema DEVE:
- Ser deployável em diferentes ambientes (dev, staging, prod)
- Usar containers (Docker) para isolamento
- Ter configuração via variáveis de ambiente
- Suportar deploy em cloud providers (AWS, GCP, Azure)

### RNF-037: Dependências
O sistema DEVE:
- Minimizar dependências externas
- Usar versões específicas de dependências
- Manter dependências atualizadas (security patches)
- Documentar todas as dependências

## 10. Eficiência de Recursos

### RNF-038: Uso de Memória
O sistema DEVE:
- Usar memória eficientemente
- Não vazar memória (memory leaks)
- Limitar uso de memória por requisição
- Implementar cache apropriado

### RNF-039: Uso de CPU
O sistema DEVE:
- Otimizar operações computacionalmente intensivas
- Usar processamento assíncrono quando apropriado
- Distribuir carga entre processos/threads
- Monitorar uso de CPU

### RNF-040: Uso de Storage
O sistema DEVE:
- Comprimir dados quando apropriado
- Implementar deduplicação de media
- Limpar dados temporários regularmente
- Otimizar tamanho de banco de dados

### RNF-041: Uso de Rede
O sistema DEVE:
- Minimizar tamanho de payloads
- Implementar compressão (gzip, brotli)
- Usar cache apropriado (browser, CDN)
- Otimizar transferência de media

## 11. Observabilidade

### RNF-042: Logging
O sistema DEVE:
- Logar todas as operações importantes
- Usar formato estruturado (JSON)
- Incluir contexto relevante (user ID, request ID)
- Ter níveis de log apropriados
- Rotacionar logs automaticamente

### RNF-043: Métricas
O sistema DEVE coletar:
- Métricas de performance (latência, throughput)
- Métricas de negócio (cards estudados, usuários ativos)
- Métricas de erro (taxa de erro, tipos de erro)
- Métricas de recursos (CPU, memória, storage)

### RNF-044: Monitoramento
O sistema DEVE:
- Monitorar saúde do sistema (health checks)
- Alertar sobre problemas críticos
- Ter dashboards de monitoramento
- Rastrear requisições end-to-end (tracing)

### RNF-045: Alertas
O sistema DEVE:
- Alertar sobre erros críticos imediatamente
- Alertar sobre degradação de performance
- Alertar sobre problemas de disponibilidade
- Ter diferentes níveis de severidade

## 12. Internacionalização (i18n)

### RNF-046: Suporte a Idiomas
O sistema DEVE:
- Suportar múltiplos idiomas na interface
- Permitir mudança de idioma sem recarregar página
- Suportar RTL (Right-to-Left) para árabe/hebraico
- Manter traduções atualizadas

### RNF-047: Localização
O sistema DEVE:
- Suportar diferentes formatos de data/hora
- Suportar diferentes formatos numéricos
- Suportar diferentes fusos horários
- Adaptar para convenções locais

## 13. Extensibilidade

### RNF-048: API Extensível
O sistema DEVE:
- Fornecer API REST completa e bem documentada
- Suportar webhooks para eventos
- Permitir integrações de terceiros
- Manter compatibilidade de API (versionamento)

### RNF-049: Plugins/Add-ons
O sistema DEVE (futuro):
- Suportar sistema de plugins
- Ter API para desenvolvedores
- Permitir extensão de funcionalidades
- Manter sandbox para segurança
- Isolar add-ons em processos/workers separados
- Limitar recursos disponíveis para add-ons (CPU, memória, tempo de execução)
- Validar código de add-ons antes de executar
- Prevenir add-ons de acessar dados de outros usuários
- Prevenir add-ons de modificar dados críticos sem permissão
- Permitir desabilitar add-ons que causam problemas de performance
- Logar todas as ações de add-ons para auditoria

## 14. Conformidade

### RNF-050: LGPD/GDPR
O sistema DEVE:
- Permitir acesso aos dados pessoais
- Permitir correção de dados
- Permitir exclusão completa de dados
- Notificar sobre uso de dados
- Ter política de privacidade clara

### RNF-051: Acessibilidade Legal
O sistema DEVE:
- Cumprir requisitos de acessibilidade (WCAG 2.1 AA)
- Ser acessível para pessoas com deficiência
- Fornecer alternativas para conteúdo não textual

## 15. Documentação

### RNF-052: Documentação Técnica
O sistema DEVE ter:
- Documentação da arquitetura
- Documentação da API (OpenAPI/Swagger)
- Documentação de instalação e deploy
- Guias de desenvolvimento
- Diagramas de arquitetura e fluxos

### RNF-053: Documentação de Usuário
O sistema DEVE ter:
- Manual do usuário completo
- Tutoriais e guias
- FAQ (Perguntas Frequentes)
- Vídeos tutoriais (opcional)
- Help contextual

## 16. Qualidade de Código

### RNF-054: Padrões de Código
O sistema DEVE:
- Seguir style guides (Go, TypeScript)
- Usar linters (golangci-lint, ESLint)
- Usar formatters (gofmt, Prettier)
- Ter code review obrigatório
- Manter código DRY (Don't Repeat Yourself)

### RNF-055: Refatoração
O sistema DEVE:
- Permitir refatoração contínua
- Manter dívida técnica baixa
- Remover código morto regularmente
- Melhorar código existente

## 17. Gestão de Configuração

### RNF-056: Configuração
O sistema DEVE:
- Usar variáveis de ambiente para configuração
- Ter valores padrão sensatos
- Validar configuração na inicialização
- Documentar todas as opções de configuração

### RNF-057: Secrets
O sistema DEVE:
- Nunca commitar secrets no código
- Usar gerenciamento de secrets (Vault, AWS Secrets Manager)
- Rotacionar secrets regularmente
- Ter diferentes secrets por ambiente

## 18. Disaster Recovery

### RNF-058: Plano de Recuperação
O sistema DEVE ter:
- Plano de disaster recovery documentado
- Procedimentos de recuperação testados
- Backup de dados em múltiplas localizações
- Tempo de recuperação objetivo (RTO) < 4 horas
- Ponto de recuperação objetivo (RPO) < 1 hora

### RNF-059: Continuidade de Negócio
O sistema DEVE:
- Ter redundância de componentes críticos
- Ter failover automático quando possível
- Manter serviços essenciais durante manutenção
- Comunicar interrupções aos usuários

## 19. Performance de Rede

### RNF-060: Latência de Rede
O sistema DEVE:
- Otimizar para baixa latência
- Usar CDN para assets estáticos
- Implementar cache de browser apropriado
- Minimizar round-trips (batch requests quando possível)

### RNF-061: Largura de Banda
O sistema DEVE:
- Comprimir respostas (gzip, brotli)
- Usar lazy loading para media
- Implementar paginação para grandes datasets
- Otimizar tamanho de imagens
- Usar CDN para distribuição de shared decks
- Cachear shared decks populares
- Comprimir packages de decks compartilhados

## 20. Experiência do Usuário

### RNF-062: Tempo de Resposta Percebido
O sistema DEVE:
- Mostrar feedback imediato para ações do usuário
- Usar loading states apropriados
- Implementar optimistic updates quando possível
- Pre-carregar dados prováveis

### RNF-063: Consistência Visual
O sistema DEVE:
- Manter design system consistente
- Usar componentes reutilizáveis
- Manter paleta de cores consistente
- Seguir princípios de design (hierarquia, espaçamento)

### RNF-064: Feedback ao Usuário
O sistema DEVE:
- Confirmar ações destrutivas
- Mostrar mensagens de sucesso/erro claras
- Fornecer progresso para operações longas
- Permitir desfazer ações quando apropriado

## 21. Performance de Funcionalidades Específicas

### RNF-065: Performance do Browser
O sistema DEVE:
- Implementar virtual scrolling para grandes datasets (10.000+ itens)
- Renderizar apenas itens visíveis na viewport
- Carregar dados sob demanda ao fazer scroll
- Otimizar ordenação e filtros para grandes datasets
- Cachear resultados de busca no browser
- Permitir cancelar operações longas no browser

### RNF-066: Performance de Undo/Redo
O sistema DEVE:
- Manter histórico limitado (máximo 50 operações ou 5MB)
- Armazenar apenas diferenças (deltas) para economizar memória
- Executar undo/redo em < 100ms
- Limpar histórico antigo automaticamente
- Não manter histórico de operações irreversíveis

### RNF-067: Performance de LaTeX/MathJax
O sistema DEVE:
- Renderizar equações LaTeX de forma assíncrona
- Cachear imagens LaTeX geradas (mesmo hash)
- Renderizar MathJax sem bloquear UI
- Limitar tempo de renderização (timeout)
- Usar web workers para processamento pesado quando possível

### RNF-068: Performance de TTS
O sistema DEVE:
- Reproduzir áudio sem bloquear UI
- Suportar múltiplos áudios simultâneos
- Cachear áudio gerado quando possível
- Limitar tamanho de áudio gerado
- Interromper áudio rapidamente (< 50ms)

### RNF-069: Performance de Shared Decks
O sistema DEVE:
- Servir shared decks via CDN
- Cachear decks populares
- Comprimir packages antes de servir
- Suportar download resumable (retomar downloads)
- Validar integridade de packages baixados

### RNF-070: Performance de Check Database
O sistema DEVE:
- Executar verificação em background
- Não bloquear outras operações durante verificação
- Mostrar progresso da verificação
- Permitir cancelar verificação
- Otimizar verificação para grandes coleções (chunking)

### RNF-071: Performance de FSRS Simulator
O sistema DEVE:
- Executar simulação em background (não bloquear UI)
- Completar simulação de 365 dias em < 5 segundos para coleções com até 10.000 cards
- Mostrar progresso da simulação
- Permitir cancelar simulação
- Cachear resultados de simulação para mesma configuração
- Otimizar simulação para grandes coleções (chunking, aproximações)

### RNF-072: Disponibilidade de Self-Hosted Sync Server
O sistema DEVE:
- Suportar múltiplas instâncias do servidor (load balancing)
- Ter uptime de 99.5% (máximo 3.6 horas de downtime por mês)
- Recuperar de falhas em < 10 minutos
- Ter redundância de storage para dados de sincronização
- Manter logs de sincronização para troubleshooting

### RNF-073: Segurança de Self-Hosted Sync Server
O sistema DEVE:
- Validar autenticação em todas as requisições
- Implementar rate limiting (100 req/min por IP, 1000 req/min por usuário)
- Criptografar dados em trânsito (TLS 1.2+)
- Validar tamanho de payloads (MAX_SYNC_PAYLOAD_MEGS)
- Implementar timeout em requisições (30s padrão)
- Logar tentativas de acesso não autorizado

## Resumo

Total de requisitos não funcionais identificados: **73 requisitos principais**

Estes requisitos não funcionais garantem que o sistema não apenas funcione corretamente, mas também seja:
- **Rápido**: Performance adequada para uso diário
- **Seguro**: Proteção de dados e privacidade
- **Confiável**: Alta disponibilidade e recuperação de falhas
- **Escalável**: Suportar crescimento de usuários e dados
- **Usável**: Interface intuitiva e acessível
- **Manutenível**: Código limpo e bem documentado
- **Observável**: Logs, métricas e monitoramento adequados

Estes requisitos são essenciais para garantir a qualidade do sistema e a satisfação dos usuários.
