module Main

let main() =
	FStar.IO.print_string "Hello, world!\n"

#push-options "--warn_error -272"
let _ = main ()
#pop-options
