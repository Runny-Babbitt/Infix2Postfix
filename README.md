# Infix2Postfix
The objective of this project is to design a digital system using Verilog that utilizes a flexible
stack to perform the conversion of Infix to Postfix expressions.

Infix notation is the conventional way of representing mathematical expressions, where
operators are placed between the operands (e.g., 3 + 4). However, infix notation can be
ambiguous and can lead to problems when evaluating expressions.
Postfix notation, also known as Reverse Polish Notation (RPN), is an alternative way of
representing mathematical expressions in which operators are placed after their operands (e.g.,
3 4 +). Postfix notation eliminates the need for parentheses and provides an unambiguous way
of evaluating expressions.

Converting an infix expression to postfix expression is a process of rearranging the operators
and operands so that the expression can be evaluated using a stack-based algorithm. The
algorithm scans the infix expression from left to right and pushes operators onto a stack until
they can be evaluated. When an operand is encountered, it is added to the output expression.
When the end of the expression is reached, any remaining operators are popped off the stack
and added to the output expression in order.

Application: Postfix notation is commonly used in computer programming, especially in
compilers and interpreters for programming languages, because it can be evaluated efficiently
using a stack-based algorithm. Postfix notation lead to faster calculations, for two reasons. The
first reason is that calculators based on postfix notation do not need expressions to be
parenthesized, so fewer operations need to be entered to perform typical calculations.
Additionally, chances of errors due to precedency of the operators is also reduced.

Infix to Postfix conversion examples:
A + B – C --> A B + C –
A + B * C --> A B C * +
(A + B) / (C – D) --> A B + C D - /
( ( A + B ) * ( C – D ) + E ) / (F + G) --> A B + C D - * E + F G + /


