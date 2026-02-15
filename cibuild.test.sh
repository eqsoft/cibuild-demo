#!/bin/sh

cibuild_log_info "this is a custom script in an unlocked job container, be careful!"

assert_log "testlog" "/bin/sh" "-c" "echo 'testlog'; sleep infinity" 
assert_response "Welcome to nginx" 80 "keep"
