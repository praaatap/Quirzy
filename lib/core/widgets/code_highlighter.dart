import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Code Syntax Highlighter - Displays code in quiz questions beautifully
///
/// Supports common languages: Python, JavaScript, Java, C++, Dart, SQL, etc.
/// Zero external dependencies - uses simple regex-based highlighting
class CodeHighlighter extends StatelessWidget {
  final String code;
  final String? language;
  final bool showLineNumbers;
  final double fontSize;
  final BorderRadius? borderRadius;

  const CodeHighlighter({
    super.key,
    required this.code,
    this.language,
    this.showLineNumbers = true,
    this.fontSize = 13,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    final detectedLang = language ?? _detectLanguage(code);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // VS Code dark theme
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language badge header
          if (detectedLang.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: borderRadius?.topLeft ?? const Radius.circular(12),
                  topRight: borderRadius?.topRight ?? const Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getLanguageIcon(detectedLang),
                    size: 14,
                    color: _getLanguageColor(detectedLang),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    detectedLang.toUpperCase(),
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  if (showLineNumbers)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(lines.length, (i) {
                        return SizedBox(
                          height: fontSize * 1.5,
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.firaCode(
                              fontSize: fontSize - 1,
                              color: Colors.white.withOpacity(0.3),
                              height: 1.5,
                            ),
                          ),
                        );
                      }),
                    ),

                  if (showLineNumbers)
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      height: lines.length * fontSize * 1.5,
                      color: Colors.white.withOpacity(0.1),
                    ),

