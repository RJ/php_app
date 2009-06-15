THRIFT_EBIN=/home/rj/thrift/lib/erl/ebin/

echo "Compiling thrift file"
thrift -erl *.thrift
echo "Compiling erlang source"
erlc -v -I gen-erl/ -o ebin/ src/*.erl gen-erl/*.erl
echo "Running, with thrift ebin set to '${THRIFT_EBIN}'"
PING="phpapp@`hostname`"
erl -name whocares@`hostname` \
    -pa ebin/ \
    -pa ${THRIFT_EBIN} \
    -pa ../ebin \
    -eval "net_adm:ping($PING), whocares:start_link(9123)."
