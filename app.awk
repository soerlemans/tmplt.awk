#!/usr/bin/env -S awk -f

# This awk script contains the source for a simple preprocessor.
# Comment blocks are started with #? and end in ?#.
# Template blocks are started with either a #! or #| and end in |# or !#.
# Everything outside of a comment block or template block is printed regularly.
# Everything inside of a template block is evaluated by default using sh.
# You can specify the interpreter/program to run on the template block,
# in the following way: #!:<interpreter>
# Examples:
# #!:python
# #!:perl
# #!:fish


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
		tmp_file = tmp_dir "/template.tmp"
}

END {
		# Remove the temporary directory when the script is done
		system("rm  -r " tmp_dir "/")
}

# Rule for detecting begin of a comment block
!tmplt_mode && /^#\?/ {
		cmnt_mode = 1
}

# Rule for detecting end of a comment block
cmnt_mode && /^\?#/ {
		cmnt_mode = 0
		next
}

# As long as we are in comment mode skip the line
cmnt_mode {
		next
}

# Rule for detecting begin of template
/^#[|!]/ {
		# If we are on the first line we do not want the shebang
		# To have us enter template mode
		if(NR != 1){
				tmplt_mode = 1
				tmplt_indicator = indicator($0)
				tmplt_interpreter = interpreter($0)
		}

		next
}

# Rule for printing when we are not in the template mode
! tmplt_mode {
		print $0
}

# Rule for detecting end of template
tmplt_mode && /^[|!]#/ {
		if(tmplt_indicator == indicator($0)){
				tmplt_mode = 0
				tmplt_indicator = 0

				print verbatim > tmp_file
				verbatim = ""

				system(tmplt_interpreter " " tmp_file)

				# Awk redirection only clears the file contents on first open
				# We must explicitly close it for it to be cleared again
				close(tmp_file)
		}
}

# Rule for evaluating contents of template
tmplt_mode {
		verbatim = verbatim $0 "\n"
}
