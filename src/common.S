#
# Common definitions for the program
#

# Pulled from standard POSIX headers
# Note: these are in octal
.equ O_CREAT,01000
.equ O_APPEND,00010
.equ O_TRUNC,02000

#
# Symbols defined in flt-conf.S
#
.ifndef FLT_CONV_S

.extern read_char
.extern print_char
.extern int_to_string
.extern string_to_int
.extern float_to_int
.extern print_float
.extern parse_float
.extern verify_float

.else

.global read_char
.global print_char
.global int_to_string
.global string_to_int
.global float_to_int
.global print_float
.global parse_float
.global verify_float 
.endif


