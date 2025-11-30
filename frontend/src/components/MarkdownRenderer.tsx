import { useEffect, useRef } from 'react';
import katex from 'katex';
import { autoWrapLatex } from '../utils/latexWrapper';

interface MarkdownRendererProps {
  content: string;
}

export default function MarkdownRenderer({ content }: MarkdownRendererProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const processContent = () => {
      try {
        // Auto-wrap LaTeX expressions that aren't already wrapped
        let currentContent = autoWrapLatex(content);

        // First, extract and mark display math blocks $$...$$
        const displayMathRegex = /\$\$([\s\S]+?)\$\$/g;
        let match;

        // Collect all matches first
        const displayMatches: Array<{ start: number; end: number; math: string }> = [];
        while ((match = displayMathRegex.exec(currentContent)) !== null) {
          displayMatches.push({
            start: match.index,
            end: match.index + match[0].length,
            math: match[1]
          });
        }

        // Process display math
        for (let i = displayMatches.length - 1; i >= 0; i--) {
          const m = displayMatches[i];
          try {
            const rendered = katex.renderToString(m.math.trim(), {
              displayMode: true,
              throwOnError: false
            });
            const before = currentContent.substring(0, m.start);
            const after = currentContent.substring(m.end);
            currentContent = before + `<div class="katex-display my-4">${rendered}</div>` + after;
          } catch (e) {
            console.error('KaTeX error:', e);
          }
        }

        // Now handle inline math $...$
        const inlineMathRegex = /\$([^\$\n]+?)\$/g;
        const inlineMatches: Array<{ start: number; end: number; math: string }> = [];
        while ((match = inlineMathRegex.exec(currentContent)) !== null) {
          inlineMatches.push({
            start: match.index,
            end: match.index + match[0].length,
            math: match[1]
          });
        }

        for (let i = inlineMatches.length - 1; i >= 0; i--) {
          const m = inlineMatches[i];
          try {
            const rendered = katex.renderToString(m.math.trim(), {
              displayMode: false,
              throwOnError: false
            });
            const before = currentContent.substring(0, m.start);
            const after = currentContent.substring(m.end);
            currentContent = before + `<span class="inline-math">${rendered}</span>` + after;
          } catch (e) {
            console.error('KaTeX error:', e);
          }
        }

        // Handle code blocks
        currentContent = currentContent.replace(/```(\w+)?\n([\s\S]+?)```/g, (_, __, code) => {
          return `<pre class="bg-gray-800 text-gray-100 p-3 rounded-lg overflow-x-auto my-2"><code class="text-sm">${escapeHtml(code.trim())}</code></pre>`;
        });

        // Handle inline code
        currentContent = currentContent.replace(/`([^`]+)`/g, (_, code) => {
          return `<code class="bg-gray-200 text-gray-800 px-1.5 py-0.5 rounded text-sm font-mono">${escapeHtml(code)}</code>`;
        });

        // Handle bold
        currentContent = currentContent.replace(/\*\*([^\*]+?)\*\*/g, '<strong>$1</strong>');
        
        // Handle italic
        currentContent = currentContent.replace(/\*([^\*]+?)\*/g, '<em>$1</em>');

        // Handle line breaks
        currentContent = currentContent.replace(/\n/g, '<br/>');

        if (containerRef.current) {
          containerRef.current.innerHTML = currentContent;
        }
      } catch (error) {
        console.error('Error rendering content:', error);
        if (containerRef.current) {
          containerRef.current.textContent = content;
        }
      }
    };

    processContent();
  }, [content]);

  return <div ref={containerRef} className="rendered-content" />;
}

function escapeHtml(text: string): string {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

