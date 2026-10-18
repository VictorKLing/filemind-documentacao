# FileMind — Escopo do MVP

Data: 18/10/2026  
Status: escopo inicial para orientar o desenvolvimento.

## 1. Objetivo

Permitir que usuários armazenem, organizem e consultem seus arquivos Markdown por meio de uma interface de gerenciamento e de um chat com inteligência artificial. O chat utilizará RAG para recuperar trechos dos documentos do usuário e elaborar respostas contextualizadas.

## 2. Decisões confirmadas

- Backend em Java 21 com Spring Boot.
- Frontend em React, com Google Drive como referência para o gerenciamento de arquivos.
- PostgreSQL com pgvector para persistência e busca vetorial.
- Armazenamento do conteúdo dos arquivos no Amazon S3.
- Apenas arquivos `.md` no MVP.
- Cada arquivo pertence a um único usuário e só pode ser acessado por seu dono.
- Não haverá compartilhamento de arquivos.
- A organização apresentada no frontend será representada no banco e será independente da chave S3.
- A IA poderá apenas consultar arquivos; não poderá criar, alterar, mover ou excluir arquivos.
- Metadados dos arquivos serão associados aos chunks para enriquecer o contexto do RAG.
- Memória persistente dos agentes ficará fora do MVP.

### Sequência de implementação escolhida

1. Autenticação e isolamento por dono.
2. Gerenciamento de Markdown e caminho virtual.
3. Ingestão e indexação.
4. Chat com RAG e fontes.

## 3. Funcionalidades contempladas

- Autenticação simples com usuário e senha.
- Gerenciamento dos próprios arquivos Markdown.
- Upload, listagem, visualização, download e exclusão de arquivos.
- Representação de caminho virtual para a interface.
- Processamento de documentos em chunks e embeddings.
- Consulta por IA restrita aos documentos do usuário autenticado.
- Apresentação dos arquivos utilizados como fontes nas respostas.

A criação de pastas, a forma de edição dos arquivos e a disponibilidade de cadastro público ainda dependem de definição.

## 4. Fora do escopo

- Compartilhamento e colaboração entre usuários.
- Arquivos PDF, DOCX, TXT, XLSX e outros formatos diferentes de Markdown.
- Criação ou alteração de arquivos pela IA.
- Memória persistente dos agentes.
- Versionamento de documentos e recuperação de versões anteriores.
- Integração com outros provedores de armazenamento, além do S3.

Histórico de chat, recuperação de senha e exclusão de conta não estão incluídos como entregas confirmadas; dependem de definição explícita.

## 5. Regras de negócio

