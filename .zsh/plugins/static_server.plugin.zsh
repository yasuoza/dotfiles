## Start static server
# http://blog.kamipo.net/entry/2013/02/20/122225
function static_httpd {
  if which ruby > /dev/null; then
    ruby -rwebrick -e 'WEBrick::HTTPServer.new(:Port => 5000, :DocumentRoot => ".").start'
  elif which php > /dev/null && php -v | grep -qm1 'PHP 5\.[45]\.'; then
    php -S 0.0.0.0:5000
  fi
}
