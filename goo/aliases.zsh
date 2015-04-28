alias gooenv="source ~/code/virtualenv-goo/bin/activate; cd ~/code/"
alias serve="open http://127.0.0.1:8080/; python -m SimpleHTTPServer 8080"

alias gooback="gooenv; cd createbackend; ./src/runserver.py"
alias goofront="gooenv;  cd createfrontend; grunt serve:dev"
alias gooasync="gooenv; cd asyncher/source; ./start_asyncher.py"
alias gooserve="gooenv; cd serve.js; grunt serve"