| ID | Regra |
| --- | --- |
| RN01 | Cada arquivo deve pertencer a um único usuário. |
| RN02 | Apenas o proprietário poderá listar, visualizar, baixar, organizar, alterar ou excluir seus arquivos, conforme as operações disponibilizadas no MVP. |
| RN03 | Não haverá compartilhamento entre usuários. |
| RN04 | O proprietário será identificado pela autenticação. Um ID enviado pelo frontend não comprova autorização. |
| RN05 | Apenas arquivos com extensão `.md` serão aceitos. |
| RN06 | O conteúdo será armazenado no S3; identificação, organização, metadados e status de processamento serão mantidos no PostgreSQL. |
| RN07 | A chave S3 seguirá o padrão `usuarios/{usuarioId}/arquivos/{uuid}-{nomeArquivo}.md`. |
| RN08 | O caminho virtual será independente da chave S3. A estrutura interna de armazenamento não será apresentada ao usuário. |
| RN09 | Os metadados relevantes serão associados aos respectivos chunks. |
| RN10 | A recuperação de contexto do RAG será restrita ao usuário autenticado, antes de qualquer envio ao modelo. |
| RN11 | A IA realizará somente consultas e não terá operações de escrita sobre arquivos. |
| RN12 | Apenas arquivos com indexação concluída poderão participar das consultas por IA. |
| RN13 | Falhas de indexação serão identificadas por arquivo e não impedirão consultas aos demais documentos já processados. |
| RN14 | Um arquivo excluído deixará de participar de novas consultas, mesmo que sua limpeza física ainda esteja em andamento. |
| RN15 | As respostas sobre documentos deverão indicar as fontes recuperadas. Sem contexto suficiente, a IA deverá informar essa limitação. |
| RN16 | Cada arquivo deverá possuir proprietário, nome, caminho virtual, tamanho e datas de controle no FileMind. |
| RN17 | O caminho virtual representará a organização no FileMind, independentemente do caminho original no computador e da chave S3. |
| RN18 | Arquivos poderão possuir metadados opcionais, como título, autor e categoria. Esses valores não poderão determinar propriedade ou autorização de acesso. |
| RN19 | As quantidades de linhas, palavras e caracteres deverão ser calculadas pelo backend a partir do conteúdo do arquivo, com critérios de contagem definidos na implementação. |
| RN20 | Um arquivo poderá gerar vários chunks. Cada chunk deverá estar associado ao arquivo de origem e preservar sua posição no documento. |
| RN21 | Os chunks deverão preservar informações suficientes para identificar a fonte utilizada nas respostas, como arquivo e, quando disponível, seção ou linhas de origem. |
| RN22 | As datas de criação e atualização no FileMind deverão ser diferenciadas de eventuais datas originais fornecidas no upload. As datas originais serão opcionais e não substituirão as datas controladas pelo sistema. |

### Regras propostas para funcionalidades pendentes

- Se houver atualização de conteúdo, os chunks e embeddings deverão representar a versão atual antes de sua disponibilização ao RAG.
- Se houver pastas, nomes repetidos serão permitidos em pastas diferentes. A política para duplicidade na mesma pasta ainda precisa ser confirmada.
- Mover ou renomear um arquivo deverá preservar sua identidade e sua relação com os chunks, atualizando os metadados pertinentes.

### Exemplo de armazenamento

Bucket de desenvolvimento: `filemind-documents-dev`.

```text
s3://filemind-documents-dev/usuarios/2/arquivos/1a05d7ef-edc5-42d5-bd63-1101a38d520e-README.md
```

Esse endereço representa o armazenamento físico. O caminho virtual apresentado pela interface será registrado separadamente no banco.

## 6. Requisitos funcionais

| ID | Requisito |
| --- | --- |
| RF01 | Permitir autenticação com usuário e senha e encerramento da sessão. |
| RF02 | Identificar o usuário autenticado e autorizar o acesso apenas aos seus próprios recursos. |
| RF03 | Suportar criação de usuários; a exposição do cadastro ao público depende de definição. |
| RF04 | Permitir upload de `.md`, validando extensão, presença de conteúdo e limites configurados. |
| RF05 | Registrar proprietário, nome, caminho virtual, extensão, tipo MIME, tamanho, chave S3, datas e status de processamento. |
| RF06 | Listar os arquivos do usuário com paginação e informações necessárias ao gerenciamento, sem expor a chave S3. |
| RF07 | Permitir visualizar e baixar os próprios arquivos. |
| RF08 | Permitir excluir arquivos, coordenando a remoção no S3, no banco e na estrutura de RAG. |
| RF09 | Representar o caminho virtual dos arquivos de forma independente do armazenamento físico. |
| RF10 | Dividir o conteúdo Markdown em chunks e gerar embeddings. |
| RF11 | Armazenar chunks, embeddings e metadados associados no PostgreSQL com pgvector. |
| RF12 | Controlar e apresentar os estados enviado, processando, processado e erro. |
| RF13 | Permitir nova tentativa de indexação após falha, sem duplicar chunks da mesma versão. |
| RF14 | Disponibilizar chat para perguntas sobre os documentos do usuário autenticado. |
| RF15 | Recuperar trechos relevantes e fornecê-los ao modelo como contexto. |
| RF16 | Apresentar as fontes utilizadas nas respostas e permitir ao proprietário acessar os documentos correspondentes. |
| RF17 | Informar erros de upload, processamento e consulta com mensagens compreensíveis. |
| RF18 | Armazenar metadados opcionais dos arquivos e calcular estatísticas do conteúdo no backend. |
| RF19 | Registrar a ordem dos chunks e informações de localização no documento para apoiar a apresentação de fontes. |

