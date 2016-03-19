alias g="gulp"
alias slay="kill \$(lsof -i :4001 | grep node | awk '{print \$2}')"
alias testlab="c adserver-manager-service/diamond; grunt testlab"
