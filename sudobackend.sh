cd "$2"

fifoid=$1

command_to_run=$(cat "$fifoid.command")
stdin=$(cat "$fifoid.fd0")
stdout=$(cat "$fifoid.fd1")
stderr=$(cat "$fifoid.fd2")

bash -c "$command_to_run" >"$stdout" 2>"$stderr" <"$stdin" &
pid=$!
echo $pid >"$fifoid.pidf"

while true; do
	sigint=$(cat "$fifoid.sigint")
	if [ ! -z "$sigint" ]; then
		if [ "$sigint" -eq 2 ]; then
			break
		fi
		kill -s SIGINT $pid
	fi
done &

wait $pid
echo 2 >"$fifoid.sigint"
echo 1 >"$fifoid.finish"