### Funcionalidades propostas, sujeitas a definição

| ID | Proposta |
| --- | --- |
| RFP01 | Criar pastas virtuais e mover ou renomear arquivos. |
| RFP02 | Atualizar conteúdo por substituição via upload. Um editor Markdown integrado não é uma entrega confirmada. |
| RFP03 | Selecionar arquivos ou pastas para limitar o contexto de uma conversa. |

## 7. Requisitos não funcionais

| ID | Categoria | Requisito |
| --- | --- | --- |
| RNF01 | Tecnologia | Utilizar Java 21, Spring Boot, React, PostgreSQL, pgvector e S3. |
| RNF02 | Segurança | Armazenar senhas com algoritmo próprio para hash de senhas, nunca em texto puro. |
| RNF03 | Segurança | Utilizar HTTPS nos ambientes acessíveis pela rede. |
| RNF04 | Segurança | Aplicar autorização por proprietário em todas as operações e buscas do RAG. |
| RNF05 | Segurança | Manter objetos S3 privados e validar autorização antes de permitir downloads. |
| RNF06 | Segurança | Fornecer segredos por configuração externa ao código e evitar sua exposição em logs e respostas. |
| RNF07 | Segurança da IA | Tratar documentos como conteúdo de consulta. Instruções presentes nos arquivos não poderão conceder acesso ou autorizar operações. |
| RNF08 | Consistência | Tratar falhas entre S3 e banco com compensação ou reconciliação. |
| RNF09 | Confiabilidade | Tornar a reindexação da mesma versão idempotente, sem duplicação de chunks. |
| RNF10 | Desempenho | Paginar listagens e definir limites de upload, armazenamento e concorrência. Os valores ainda estão pendentes. |
| RNF11 | Observabilidade | Registrar falhas e transições de processamento com identificação para diagnóstico, evitando conteúdo sensível desnecessário. |
| RNF12 | Banco | Versionar alterações do esquema por migrações reproduzíveis. |
| RNF13 | Testes | Cobrir isolamento entre usuários, autenticação, validação de arquivos e consistência de upload, exclusão e indexação. |
| RNF14 | Usabilidade | Apresentar estados de carregamento, processamento, sucesso e falha; solicitar confirmação para exclusão de arquivos. |
| RNF15 | Manutenibilidade | Delimitar as responsabilidades das integrações com S3, geração de embeddings e modelo de linguagem. |

**Proposta técnica:** realizar a indexação de forma assíncrona, permitindo concluir o upload sem esperar pela geração dos embeddings.

Tempos de resposta, disponibilidade, retenção de dados, recuperação de backups e orçamento de uso da IA ainda precisam de metas mensuráveis.

## 8. Etapas e critérios de aceite

### Etapa 1 — Autenticação e isolamento por dono

Entregas:

- Login, identificação do usuário autenticado e encerramento da sessão.
- Hash de senhas e proteção dos endpoints.
- Remoção da confiança em IDs enviados pelo cliente para determinar o proprietário.
- Restrição das operações de usuários e arquivos ao acesso autorizado.
- Correção da atualização parcial de usuário para preservar campos omitidos.

Critérios de aceite:

- Credenciais válidas permitem autenticação e credenciais inválidas são rejeitadas.
- Requisições sem autenticação não acessam recursos protegidos.
- Um usuário não consegue consultar nem modificar recursos de outro, mesmo alterando IDs na requisição.
- Senhas não aparecem em texto puro no banco ou nas respostas.
- Atualizações parciais preservam campos não enviados.

