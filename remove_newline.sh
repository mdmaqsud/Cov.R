## one liner shell script which removes the newline characters
sed ':a;N;$!ba;s/\n//g'
