alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcs='docker-compose stop'
alias dcl='docker-compose logs -f'
alias dcuw='docker-compose logs -f unomalyweb'

dopen() {
    if [ "$1" != "" ] # or better, if [ -n "$1" ]
    then
        docker run -it $1 /bin/sh
    fi
}