### Etapa 2 — Gerenciamento de Markdown e caminho virtual

Entregas:

- Restrição do upload a Markdown.
- Caminho virtual persistido separadamente da chave S3.
- Upload, listagem paginada, visualização, download e exclusão.
- Validações e tratamento de falhas de armazenamento.
- Organização em pastas e atualização de conteúdo somente após confirmação de escopo.

Critérios de aceite:

- Arquivos de outros formatos e uploads vazios são rejeitados com erro de entrada compreensível.
- O objeto é armazenado no padrão S3 definido e associado ao proprietário correto.
- A interface recebe o caminho virtual sem depender da chave S3.
- Somente o proprietário visualiza, baixa ou exclui o arquivo.
- Estatísticas são calculadas pelo backend e datas do sistema permanecem distintas de eventuais datas originais.
- Falhas entre S3 e banco possuem tratamento verificável de compensação ou reconciliação.

### Etapa 3 — Ingestão e indexação

Entregas:

- Estrutura de chunks e embeddings no pgvector, com migrações.
- Fluxo de processamento e atualização de status.
- Associação entre usuário, arquivo, chunks e metadados.
- Tratamento de falhas e nova tentativa de processamento.
- Exclusão dos dados de indexação relacionados ao arquivo.

Critérios de aceite:

- Um Markdown válido percorre os estados de processamento até ficar disponível para consulta.
- Falhas ficam identificadas e permitem nova tentativa.
- Reprocessar a mesma versão não duplica chunks.
- Cada chunk permite identificar o arquivo e seu proprietário.
- Cada chunk preserva sua ordem e as informações de origem disponíveis para referência nas respostas.
- Arquivos excluídos não aparecem nos resultados de recuperação.

### Etapa 4 — Chat com RAG e fontes

Entregas:

- Interface e endpoint de chat.
- Busca de contexto restrita ao usuário autenticado.
- Geração de resposta com fontes.
- Tratamento de ausência de contexto e falhas dos provedores de IA.

Critérios de aceite:

- Perguntas sobre arquivos processados recuperam contexto do próprio usuário.
- Documentos de outro usuário nunca são enviados como contexto ao modelo.
- As fontes apresentadas correspondem aos documentos recuperados e respeitam a autorização.
- Sem contexto suficiente, a resposta informa a limitação.
- A IA não possui ferramentas que criem ou alterem arquivos.

## 9. Situação encontrada no código


| Área | Situação |
| --- | --- |
| Usuários | CRUD implementado; autenticação e autorização ausentes; senhas armazenadas em texto puro. |
| Upload | Integração com S3 e persistência implementadas; aceita formatos além de `.md`. |
| Propriedade | Existe vínculo entre arquivo e usuário, mas o acesso depende de ID enviado pelo cliente. |
| Organização | Chave S3 no padrão definido; caminho virtual ausente. |
| Gerenciamento | Upload e listagem implementados; leitura, download, edição e exclusão de arquivos ausentes. |
| RAG | Campo e enum de status existentes; chunks, embeddings, recuperação e chat ausentes. |
| Qualidade | Tratamento parcial de erros; apenas teste de carregamento de contexto; migrações não encontradas. |
| Frontend | Não encontrado no repositório analisado. |

## 10. Condição de conclusão do MVP

O MVP estará concluído quando um usuário conseguir autenticar-se, enviar e gerenciar seus arquivos Markdown e consultar seu conteúdo pelo chat com fontes, com isolamento entre usuários e tratamento verificável das falhas essenciais de armazenamento e indexação. Funcionalidades ainda propostas só integrarão essa condição após confirmação explícita.

## 11. Modelo de dados proposto

Esta seção orienta a implementação técnica. Os nomes de tabelas e campos são sugestões e deverão ser ajustados às convenções e migrações do projeto.

### 11.1. Arquivos

