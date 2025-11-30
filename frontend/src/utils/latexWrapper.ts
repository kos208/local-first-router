/**
 * Automatically detect and wrap LaTeX commands in dollar signs if they're not already wrapped
 */
export function autoWrapLatex(text: string): string {
  // Common LaTeX commands that should be wrapped
  const latexCommands = [
    'frac', 'sqrt', 'int', 'sum', 'prod', 'lim', 'infty',
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'theta',
    'pi', 'sigma', 'omega', 'pm', 'times', 'div',
    'cdot', 'neq', 'leq', 'geq', 'approx', 'partial'
  ];

  let result = text;

  // Detect standalone \frac{...}{...} and similar patterns
  const fracPattern = /\\frac\{[^}]+\}\{[^}]+\}/g;
  const matches = text.match(fracPattern);
  
  if (matches) {
    matches.forEach(match => {
      // Check if it's already wrapped in $...$
      const beforeMatch = text.substring(0, text.indexOf(match));
      const afterMatch = text.substring(text.indexOf(match) + match.length);
      
      // Simple check: if there's no $ before and after, wrap it
      if (!beforeMatch.endsWith('$') && !afterMatch.startsWith('$')) {
        result = result.replace(match, `$${match}$`);
      }
    });
  }

  // Detect other LaTeX commands
  latexCommands.forEach(cmd => {
    const pattern = new RegExp(`\\\\${cmd}(?![a-zA-Z])`, 'g');
    const cmdMatches = [...result.matchAll(pattern)];
    
    cmdMatches.forEach(match => {
      const index = match.index!;
      // Find the complete expression (including braces if any)
      let endIndex = index + match[0].length;
      let braceCount = 0;
      
      // Extend to include any following braces
      while (endIndex < result.length) {
        if (result[endIndex] === '{') braceCount++;
        else if (result[endIndex] === '}') {
          braceCount--;
          endIndex++;
          if (braceCount === 0) break;
        } else if (braceCount === 0 && !/[a-zA-Z0-9_^]/.test(result[endIndex])) {
          break;
        } else {
          endIndex++;
        }
      }
      
      const expression = result.substring(index, endIndex);
      const before = result.substring(0, index);
      const after = result.substring(endIndex);
      
      // Check if not already wrapped
      if (!before.endsWith('$') && !after.startsWith('$')) {
        result = before + `$${expression}$` + after;
      }
    });
  });

  return result;
}

