# Projeto Paygo-ACBr-SACFiscal-Nuvem Fiscal

![alt text](https://www.sacfiscal.com.br/paygo/fmx/logo_fmx.jpg)

## Demo PayGO FMX

Este projeto visa acelerar a estratégia da Software House na adoção do android no varejo, integrado ao TEF PayGO e API NFC-e da Nuvem Fiscal, demonstrando como integrar ao PayGO Integrado no android e à API de NFC-e.

## Ambiente e Componentes Utilizados

- Delphi Alexandria 11 Update 2 (Esta versão compila aplicativos da versão android 8.1 acima. Para versões anteriores é preciso utilizar a versão correta do Delphi, conforme documentação: https://docwiki.embarcadero.com/PlatformStatus/en/Main_Page)
- O banco de dados que armazena as informações locais no aplicativo: SQLite (https://sqlite.org/)
- ACBrTEFAndroid (https://projetoacbr.com.br/fontes/)
  Fórum ACBR de suporte ao ACBrTEF: https://www.projetoacbr.com.br/forum/forum/13-d%C3%BAvidas-sobre-tef/
- SDK Nuvem Fiscal (https://github.com/nuvem-fiscal/nuvemfiscal-sdk-delphi)
  Documentação de utilização do SDK da Nuvem Fiscal: https://dev.nuvemfiscal.com.br/docs/sdk-delphi
- Aplicativo PayGO Integrado v. 4.21.8 (https://projetoacbr.com.br/tef/#integracao)

## Estrutura do Projeto

![alt text](https://www.sacfiscal.com.br/paygo/fmx/estrutura.png)

- Commons: Units utilizadas nas demais camadas do projeto
- Infraestructure: Units de configuração e DTO (Data Transfer Object) de emissão da NFCe, do menu administrativo PayGO e de impressão
- Libs: Bibliotecas de impressão necessárias ao projeto, e a lib Interfaceautomação que é utilizada no TEF android
- Presentation: Camada de visualização/telas do aplicativo

###### OBS: Usamos uma versão customizada da unit do ACBr devido a um retorno inesperado na unit ACBrTEFPayGoAndroidAPI.pas (linha 1126)

if (RequestCode = Intent_ResultCode) then

## Execução da chamada do TEF:

- Ocorre na unit uFormVendasPagamento.pas, linha 586 – procedure btnTefPayGOClick, com chamada da procedure Inicializar TEF (linha 655 -> linha 164). Ele chama o ACBrTEF.Inicializar (linha 201)

## Execução da Chamada da API NFC-e:

- Ao autorizar a transação, na unit uFormVendasPagamento.pas, linha 236, procedure ACBrTEFQuandoFinalizarOperacao, é chamada a função nuvemFiscalEmitirNFCe(vendaID), linha 427.
- Todas as chamadas a API de NFC-e estão na unit uFuncoesNuvemFiscalAPI.pas na camada Commons.

## Utilização do Aplicativo

1 - Na primeira execução do app, será solicitado o CNPJ da empresa, que deverá estar previamente cadastrada na API da Nuvem Fiscal, pela própria Software House.

![alt text](https://www.sacfiscal.com.br/paygo/fmx/t1_fmx.png)

2 - Após a validação do CNPJ na API da Nuvem Fiscal, será solicitado login (usuário: admin/senha: admin) para acesso ao app.

![alt text](https://www.sacfiscal.com.br/paygo/fmx/t2_fmx.png)

3 - Na tela principal temos acesso aos cadastros e às configurações. Inicialmente deve ser configurado o ambiente de emissão, a série de NFCe a ser utilizada e a última numeração para sequência da NFC-e.

![alt text](https://www.sacfiscal.com.br/paygo/fmx/t3_fmx.png)

4 - Na aba de Impressão, escolhemos a impressora, via bluetooth que será utilizada nas impressões.

![alt text](https://www.sacfiscal.com.br/paygo/fmx/t4_fmx.png)

5 - Na tela de venda, após inserir os produtos, ocorre a finalização da venda com o pagamento via TEF ou dinheiro e na sequência a emissão da NFC-e.

![alt text](https://www.sacfiscal.com.br/paygo/fmx/t5_fmx.png)

6 - O XML autorizado é baixado e salvo no banco dedados local e a impressão do DANFECe se dá consumindo o endpoint de ESCPOS na API da Nuvem Fiscal, e mandando para o componente ACBrPOSPrinter.
7 - Os comprovantes de transações TEF impressos também são gravados no banco de dados local do app.
8- O aplicativo possui a implementação da inutilização de numeração (uFormInutilizacao.pas) e cancelamento da NFCe.

## Licença

MIT
