import { useState, useRef, useEffect, useMemo, useCallback } from "react";
import ChatMessage from "./ChatMessage";

interface ChatProps {
  availableModels: string[];
  cloudModel: string;
  selectedModel: string;
  onModelChange: (model: string) => void;
}

interface Message {
  role: "user" | "assistant";
  content: string;
  route?: string;
  confidence?: number;
  latency_ms?: number;
  estimated_cost_saved_usd?: number;
  model?: string;
  localModel?: string | null;
}

interface ChatSession {
  id: string;
  title: string;
  messages: Message[];
  createdAt: number;
  updatedAt: number;
  selectedModel?: string;
}

const STORAGE_KEY = "lfr.sessions";
const DEFAULT_TITLE = "New chat";

const createId = () => {
  if (typeof crypto !== "undefined" && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  return Math.random().toString(36).slice(2);
};

const deriveTitle = (text: string) => {
  const trimmed = text.trim();
  if (!trimmed) return DEFAULT_TITLE;
  const singleLine = trimmed.replace(/\s+/g, " ");
  return singleLine.length > 60 ? `${singleLine.slice(0, 60)}…` : singleLine;
};

const sortSessions = (sessions: ChatSession[]) =>
  [...sessions].sort((a, b) => b.updatedAt - a.updatedAt);

const formatTimestamp = (timestamp: number) => {
  const date = new Date(timestamp);
  return date.toLocaleString();
};

export default function Chat({ availableModels, cloudModel, selectedModel, onModelChange }: ChatProps) {
  const [sessions, setSessions] = useState<ChatSession[]>([]);
  const [activeSessionId, setActiveSessionId] = useState<string | null>(null);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const modelOptions = useMemo(() => {
    const locals = availableModels ?? [];
    const options = locals.map((value) => ({
      value,
      label: `Local · ${value}`,
    }));
    if (cloudModel) {
      options.push({
        value: "cloud",
        label: `Cloud · ${cloudModel}`,
      });
    }
    return options;
  }, [availableModels, cloudModel]);

  const fallbackModel = useMemo(() => {
    if (selectedModel) return selectedModel;
    if (availableModels && availableModels.length > 0) return availableModels[0];
    if (cloudModel) return "cloud";
    return "";
  }, [availableModels, cloudModel, selectedModel]);

  const modelSelectValue = useMemo(() => {
    if (selectedModel) return selectedModel;
    if (modelOptions.find((opt) => opt.value === fallbackModel)) {
      return fallbackModel;
    }
    return modelOptions[0]?.value ?? "";
  }, [fallbackModel, modelOptions, selectedModel]);

  const persistSessions = useCallback((nextSessions: ChatSession[]) => {
    if (typeof window === "undefined") return;
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(nextSessions));
    } catch (err) {
      console.error("Failed to save sessions", err);
    }
  }, []);

  const updateSessions = useCallback(
    (updater: (prev: ChatSession[]) => ChatSession[]) => {
      setSessions((prev) => {
        const next = sortSessions(updater(prev));
        persistSessions(next);
        return next;
      });
    },
    [persistSessions]
  );

  const activeSession = useMemo(() => {
    if (!activeSessionId) return sessions[0] ?? null;
    return sessions.find((session) => session.id === activeSessionId) ?? sessions[0] ?? null;
  }, [sessions, activeSessionId]);

  const messages = activeSession?.messages ?? [];

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, activeSessionId]);

  useEffect(() => {
    if (!activeSession) return;
    if (!selectedModel) return;
    if (activeSession.selectedModel === selectedModel) return;
    updateSessions((prev) =>
      prev.map((session) =>
        session.id === activeSession.id
          ? { ...session, selectedModel }
          : session
      )
    );
  }, [activeSession, selectedModel, updateSessions]);

  const createNewSession = useCallback(() => {
    const now = Date.now();
    const newSession: ChatSession = {
      id: createId(),
      title: DEFAULT_TITLE,
      messages: [],
      createdAt: now,
      updatedAt: now,
      selectedModel: modelSelectValue,
    };
    updateSessions((prev) => [newSession, ...prev]);
    setActiveSessionId(newSession.id);
    setInput("");
    setError(null);
    return newSession;
  }, [modelSelectValue, updateSessions]);

  useEffect(() => {
    if (typeof window === "undefined") return;
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        const parsed: ChatSession[] = JSON.parse(stored);
        if (Array.isArray(parsed) && parsed.length > 0) {
          const sorted = sortSessions(parsed);
          setSessions(sorted);
          setActiveSessionId(sorted[0].id);
          persistSessions(sorted);
          if (sorted[0].selectedModel) {
            onModelChange(sorted[0].selectedModel);
          }
          return;
        }
      }
    } catch (err) {
      console.error("Failed to load stored sessions", err);
    }
    createNewSession();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (!activeSession && sessions.length > 0) {
      setActiveSessionId(sessions[0].id);
    }
  }, [activeSession, sessions]);

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      send();
    }
  };

  const updateSessionById = useCallback(
    (sessionId: string, mutator: (session: ChatSession) => ChatSession) => {
      updateSessions((prev) =>
        prev.map((session) => {
          if (session.id !== sessionId) return session;
          const updated = mutator(session);
          return {
            ...updated,
            updatedAt: Date.now(),
          };
        })
      );
    },
    [updateSessions]
  );

  useEffect(() => {
    if (!activeSession || !selectedModel) return;
    if (activeSession.selectedModel === selectedModel) return;
    updateSessionById(activeSession.id, (current) => ({
      ...current,
      selectedModel,
    }));
  }, [activeSession, selectedModel, updateSessionById]);

  const send = async () => {
    if (!input.trim() || loading) return;

    let session = activeSession;
    if (!session) {
      session = createNewSession();
    }
    if (!session) return;

    const sessionId = session.id;
    const userMessage = input.trim();
    setInput("");
    setError(null);

    const effectiveModelSelection = selectedModel || availableModels[0] || (cloudModel ? "cloud" : "");
    const isCloudSelected = effectiveModelSelection === "cloud";
    if (isCloudSelected && !cloudModel) {
      setError("Cloud model is not available. Check Anthropic configuration.");
      return;
    }
    const modelToSend = isCloudSelected ? cloudModel : effectiveModelSelection;
    if (!modelToSend) {
      setError("No model available. Add a local model or configure a cloud fallback.");
      return;
    }

    const newUserMessage: Message = { role: "user", content: userMessage };
    newUserMessage.model = isCloudSelected ? modelToSend : effectiveModelSelection;
    newUserMessage.localModel = isCloudSelected ? null : effectiveModelSelection;

    updateSessionById(sessionId, (current) => {
      const newMessages = [...current.messages, newUserMessage];
      return {
        ...current,
        messages: newMessages,
        selectedModel: isCloudSelected ? "cloud" : effectiveModelSelection,
        title: current.messages.length === 0 ? deriveTitle(userMessage) : current.title,
      };
    });

    setLoading(true);

    const timeoutId = setTimeout(() => {
      setLoading(false);
      setError(
        "Request timed out after 60 seconds. The model might be processing a complex query. Try a simpler question or check the backend logs."
      );
    }, 60000);

    try {
      const conversationHistory = [...session.messages, newUserMessage].map((m) => ({
        role: m.role,
        content: m.content,
      }));

      console.log("Sending request with", conversationHistory.length, "messages");

      const controller = new AbortController();
      const fetchTimeoutId = setTimeout(() => controller.abort(), 60000);

      const r = await fetch("/v1/chat/completions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: conversationHistory,
          model: modelToSend,
          conversation_id: sessionId,
        }),
        signal: controller.signal,
      });

      clearTimeout(fetchTimeoutId);
      clearTimeout(timeoutId);

      if (!r.ok) {
        const errorData = await r.json().catch(() => ({ detail: r.statusText }));
        setError(errorData.detail || `HTTP ${r.status}: ${r.statusText}`);
        console.error("API error:", errorData);
        return;
      }

      const data = await r.json();
      console.log("Received response:", data);

      const assistantMessage: Message = {
        role: "assistant",
        content: data.choices[0].message.content,
        route: data.route,
        confidence: data.confidence,
        latency_ms: data.latency_ms,
        estimated_cost_saved_usd: data.estimated_cost_saved_usd,
        model: data.model,
        localModel: data.local_model,
      };

      updateSessionById(sessionId, (current) => ({
        ...current,
        messages: [...current.messages, assistantMessage],
        selectedModel: isCloudSelected ? "cloud" : effectiveModelSelection,
      }));
    } catch (error: any) {
      clearTimeout(timeoutId);
      if (error.name === "AbortError") {
        setError("Request timed out. Try a shorter or simpler question.");
      } else {
        setError(`Error: ${String(error)}. Check that backend is running on port 8001.`);
      }
      console.error("Request error:", error);
    } finally {
      clearTimeout(timeoutId);
      setLoading(false);
      textareaRef.current?.focus();
    }
  };

  const clearChat = () => {
    if (!activeSession) return;
    updateSessionById(activeSession.id, (current) => ({
      ...current,
      messages: [],
      title: current.title,
    }));
    setError(null);
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  const handleSelectSession = (sessionId: string) => {
    setActiveSessionId(sessionId);
    const selectedSession = sessions.find((s) => s.id === sessionId);
    if (selectedSession?.selectedModel && selectedSession.selectedModel !== selectedModel) {
      onModelChange(selectedSession.selectedModel);
    }
    if (!selectedSession?.selectedModel && !selectedModel) {
      const fallback = availableModels[0] ?? (cloudModel ? "cloud" : "");
      if (fallback) {
        onModelChange(fallback);
      }
    }
    setInput("");
    setError(null);
  };

  const handleDeleteSession = (sessionId: string) => {
    updateSessions((prev) => {
      const filtered = prev.filter((session) => session.id !== sessionId);
      if (!filtered.length) {
        const now = Date.now();
        const newSession: ChatSession = {
          id: createId(),
          title: DEFAULT_TITLE,
          messages: [],
          createdAt: now,
          updatedAt: now,
        };
        setActiveSessionId(newSession.id);
        setInput("");
        setError(null);
        return [newSession];
      }
      if (sessionId === activeSessionId) {
        setActiveSessionId(filtered[0].id);
        setInput("");
        setError(null);
      }
      return filtered;
    });
  };

  const handleRenameSession = (sessionId: string) => {
    const session = sessions.find((s) => s.id === sessionId);
    if (!session) return;
    const newTitle = prompt("Rename chat", session.title);
    if (!newTitle) return;
    updateSessionById(sessionId, (current) => ({
      ...current,
      title: newTitle.trim() || current.title,
    }));
  };

  const sessionList = useMemo(() => sessions, [sessions]);

  const conversationTitle = activeSession?.title ?? DEFAULT_TITLE;

  return (
    <div className="flex h-full min-h-[500px]">
      {/* Session sidebar */}
      <aside className="hidden md:flex md:flex-col w-64 border-r border-gray-200 bg-white rounded-l-lg">
        <div className="p-4 border-b border-gray-200 flex items-center justify-between">
          <h2 className="text-sm font-semibold text-gray-700">Conversations</h2>
          <button
            onClick={createNewSession}
            className="text-xs px-2 py-1 rounded bg-blue-600 text-white hover:bg-blue-700"
          >
            + New Chat
          </button>
        </div>
        <div className="flex-1 overflow-y-auto">
          {sessionList.length === 0 ? (
            <div className="p-4 text-sm text-gray-500">No chats yet</div>
          ) : (
            sessionList.map((session) => (
              <div
                key={session.id}
                className={`group px-3 py-2 border-b border-gray-100 cursor-pointer hover:bg-blue-50 transition-colors ${
                  session.id === activeSession?.id ? "bg-blue-50" : "bg-white"
                }`}
                onClick={() => handleSelectSession(session.id)}
              >
                <div className="flex items-center justify-between gap-2">
                  <span className="text-sm font-medium text-gray-800 truncate" title={session.title}>
                    {session.title}
                  </span>
                  <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleRenameSession(session.id);
                      }}
                      className="text-gray-400 hover:text-gray-600 text-xs"
                      title="Rename"
                    >
                      ✎
                    </button>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDeleteSession(session.id);
                      }}
                      className="text-gray-400 hover:text-red-500 text-xs"
                      title="Delete"
                    >
                      ✕
                    </button>
                  </div>
                </div>
                <div className="text-[11px] text-gray-400 mt-1">
                  {session.messages.length} messages · {formatTimestamp(session.updatedAt)}
                </div>
              </div>
            ))
          )}
        </div>
      </aside>

      {/* Main chat area */}
      <div className="flex-1 flex flex-col bg-white rounded-r-lg shadow-lg border border-gray-200 border-l-0">
        {/* Header */}
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between p-4 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-purple-50">
          <div className="flex-1">
            <h2 className="text-xl font-bold text-gray-800 truncate" title={conversationTitle}>
              {conversationTitle}
            </h2>
            <p className="text-xs text-gray-600">Local-first routing with cost savings</p>
            <div className="md:hidden mt-2">
              <select
                value={activeSession?.id ?? ""}
                onChange={(e) => handleSelectSession(e.target.value)}
                className="w-full border border-gray-300 rounded-md text-sm p-2 text-gray-700"
              >
                {sessionList.map((session) => (
                  <option key={session.id} value={session.id}>
                    {session.title}
                  </option>
                ))}
              </select>
            </div>
          </div>
          <div className="flex flex-col sm:flex-row sm:items-center gap-3">
            {modelOptions.length > 0 && (
              <div className="flex items-center gap-2">
                <label className="text-xs text-gray-500 uppercase">Model</label>
                <select
                  value={modelSelectValue}
                  onChange={(e) => onModelChange(e.target.value)}
                  className="text-sm border border-gray-300 rounded-lg px-3 py-1.5 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  {modelOptions.map((option) => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
              </div>
            )}
            <button
              onClick={createNewSession}
              className="px-3 py-1.5 text-sm rounded-lg bg-white border border-gray-300 hover:bg-gray-50 transition-colors"
            >
              New Chat
            </button>
            {messages.length > 0 && (
              <button
                onClick={clearChat}
                className="px-3 py-1.5 text-sm rounded-lg bg-white border border-gray-300 hover:bg-gray-50 transition-colors"
              >
                Clear
              </button>
            )}
            <button
              onClick={() => copyToClipboard(messages.map((m) => `${m.role}: ${m.content}`).join("\n\n"))}
              className="px-3 py-1.5 text-sm rounded-lg bg-white border border-gray-300 hover:bg-gray-50 transition-colors"
              disabled={messages.length === 0}
            >
              Copy All
            </button>
          </div>
        </div>

        {/* Messages Area */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gradient-to-b from-gray-50 to-white">
          {messages.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-center p-8">
              <div className="text-6xl mb-4">💬</div>
              <h3 className="text-xl font-semibold text-gray-700 mb-2">Start a Conversation</h3>
              <p className="text-gray-500 mb-4 max-w-md">
                Ask anything! The router will use your local model first and fall back to cloud if needed.
              </p>
              <div className="text-sm text-gray-400 space-y-1">
                <p>
                  💡 Tip: Use <code className="bg-gray-100 px-2 py-0.5 rounded">#no_cloud</code> for private queries
                </p>
                <p>⌨️ Press Enter to send, Shift+Enter for new line</p>
              </div>
            </div>
          ) : (
            <>
              {messages.map((msg, idx) => (
                <ChatMessage
                  key={idx}
                  role={msg.role}
                  content={msg.content}
                  route={msg.route}
                  confidence={msg.confidence}
                  latency={msg.latency_ms}
                  costSaved={msg.estimated_cost_saved_usd}
                  model={msg.model}
                  localModel={msg.localModel}
                />
              ))}
              {loading && (
                <div className="flex justify-start mb-4">
                  <div className="flex items-center gap-2 bg-gray-100 rounded-2xl px-4 py-3 border border-gray-200">
                    <div className="flex gap-1">
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: "0ms" }}></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: "150ms" }}></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: "300ms" }}></div>
                    </div>
                    <span className="text-sm text-gray-600">Thinking...</span>
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </>
          )}
        </div>

        {/* Error Display */}
        {error && (
          <div className="mx-4 mb-2 p-3 rounded-lg bg-red-50 border border-red-200">
            <div className="flex items-start gap-2">
              <span className="text-red-600 text-sm">⚠️</span>
              <p className="text-red-800 text-sm flex-1">{error}</p>
              <button onClick={() => setError(null)} className="text-red-600 hover:text-red-800">
                ✕
              </button>
            </div>
          </div>
        )}

        {/* Input Area */}
        <div className="p-4 border-t border-gray-200 bg-white">
          <div className="flex gap-2">
            <textarea
              ref={textareaRef}
              className="flex-1 border border-gray-300 rounded-lg p-3 focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
              rows={2}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Type your message... (Shift+Enter for new line)"
              disabled={loading}
            />
            <button
              className="px-6 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors font-medium h-fit self-end"
              onClick={send}
              disabled={loading || !input.trim()}
            >
              {loading ? (
                <span className="flex items-center gap-2">
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  Sending
                </span>
              ) : (
                "Send"
              )}
            </button>
          </div>
          <div className="mt-2 text-xs text-gray-500 flex items-center justify-between">
            <span>{messages.length > 0 && `${messages.length} messages in conversation`}</span>
            <span>{input.length > 0 && `${input.length} characters`}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

