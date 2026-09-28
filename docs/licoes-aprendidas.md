# Lições aprendidas

O primeiro ping do Ubuntu para o gateway deu 100% de perda. O IP da OPT1 estava certo. O problema é que interface nova no OPNsense não vem com regra nenhuma, e sem regra ele bloqueia tudo.

Foi olhando o console do firewall, que mostrava a OPT1 com 10.10.10.1/24, e o ip route do Ubuntu, com o gateway certo, que vi que endereço e rota estavam bons. Então só podia ser regra.

Para sair do lugar, criei uma regra Pass com tudo em any na OPT1. Funcionou, mas deixava a LAB-LAN sair para qualquer lugar. Depois troquei por regras só para DNS, HTTP, HTTPS e ping ao firewall. A regra de teste eu desativei em vez de apagar. Se precisar testar de novo, é só reativar.

Com as regras novas, o ping para 8.8.8.8 parou de responder. Isso é o esperado, porque o ICMP só está liberado para o próprio firewall. Por isso testei os dois lados: o que devia passar e o que devia ser bloqueado.

Tirei um snapshot da Ubuntu já atualizada e com a rede funcionando, o `ubuntu-atualizada-rede-ok`. Se algo der errado nas próximas mudanças, volto para esse ponto em vez de reinstalar.
