#!/bin/sh 

# assert_log "testlog" "/bin/sh" "-c" "echo 'testlog'; sleep infinity" 
assert_response 80 "Welcome to nginx"

