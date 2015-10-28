alias gooenv="source ~/code/virtualenv-goo/bin/activate; cd ~/code/"
alias serve="open http://127.0.0.1:8080/; python -m SimpleHTTPServer 8080"

alias gback="gooenv; cd createbackend; ./src/runserver.py"
alias gfront="gooenv; cd createfrontend; grunt build serve:dev"
alias gasync="gooenv; cd asyncher/source; ./start_asyncher.sh"
alias gserve="gooenv; cd serve.js; grunt serve"

alias gschema="gooenv; cd datamodel; grunt; cp schema_json/2.0/* ../createbackend/src/common/utils/schema_json/2.0"
