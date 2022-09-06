# dhcpmarkmangle
Script RouterOS para marcação de pacotes de saída na cadeia de mangle, especificamente para links DHCP Client

## Apresentação
A idéia de criar esse script nasceu da necessidade de automatizar o processo de marcação da conexão, rotas de saídas por link *dhcp client* e atualização do gateway em caso de reconexão do link *dhcp client*.

Caso a opção *"Add Default Route"* de uma conexão dhcp client não esteja seleciona o script cria automaticamente as rotas default na tabela de roteamento e caso a opção do script denominada *"ehCheckPing"* esteja informada como verdadeiro, no momento da criação da rota é habilitada a opção *"check ping"* na rota default para a interface.

O processo de marcação de conexão e rotas ocorre na tabela mangle, marcando o pacote de entrada e forçando sua saída pelo mesmo link.

## Definição
As variáveis de controle estão listadas abaixo:

```
:local interfaceLan   "bridge";
:global dnsCheckPing  "aol.com.br";
:local ehCheckPing    true;
:global routeDistance "2";
```

- **interfaceLan:** variável que recebe o nome da interface local que representa a lan da rede;
- **dnsCheckPing:** variavel que recebe o nome do domínio que será usado como ponto de checkping, nunca o valor deve ser repetido em caso de usar o script em vários links;
- **ehCheckPing:** variável que recebe verdadeiro caso seja necessário criar a rota padrão do link com opção de checkping;
- **routeDistance:** variável que recebe o distance da rota padrão a ser criada.

## Compatibilidade
Este script foi homologado para a versão 6.48.6 do RouterOS.

## Como usar
Este script deve ser inserido na interface dhcp client, na aba avançada, seguem os passos abaixo:

1. Abrir a interface dhcp client já previamente criada;
2. Acessar a aba *Avançada* e copiar o conteúdo do script [dhcp_advanced.rsc](https://github.com/jayroncastro/dhcpmarkmangle/blob/master/dhcp_advanced.rsc) na caixa denominada *script*;
3. Configurar as variáveis necessárias conforme seu cenário.

## Sugestões e Melhorias
Sugestões, Bugs e melhorias podem ser informadas ou solicitadas via [Issues](https://github.com/jayroncastro/dhcpmarkmangle/issues)