Dados essenciais à identificação, autorização, organização e operação ficarão em colunas. Metadados complementares e extensíveis ficarão em JSONB.

| Campo sugerido | Armazenamento | Finalidade |
| --- | --- | --- |
| `id` | Coluna, chave primária | Identidade do arquivo. |
| `usuario_id` | Coluna, chave estrangeira | Proprietário e base para autorização. |
| `nome` | Coluna | Nome apresentado ao usuário. |
| `extensao` | Coluna | Extensão permitida no MVP. |
| `tipo_mime` | Coluna | Tipo do conteúdo. |
| `caminho_virtual` | Coluna | Organização no FileMind, por exemplo `/documentacao/teste.md`. |
| `s3_key` | Coluna interna | Localização física do objeto no S3. |
| `tamanho_bytes` | Coluna | Tamanho do arquivo recebido. |
| `criado_em` | Coluna temporal com fuso | Data de criação do registro no FileMind, gerada pelo backend. |
| `atualizado_em` | Coluna temporal com fuso | Data da última atualização do registro no FileMind, gerada pelo backend. |
| `status_rag` | Coluna | Estado de processamento. |
| `metadados` | JSONB | Título, autor, categoria, estatísticas e outros atributos opcionais. |

Exemplo do conteúdo da coluna `metadados`:

```json
{
  "titulo": "FileMind",
  "autor": "Yuri",
  "categoria": "documentacao",
  "estatisticas": {
    "quantidade_linhas": 5,
    "quantidade_palavras": 13,
    "quantidade_caracteres": 88
  }
}
```

Não duplicar nesse JSON os campos que já possuem colunas como fonte oficial, especialmente proprietário, caminho virtual e chave S3. Caso sejam recebidas datas originais, registrá-las com nomes explícitos, como `origem.criado_em` e `origem.modificado_em`, preservando a informação de fuso quando disponível. Um upload comum não fornece automaticamente as datas originais do sistema de arquivos.

O caminho local do computador, como `C:\Users\usuario\Desktop\teste.md`, não será utilizado como caminho virtual nem como endereço de armazenamento. Seu recebimento ou persistência não é necessário ao MVP.

### 11.2. Chunks dos arquivos

Cada chunk terá um registro próprio. O conteúdo dos trechos e seus embeddings não serão armazenados dentro do JSON de metadados do arquivo.

| Campo sugerido | Armazenamento | Finalidade |
| --- | --- | --- |
| `id` | Coluna, chave primária | Identidade do chunk. |
| `arquivo_id` | Coluna, chave estrangeira | Vínculo obrigatório com o arquivo de origem. |
| `indice` | Coluna | Ordem do chunk no documento. |
| `conteudo` | Coluna de texto | Trecho utilizado na recuperação de contexto. |
| `embedding` | Coluna vetorial do pgvector | Representação vetorial; dimensão depende do modelo escolhido. |
| `metadados` | JSONB | Informações específicas do trecho, como seção e linhas de origem. |

Exemplo do conteúdo da coluna `metadados` de um chunk:

```json
{
  "secao": "Introducao",
  "linha_inicial": 1,
  "linha_final": 5
}
```

O vínculo com o arquivo permitirá recuperar os metadados gerais sem copiá-los integralmente em cada chunk. As consultas vetoriais deverão restringir os resultados ao proprietário por meio desse vínculo antes de fornecer contexto à IA. Qualquer duplicação futura de dados para otimizar consultas deverá preservar essa consistência e o isolamento entre usuários.

### 11.3. Pontos técnicos a definir

- Origem dos metadados opcionais: entrada manual, front matter Markdown ou outra fonte explicitamente definida.
- Critérios de contagem de linhas, palavras e caracteres, incluindo o tratamento da sintaxe Markdown.
- Modelo de embeddings, dimensão vetorial e estratégia de chunking.
- Estratégia para manter metadados e embeddings consistentes quando houver atualização de arquivos.
