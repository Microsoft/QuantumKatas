using System;
using Microsoft.Quantum.QsCompiler.SyntaxTree;
using Microsoft.Quantum.QsCompiler.SyntaxTokens;

namespace Microsoft.Quantum.Katas
{
    internal static class Extensions
    {
        internal static string? TryAsStringLiteral(this TypedExpression expression)
        {
            if (expression.Expression is QsExpressionKind<TypedExpression, Identifier, ResolvedType>.StringLiteral literal)
            {
                return literal.Item1;
            }
            else
            {
                return null;
            }
        }
    }
    
}