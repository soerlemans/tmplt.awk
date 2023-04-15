#!/usr/bin/env -S awk -f


# Function to extract the | or ! indicator
function indicator(t_str)
{
	start = match(t_str, /[|!]/)

	return substr(t_str, start, 1)
}

# Function to extract the interpreter argument
function interpreter(t_str)
{
		start = match(t_str, /^#[|!]:[a-zA-Z0-9]+/)
		if(start){
				str = substr(t_str, RSTART + 3, RLENGTH)
    }else{
				# Set default interpreter to use
				str = "sh"
		}

		return str
}

BEGIN {
		# Set temporary dir
		"mktemp --directory '/tmp/app.awk-XXXXXX'" | getline tmp_dir
}

# Rule for printing when we are not in the template mode
! tmplt_mode && /^[^#]/ {
	print $0
}

# Rule for detecting end of template
tmplt_mode && /^[|!]#/ {
		if(tmplt_indicator == indicator($0)){
				tmplt_mode = 0
				tmplt_indicator = 0

				tmp_file = tmp_dir "/template.tmp"
				print verbatim > tmp_file
				system(tmplt_interpreter " " tmp_file)

				verbatim = ""
		}
}

# Rule for evaluating contents of template
tmplt_mode {
		verbatim = verbatim $0 "\n"
}

# Rule for detecting begin of template
/^#[|!]/ {
	tmplt_mode = 1
  tmplt_indicator = indicator($0)
	tmplt_interpreter = interpreter($0)
}