                  // Highlighted code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: lines.map((line) {
                      return SizedBox(
                        height: fontSize * 1.5,
                        child: _buildHighlightedLine(line, detectedLang),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedLine(String line, String lang) {
    final spans = _highlightCode(line, lang);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.firaCode(fontSize: fontSize, height: 1.5),
        children: spans,
      ),
    );
  }

  List<TextSpan> _highlightCode(String line, String lang) {
    if (line.isEmpty) return [const TextSpan(text: ' ')];

    final spans = <TextSpan>[];
    var remaining = line;
    var index = 0;

    // Color palette (VS Code inspired)
    const keywordColor = Color(0xFFC586C0); // Purple
    const stringColor = Color(0xFFCE9178); // Orange
    const numberColor = Color(0xFFB5CEA8); // Light green
    const commentColor = Color(0xFF6A9955); // Green
    const functionColor = Color(0xFFDCDCAA); // Yellow
    const typeColor = Color(0xFF4EC9B0); // Cyan
    const operatorColor = Color(0xFFD4D4D4); // Light gray
    const defaultColor = Color(0xFFD4D4D4); // Light gray

    // Keywords by language
    final keywords = _getKeywords(lang);

    while (remaining.isNotEmpty) {
      bool matched = false;

      // Check for comments
      if (remaining.startsWith('//') || remaining.startsWith('#')) {
        spans.add(
          TextSpan(
            text: remaining,
            style: TextStyle(color: commentColor, fontStyle: FontStyle.italic),
          ),
        );
        break;
      }

      // Check for multi-line comment start
      if (remaining.startsWith('/*') ||
          remaining.startsWith('"""') ||
          remaining.startsWith("'''")) {
        spans.add(
          TextSpan(
            text: remaining,
            style: TextStyle(color: commentColor, fontStyle: FontStyle.italic),
          ),
        );
        break;
      }

      // Check for strings
      for (final quote in ['"', "'"]) {
        if (remaining.startsWith(quote)) {
          final endIndex = remaining.indexOf(quote, 1);
          if (endIndex != -1) {
            final str = remaining.substring(0, endIndex + 1);
            spans.add(
              TextSpan(
                text: str,
                style: TextStyle(color: stringColor),
              ),
            );
            remaining = remaining.substring(endIndex + 1);
            matched = true;
            break;
          }
        }
      }
      if (matched) continue;

      // Check for backtick strings (JavaScript template literals)
      if (remaining.startsWith('`')) {
        final endIndex = remaining.indexOf('`', 1);
        if (endIndex != -1) {
          final str = remaining.substring(0, endIndex + 1);
          spans.add(
            TextSpan(
              text: str,
              style: TextStyle(color: stringColor),
            ),
          );
          remaining = remaining.substring(endIndex + 1);
          continue;
        }
      }

      // Check for numbers
      final numberMatch = RegExp(r'^-?\d+\.?\d*').firstMatch(remaining);
      if (numberMatch != null &&
          (index == 0 || !RegExp(r'[a-zA-Z_]').hasMatch(line[index - 1]))) {
        spans.add(
          TextSpan(
            text: numberMatch.group(0),
            style: TextStyle(color: numberColor),
          ),
        );
        remaining = remaining.substring(numberMatch.group(0)!.length);
        index += numberMatch.group(0)!.length;
        continue;
      }

      // Check for keywords and identifiers
      final wordMatch = RegExp(
        r'^[a-zA-Z_][a-zA-Z0-9_]*',
      ).firstMatch(remaining);
      if (wordMatch != null) {
        final word = wordMatch.group(0)!;
        Color color = defaultColor;

        if (keywords.contains(word)) {
          color = keywordColor;
        } else if (_isType(word)) {
          color = typeColor;
        } else if (remaining.length > word.length &&
            remaining[word.length] == '(') {
          color = functionColor;
        }

        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(color: color),
          ),
        );
        remaining = remaining.substring(word.length);
        index += word.length;
        continue;
      }

      // Check for operators
      final operatorMatch = RegExp(
        r'^[+\-*/%=<>!&|^~?:]+',
      ).firstMatch(remaining);
      if (operatorMatch != null) {
        spans.add(
          TextSpan(
            text: operatorMatch.group(0),
            style: TextStyle(color: operatorColor),
          ),
        );
        remaining = remaining.substring(operatorMatch.group(0)!.length);
        index += operatorMatch.group(0)!.length;
        continue;
      }

      // Default: add single character
      spans.add(
        TextSpan(
          text: remaining[0],
          style: TextStyle(color: defaultColor),
        ),
      );
      remaining = remaining.substring(1);
      index++;
    }

    return spans;
  }

  Set<String> _getKeywords(String lang) {
    switch (lang.toLowerCase()) {
      case 'python':
        return {
          'def',
          'class',
          'if',
          'elif',
          'else',
          'for',
          'while',
          'return',
          'import',
          'from',
          'as',
          'try',
          'except',
          'finally',
          'with',
          'lambda',
          'in',
          'not',
          'and',
          'or',
          'True',
          'False',
          'None',
          'pass',
          'break',
          'continue',
          'yield',
          'async',
          'await',
          'raise',
          'global',
          'nonlocal',
          'assert',
          'del',
        };
      case 'javascript':
      case 'js':
      case 'typescript':
      case 'ts':
        return {
          'function',
          'const',
          'let',
          'var',
          'if',
          'else',
          'for',
          'while',
          'return',
          'import',
          'export',
          'from',
          'class',
          'extends',
          'new',
          'this',
          'super',
          'try',
          'catch',
          'finally',
          'throw',
          'async',
          'await',
          'yield',
          'true',
          'false',
          'null',
          'undefined',
          'typeof',
          'instanceof',
          'in',
          'of',
          'switch',
          'case',
          'default',
          'break',
          'continue',
          'static',
          'get',
          'set',
        };
      case 'java':
        return {
          'public',
          'private',
          'protected',
          'class',
          'interface',
          'extends',
          'implements',
          'static',
          'final',
          'void',
          'if',
          'else',
          'for',
          'while',
          'do',
          'switch',
          'case',
          'default',
          'break',
          'continue',
          'return',
          'new',
          'this',
          'super',
          'try',
          'catch',
          'finally',
          'throw',
          'throws',
          'import',
          'package',
          'true',
          'false',
          'null',
          'abstract',
          'synchronized',
          'volatile',
          'transient',
        };
      case 'dart':
        return {
          'void',
          'int',
          'double',
          'String',
          'bool',
          'dynamic',
          'var',
          'final',
          'const',
          'class',
          'abstract',
          'extends',
          'implements',
          'with',
          'mixin',
          'if',
          'else',
          'for',
          'while',
          'do',
          'switch',
          'case',
          'default',
          'break',
          'continue',
          'return',
          'async',
          'await',
          'Future',
          'Stream',
          'try',
          'catch',
          'finally',
          'throw',
          'rethrow',
          'import',
          'export',
          'library',
          'part',
          'true',
          'false',
          'null',
          'this',
          'super',
          'new',
          'static',
          'late',
          'required',
          'override',
        };
      case 'c':
      case 'cpp':
      case 'c++':
        return {
          'int',
          'char',
          'float',
          'double',
          'void',
          'short',
          'long',
          'unsigned',
          'signed',
          'if',
          'else',
          'for',
          'while',
          'do',
          'switch',
          'case',
          'default',
          'break',
          'continue',
          'return',
          'struct',
          'union',
          'enum',
          'typedef',
          'sizeof',
          'static',
          'extern',
          'const',
          'volatile',
          'register',
          'auto',
          'inline',
          'class',
          'public',
          'private',
          'protected',
          'virtual',
          'template',
          'typename',
          'namespace',
          'using',
          'new',
          'delete',
          'try',
          'catch',
          'throw',
          'true',
          'false',
        };
      case 'sql':
        return {
          'SELECT',
          'FROM',
          'WHERE',
          'AND',
          'OR',
          'NOT',
          'IN',
          'LIKE',
          'BETWEEN',
          'ORDER',
          'BY',
          'GROUP',
          'HAVING',
          'JOIN',
          'LEFT',
          'RIGHT',
          'INNER',
          'OUTER',
          'ON',
          'AS',
          'INSERT',
          'INTO',
          'VALUES',
          'UPDATE',
          'SET',
          'DELETE',
          'CREATE',
          'TABLE',
          'DROP',
          'ALTER',
          'INDEX',
          'PRIMARY',
          'KEY',
          'FOREIGN',
          'REFERENCES',
          'NULL',
          'DISTINCT',
          'COUNT',
          'SUM',
          'AVG',
          'MAX',
          'MIN',
          'LIMIT',
          'ASC',
          'DESC',
        };
      default:
        return {
          'if',
          'else',
          'for',
          'while',
          'return',
          'function',
          'class',
          'import',
          'export',
          'from',
          'const',
          'let',
          'var',
          'true',
          'false',
          'null',
        };
    }
  }

  bool _isType(String word) {
    return RegExp(r'^[A-Z][a-zA-Z0-9_]*$').hasMatch(word);
  }

  String _detectLanguage(String code) {
    final lower = code.toLowerCase();

    if (lower.contains('def ') ||
        lower.contains('import numpy') ||
        lower.contains('print(')) {
      return 'python';
    }
    if (lower.contains('function ') ||
        lower.contains('const ') ||
        lower.contains('let ') ||
        lower.contains('=>') ||
        lower.contains('console.log')) {
      return 'javascript';
    }
    if (lower.contains('public class ') ||
        lower.contains('system.out.println') ||
        lower.contains('public static void main')) {
      return 'java';
    }
    if (lower.contains('void main(') ||
        lower.contains('#include') ||
        lower.contains('std::') ||
        lower.contains('cout <<')) {
      return 'cpp';
    }
    if (lower.contains('select ') &&
        (lower.contains(' from ') || lower.contains(' where '))) {
      return 'sql';
    }
    if (lower.contains('widget') ||
        lower.contains('statelesswidget') ||
        lower.contains('build(buildcontext')) {
      return 'dart';
    }

    return '';
  }

  IconData _getLanguageIcon(String lang) {
    switch (lang.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'javascript':
      case 'js':
        return Icons.javascript;
      case 'java':
        return Icons.coffee;
      case 'dart':
        return Icons.flutter_dash;
      case 'sql':
        return Icons.storage;
      default:
        return Icons.code;
    }
  }

  Color _getLanguageColor(String lang) {
    switch (lang.toLowerCase()) {
      case 'python':
        return const Color(0xFF3776AB);
      case 'javascript':
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'java':
        return const Color(0xFFED8B00);
      case 'dart':
        return const Color(0xFF0175C2);
      case 'sql':
        return const Color(0xFF4479A1);
      default:
        return Colors.white.withOpacity(0.6);
    }
  }
}

