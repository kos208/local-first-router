import MarkdownRenderer from "./MarkdownRenderer";

interface ChatMessageProps {
  role: "user" | "assistant";
  content: string;
  route?: string;
  confidence?: number;
  latency?: number;
  costSaved?: number;
  model?: string;
  localModel?: string | null;
}

export default function ChatMessage({ role, content, route, confidence, latency, costSaved, model, localModel }: ChatMessageProps) {
  const isUser = role === "user";
  const modelBadge =
    model && !isUser
      ? route === "cloud"
        ? `Cloud · ${model}`
        : `Local · ${model}`
      : null;
  const attemptedLocalBadge = !isUser && route === "cloud" && localModel ? `Tried local · ${localModel}` : null;
  
  return (
    <div className={`flex ${isUser ? "justify-end" : "justify-start"} mb-4`}>
      <div className={`max-w-[80%] ${isUser ? "order-2" : "order-1"}`}>
        <div
          className={`rounded-2xl px-4 py-3 ${
            isUser
              ? "bg-blue-600 text-white"
              : "bg-gray-100 text-gray-900 border border-gray-200"
          }`}
        >
          {isUser ? (
            <div className="whitespace-pre-wrap break-words">{content}</div>
          ) : (
            <MarkdownRenderer content={content} />
          )}
        </div>
        
        {!isUser && route && (
          <div className="space-y-1">
            <div className="flex gap-2 mt-2 text-xs flex-wrap">
              {modelBadge && (
                <span className="px-2 py-1 rounded bg-gray-100 text-gray-600">
                  {modelBadge}
                </span>
              )}
              <span className={`px-2 py-1 rounded ${route === 'local' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'}`}>
                {route}
              </span>
              {confidence !== undefined && (
                <span className={`px-2 py-1 rounded ${
                  confidence >= 0.7 
                    ? 'bg-gray-100 text-gray-600' 
                    : 'bg-orange-100 text-orange-700'
                }`}>
                  {(confidence * 100).toFixed(0)}% confident
                </span>
              )}
              {latency !== undefined && (
                <span className="px-2 py-1 rounded bg-gray-100 text-gray-600">
                  {latency}ms
                </span>
              )}
              {costSaved !== undefined && costSaved > 0 && (
                <span className="px-2 py-1 rounded bg-yellow-100 text-yellow-700">
                  💰 ${costSaved.toFixed(4)} saved
                </span>
              )}
              {attemptedLocalBadge && (
                <span className="px-2 py-1 rounded bg-purple-100 text-purple-700">
                  {attemptedLocalBadge}
                </span>
              )}
            </div>
            {confidence !== undefined && confidence < 0.7 && (
              <div className="text-xs text-orange-600 italic">
                ⚠️ Lower confidence - answer may be less reliable
              </div>
            )}
          </div>
        )}
      </div>
      
      <div className={`flex-shrink-0 ${isUser ? "order-1 mr-3" : "order-2 ml-3"}`}>
        <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
          isUser ? "bg-blue-600 text-white" : "bg-gray-300 text-gray-700"
        }`}>
          {isUser ? "U" : "AI"}
        </div>
      </div>
    </div>
  );
}

