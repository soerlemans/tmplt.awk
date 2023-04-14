#!/usr/bin/env -S awk -f


# Function to extract the | or ! indicator
function indicator()
{
	start = match($0, /[|!]/)
	return substr($0, start, 1)
}

# Function to extract the interpreter argument
function interpreter()
{

}

# Rule for printing when we are not in the template mode
! tmplt_mode && /^[^#]/ {
	print $0
}

# Rule for detecting end of template
tmplt_mode && /^[|!]#/ {
		if(tmplt_indicator == indicator()){
				tmplt_mode = 0
				tmplt_indicator = 0

				# TODO: Add support for other interpreters
				# system(verbatim)
				print verbatim > "/tmp/app.awk.tmp"
				system("sh /tmp/app.awk.tmp")

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
  tmplt_indicator = indicator()
}