/// Utility to detect if text contains code
class CodeDetector {
  /// Check if text likely contains code
  static bool containsCode(String text) {
    // Common code patterns
    final codePatterns = [
      RegExp(r'def \w+\('), // Python function
      RegExp(r'function \w+\('), // JavaScript function
      RegExp(r'class \w+'), // Class definition
      RegExp(r'if\s*\(.+\)\s*{'), // If statement with braces
      RegExp(r'for\s*\(.+\)\s*{'), // For loop
      RegExp(r'while\s*\(.+\)\s*{'), // While loop
      RegExp(r'\w+\s*=\s*\w+\('), // Function call assignment
      RegExp(r'import\s+\w+'), // Import statement
      RegExp(r'#include\s*<'), // C include
      RegExp(r'public\s+static'), // Java public static
      RegExp(r'SELECT\s+.+FROM', caseSensitive: false), // SQL
      RegExp(r'console\.log\('), // console.log
      RegExp(r'print\('), // print statement
      RegExp(r'=>'), // Arrow function
      RegExp(r'^\s*```'), // Markdown code block
    ];

    for (final pattern in codePatterns) {
      if (pattern.hasMatch(text)) return true;
    }

    return false;
  }

  /// Extract code from markdown code block
  static String? extractCodeFromMarkdown(String text) {
    final match = RegExp(r'```(\w+)?\n([\s\S]*?)```').firstMatch(text);
    if (match != null) {
      return match.group(2);
    }
    return null;
  }

  /// Get language from markdown code block
  static String? getLanguageFromMarkdown(String text) {
    final match = RegExp(r'```(\w+)').firstMatch(text);
    return match?.group(1);
  }
}

/// Widget that auto-detects and highlights code in text
class SmartCodeText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const SmartCodeText({super.key, required this.text, this.textStyle});

  @override
  Widget build(BuildContext context) {
    // Check for markdown code block
    final codeBlock = CodeDetector.extractCodeFromMarkdown(text);
    if (codeBlock != null) {
      final cleanedText = text
          .replaceAll(RegExp(r'```\w*\n[\s\S]*?```'), '')
          .trim();
      final lang = CodeDetector.getLanguageFromMarkdown(text);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cleanedText.isNotEmpty) ...[
            Text(cleanedText, style: textStyle),
            const SizedBox(height: 12),
          ],
          CodeHighlighter(code: codeBlock, language: lang),
        ],
      );
    }

    // Check for inline code detection
    if (CodeDetector.containsCode(text)) {
      return CodeHighlighter(code: text);
    }

    // Regular text
    return Text(text, style: textStyle);
  }
}
