#!/bin/sh
read _
printf 'HTTP/1.0 200 Radamsa\r\n'
printf 'Content-Type: text/plain\r\n'
printf '\r\n'

./radamsa corpus/*.pvl
