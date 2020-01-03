%include{
#include <iostream>

#include "VUComp.h"

#define LEMON_SUPER VU_Parser
}


%code {

VU_Parser * VU_Parser::create(std::string fName, std::string & fText)
{
	return new yypParser(fName, fText);
}
}

%syntax_error {
	const YYACTIONTYPE stateno = yytos->stateno;
	size_t eolPos = fText.find("\n", m_pos);
	std::string eLine = fText.substr(m_pos, eolPos - m_pos);

	std::cerr << "vuc: " << fName << "(" << std::to_string(m_line) + "," 
			  << std::to_string(m_col) << "): "
			  << "Error V1001: Syntax error: unexpected " 
			  << yyTokenName[yymajor] << "\n";

	std::cerr << "+ " << eLine << "\n";
	std::cerr << "+ ";
	for (int i = 1; i < m_col; i++)
		std::cerr << " ";
	std::cerr << "^";

	std::cerr << "\n\texpected one of: \n";

	for (unsigned i = 0; i < YYNTOKEN; ++i)
	{
		int yyact = yy_find_shift_action(i, stateno);
		if (yyact != YY_ERROR_ACTION && yyact != YY_NO_ACTION)
			std::cerr << "\t" << yyTokenName[i] << "\n";
	}

}


%token_type    {Token}
%token_prefix  TOK_

%left COMMA.
%left LBRACKET LSBRACKET RBRACKET RSBRACKET.

file ::= statement_list EOF.

statement_break ::= EOL.

statement_list ::= statement statement_break.
statement_list ::= statement_list statement statement_break.

statement ::= primary_expr argument_expr_list.

primary_expr
	::= IDENTIFIER.
primary_expr
	::= CONSTANT.
primary_expr
	::= STRING_LITERAL.
primary_expr
	::= LBRACKET expr RBRACKET.

postfix_expr
	::= primary_expr.
postfix_expr
	::= postfix_expr LSBRACKET expr RSBRACKET.
postfix_expr
	::= postfix_expr LBRACKET RBRACKET.
postfix_expr
	::= postfix_expr LBRACKET argument_expr_list RBRACKET.
postfix_expr
	::= postfix_expr DOT IDENTIFIER.
postfix_expr
	::= postfix_expr PTR_OP IDENTIFIER.
postfix_expr
	::= postfix_expr INC_OP.
postfix_expr
	::= postfix_expr DEC_OP.

argument_expr_list
	::= assign_expr.
argument_expr_list
	::= argument_expr_list COMMA assign_expr.

unary_expr
	::= postfix_expr.
unary_expr
	::= INC_OP unary_expr.
unary_expr
	::= DEC_OP unary_expr.
unary_expr
	::= unary_operator cast_expr.
unary_expr
	::= SIZEOF unary_expr.
unary_expr
	::= SIZEOF LBRACKET type_name RBRACKET.

unary_operator
	::= AND.
unary_operator
	::= STAR.
unary_operator
	::= PLUS.
unary_operator
	::= MINUS.
unary_operator
	::= TILDE.
unary_operator
	::= EXCLAMATION.

cast_expr
	::= unary_expr.
cast_expr
	::= LBRACKET type_name RBRACKET cast_expr.

mul_expr
	::= cast_expr.
mul_expr
	::= mul_expr STAR cast_expr.
mul_expr
	::= mul_expr FSLASH cast_expr.
mul_expr
	::= mul_expr PERCENT cast_expr.

add_expr
	::= mul_expr.
add_expr
	::= add_expr PLUS mul_expr.
add_expr
	::= add_expr MINUS mul_expr.

shift_expr
	::= add_expr.
shift_expr
	::= shift_expr LEFT_OP add_expr.
shift_expr
	::= shift_expr RIGHT_OP add_expr.

rel_expr
	::= shift_expr.
rel_expr
	::= rel_expr LCARET shift_expr.
rel_expr
	::= rel_expr RCARET shift_expr.
rel_expr
	::= rel_expr LE_OP shift_expr.
rel_expr
	::= rel_expr GE_OP shift_expr.

eq_expr
	::= rel_expr.
eq_expr
	::= eq_expr EQ_OP rel_expr.
eq_expr
	::= eq_expr NE_OP rel_expr.

and_expr
	::= eq_expr.
and_expr
	::= and_expr AND eq_expr.

excl_or_expr
	::= and_expr.
excl_or_expr
	::= excl_or_expr HAT and_expr.


incl_or_expr
	::= excl_or_expr.
incl_or_expr
	::= incl_or_expr BAR excl_or_expr.

log_and_expr
	::= incl_or_expr.
log_and_expr
	::= log_and_expr AND_OP incl_or_expr.

log_or_expr
	::= log_and_expr.
log_or_expr
	::= log_or_expr OR_OP log_and_expr.

cond_expr
	::= log_or_expr.
cond_expr
	::= log_or_expr QUESTION expr COLON cond_expr.

assign_expr
	::= cond_expr.
assign_expr
	::= unary_expr assign_op assign_expr.

assign_op
	::= EQUALS.
assign_op
	::= MUL_ASSIGN.
assign_op
	::= DIV_ASSIGN.
assign_op
	::= MOD_ASSIGN.
assign_op
	::= ADD_ASSIGN.
assign_op
	::= SUB_ASSIGN.
assign_op
	::= LEFT_ASSIGN.
assign_op
	::= RIGHT_ASSIGN.
assign_op
	::= AND_ASSIGN.
assign_op
	::= XOR_ASSIGN.
assign_op
	::= OR_ASSIGN.

expr
	::= assign_expr.
expr
	::= expr COMMA assign_expr.

type_name
	::= TYPE.