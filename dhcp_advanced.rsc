# dhcp_advanced
# Script para automatizar a criacao de regras de mangle e rotas para forcar saida pelo link de entrada
# Development by: Jayron Castro
# Date: 31/08/2022 21:28
# eMail: jayroncastro@gmail.com
{
  #======== VARIAVEL DE CONTROLE =========
  #"interfaceLan" Recebe o nome da interface local que representa a lan da rede;
  #"dnsCheckPing" Recebe o nome do domínio que será usado como ponto de checkping;
  #"ehCheckPing" Recebe verdadeiro caso seja necessário criar a rota padrão do link com opção de checkping;
  #"routeDistance" Recebe o distance da rota padrão a ser criada.
  #=======================================
  :local interfaceLan     "ether2-lan";
  #=== VARIAVEIS DE CONTROLE DE RECURSIVIDADE ===
  #=======================================
  :global dnsCheckPing  "aol.com.br";
  :local ehCheckPing    true;
  :global routeDistance "2";
  #=======================================

  :log warning "initializing script dhcp_advanced for interface: $interface";

  #Entra somente se a interface estiver ativa
  :if ([$bound] = 1) do={
    :log debug "Interface Enabled";
    #Executa instrução somente se a opção "add-default-route" não estiver selecionada
    :if (![/ip dhcp-client get $interface add-default-route]) do={
      #Retorna o ip do dns a ser pingado
      :local ipCheckPing [:resolve $dnsCheckPing];
      :delay 1;
      :log debug "IP Check ping: $ipCheckPing";

      #Cria a rota especifica para o gatewayCheckPing
      /ip route add dst-address=$ipCheckPing scope=10 gateway=$"gateway-address" comment="** link: $interface";

      #Cria a rota de saida padrao
      :if ($ehCheckPing) do={
        /ip route add dst-address=0.0.0.0/0 gateway=$ipCheckPing check-gateway=ping distance=$routeDistance comment="** link: $interface";
      } else={
        /ip route add dst-address=0.0.0.0/0 gateway=$ipCheckPing distance=$routeDistance comment="** link: $interface";
      }
    };

    #Marca conexão entrando pelo link
    :log debug "Creating connection markup mangle rule by entering the link: $interface";
    /ip firewall mangle add chain=prerouting in-interface=$interface connection-state=new connection-mark="no-mark" action=mark-connection new-connection-mark="in_$interface" comment="** marca conexao entrando pelo link $interface";
    :log debug "Connection markup mangle rule created successfully";

    #Marca rota de saída dos pacotes da lan pelo link que entrou
    :log debug "Creating route marking mangle rule entering through the interface: $interface";
    /ip firewall mangle add chain=prerouting in-interface=$interfaceLan connection-mark="in_$interface" action=mark-routing new-routing-mark="out_$interface" passthrough=no comment="** marca rota de saida dos pacotes da lan pelo link $interface";
    :log debug "Route marking mangle rule created successfully. :)";

    #Marca rota de saída local pela interface dhcp client especificado
    :log debug "Creating route marking mangle rule exiting through the interface: $interface";
    /ip firewall mangle add chain=output src-address=$"lease-address" action=mark-routing new-routing-mark="out_$interface" passthrough=no comment="** marca rota de saida local pelo link $interface";
    :log debug "Route marking mangle rule created successfully. :)";

    #Cria rota forcando saida pelo link dhcp client especificado
    :log debug "Creating default route to interface: $interface";
    /ip route add dst-address=0.0.0.0/0 gateway=$interface routing-mark="out_$interface" comment="** tabela de rota para a interface: $interface";
    :log debug "$interface route table created successfully. :)";

  } else={
    #Entra se a interface estiver desligada
    :log debug "Interface Disabled. :(";
    #Remove regras mangle para marcacao de rotas
    :log debug "initiating deletion of mangle rules with route marking in_$interface";
    /ip firewall mangle remove [find new-routing-mark="out_$interface"];
    :log debug "finalizing deletion of mangle rules with route marking in_$interface";

    #Remove regras mangle de marcacao de conexao
    :log debug "initiating deletion of mangle rules with connection markup in_$interface";
    /ip firewall mangle remove [find new-connection-mark="in_$interface"];
    :log debug "finalizing deletion of mangle rules with connection markup in_$interface";

    #Remove tabela de rota especifica do link dhcp client
    :log debug "initializing specific route deletion for link in_$interface";
    :log debug "gateway: $interface";
    :log debug "routingMark: out_$interface";
    /ip route remove [find gateway=$interface routing-mark="out_$interface"];
    :delay 1;
    :log debug "finalizing specific route deletion for link in_$interface";

    #Exclui as rotas criadas pelo script
    :log debug "initialize general route deletion for interface: $interface";
    /ip route remove [find comment="** link: $interface"];
    :delay 1;
    :log debug "finalizing general route deletion for interface: $interface";
  };

  :log warning "finalizing script dhcp_advanced for interface: $interface";
}