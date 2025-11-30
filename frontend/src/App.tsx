import { useEffect, useMemo, useState } from "react";
import Chat from "./components/Chat";
import LogsTable from "./components/Table";

type RouterConfig = {
  local_models: string[];
  default_local_model: string;
  cloud_model: string;
  confidence_threshold: number;
};

const MODEL_KEY = "lfr.selected_model";

export default function App() {
  const [activeTab, setActiveTab] = useState<"chat" | "logs">("chat");
  const [showSidebar, setShowSidebar] = useState(true);
  const [config, setConfig] = useState<RouterConfig | null>(null);
  const [configError, setConfigError] = useState<string | null>(null);
  const [selectedModel, setSelectedModel] = useState<string>("");

  useEffect(() => {
    let mounted = true;
    const loadConfig = async () => {
      try {
        const res = await fetch("/api/config");
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data: RouterConfig = await res.json();
        if (!mounted) return;
        setConfig(data);
      } catch (err) {
        if (!mounted) return;
        setConfigError(err instanceof Error ? err.message : String(err));
      }
    };
    loadConfig();
    return () => {
      mounted = false;
    };
  }, []);

  const availableModels = config?.local_models ?? [];
  const cloudModel = config?.cloud_model ?? "";

  useEffect(() => {
    if (!config) return;
    if (typeof window === "undefined") return;
    const stored = window.localStorage.getItem(MODEL_KEY);
    if (stored) {
      setSelectedModel(stored);
      return;
    }
    const fallback =
      config.default_local_model ||
      availableModels[0] ||
      (cloudModel ? "cloud" : "");
    if (fallback) {
      setSelectedModel(fallback);
      window.localStorage.setItem(MODEL_KEY, fallback);
    }
  }, [availableModels, cloudModel, config]);

  useEffect(() => {
    if (!config) return;
    if (!selectedModel) return;
    if (typeof window !== "undefined") {
      window.localStorage.setItem(MODEL_KEY, selectedModel);
    }
  }, [config, selectedModel]);

  useEffect(() => {
    if (!config) return;
    if (!selectedModel) return;
    if (selectedModel === "cloud") {
      if (!cloudModel) {
        const fallback = availableModels[0] || "";
        if (fallback && fallback !== selectedModel) {
          setSelectedModel(fallback);
        }
      }
      return;
    }
    if (!availableModels.includes(selectedModel)) {
      const fallback = availableModels[0] || (cloudModel ? "cloud" : "");
      if (fallback && fallback !== selectedModel) {
        setSelectedModel(fallback);
      }
    }
  }, [availableModels, cloudModel, config, selectedModel]);

  const effectiveSelectedModel = useMemo(() => {
    if (selectedModel) return selectedModel;
    if (config?.default_local_model) return config.default_local_model;
    if (availableModels.length > 0) return availableModels[0];
    if (cloudModel) return "cloud";
    return "";
  }, [availableModels, cloudModel, config, selectedModel]);

  const modelLabel = useMemo(() => {
    if (!config) return configError ? "Unavailable" : "Loading…";
    if (effectiveSelectedModel === "cloud") {
      return cloudModel ? `Cloud · ${cloudModel}` : "Cloud";
    }
    return effectiveSelectedModel ? `Local · ${effectiveSelectedModel}` : "Model unavailable";
  }, [cloudModel, config, configError, effectiveSelectedModel]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-purple-50 flex flex-col">
      {/* Top Navigation Bar */}
      <nav className="bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">⚡</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  Local-first Router
                </h1>
                <p className="text-xs text-gray-500">
                  AI routing with cost optimization
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-4">
              <div className="hidden md:flex items-center gap-3 text-sm">
                <div className="flex items-center gap-2 px-3 py-1.5 bg-green-50 border border-green-200 rounded-lg">
                  <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-green-700 font-medium">Online</span>
                </div>
                <div className="text-gray-500">
                  <span className="font-medium text-gray-700">Model:</span> {modelLabel}
                </div>
                {configError && (
                  <div className="text-xs text-red-600">
                    Config error: {configError}
                  </div>
                )}
              </div>
              
              <button
                onClick={() => setShowSidebar(!showSidebar)}
                className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
                title="Toggle info panel"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content Area */}
      <div className="flex-1 flex overflow-hidden">
        <div className="flex-1 flex flex-col">
          {/* Tab Navigation */}
          <div className="bg-white border-b border-gray-200">
            <div className="max-w-7xl mx-auto px-4">
              <div className="flex gap-1">
                <button
                  onClick={() => setActiveTab("chat")}
                  className={`px-6 py-3 font-medium transition-colors border-b-2 ${
                    activeTab === "chat"
                      ? "border-blue-600 text-blue-600"
                      : "border-transparent text-gray-600 hover:text-gray-900"
                  }`}
                >
                  💬 Chat
                </button>
                <button
                  onClick={() => setActiveTab("logs")}
                  className={`px-6 py-3 font-medium transition-colors border-b-2 ${
                    activeTab === "logs"
                      ? "border-blue-600 text-blue-600"
                      : "border-transparent text-gray-600 hover:text-gray-900"
                  }`}
                >
                  📊 Request Logs
                </button>
              </div>
            </div>
          </div>

          {/* Content Area */}
          <div className="flex-1 overflow-hidden">
            <div className="max-w-7xl mx-auto h-full p-4">
              {activeTab === "chat" ? (
                <div className="h-full">
                  {config ? (
                    <Chat
                      availableModels={availableModels}
                      cloudModel={cloudModel}
                      selectedModel={effectiveSelectedModel}
                      onModelChange={setSelectedModel}
                    />
                  ) : configError ? (
                    <div className="h-full flex items-center justify-center text-sm text-red-600">
                      Failed to load configuration: {configError}
                    </div>
                  ) : (
                    <div className="h-full flex items-center justify-center text-sm text-gray-500">
                      Loading configuration…
                    </div>
                  )}
                </div>
              ) : (
                <div className="h-full overflow-auto">
                  <LogsTable />
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Sidebar */}
        {showSidebar && (
          <div className="w-80 bg-white border-l border-gray-200 overflow-y-auto p-4 space-y-4 hidden lg:block">
            <div>
              <h3 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <span>🚀</span> How It Works
              </h3>
              <ul className="text-sm text-gray-600 space-y-2">
                <li className="flex items-start gap-2">
                  <span className="text-blue-500 font-bold">1.</span>
                  <span>Sends request to local model first</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-500 font-bold">2.</span>
                  <span>Local model returns answer + confidence score</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-500 font-bold">3.</span>
                  <span>If confidence {"<"} 70%, routes to cloud</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-blue-500 font-bold">4.</span>
                  <span>Logs everything with cost tracking</span>
                </li>
              </ul>
            </div>

            <div className="border-t pt-4">
              <h3 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <span>🔒</span> Privacy Features
              </h3>
              <div className="text-sm text-gray-600 space-y-2">
                <p>
                  Add <code className="bg-gray-100 px-2 py-1 rounded text-xs font-mono">#no_cloud</code> to any message to force local-only processing.
                </p>
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 mt-2">
                  <p className="text-xs text-blue-800">
                    <strong>Example:</strong><br />
                    "My password is abc123 #no_cloud"
                  </p>
                </div>
              </div>
            </div>

            <div className="border-t pt-4">
              <h3 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <span>💰</span> Cost Savings
              </h3>
              <div className="text-sm text-gray-600 space-y-2">
                <p>Every local response saves cloud API costs!</p>
                <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                  <div className="text-xs space-y-1">
                    <div className="flex justify-between">
                      <span>Cloud cost per 1K tokens:</span>
                      <span className="font-mono">$0.005</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Local cost:</span>
                      <span className="font-mono text-green-600">$0.000</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="border-t pt-4">
              <h3 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
                <span>⚡</span> Quick Tips
              </h3>
              <ul className="text-sm text-gray-600 space-y-2">
                <li className="flex items-start gap-2">
                  <span>•</span>
                  <span>Press <kbd className="px-1.5 py-0.5 bg-gray-100 rounded text-xs">Enter</kbd> to send</span>
                </li>
                <li className="flex items-start gap-2">
                  <span>•</span>
                  <span><kbd className="px-1.5 py-0.5 bg-gray-100 rounded text-xs">Shift+Enter</kbd> for new line</span>
                </li>
                <li className="flex items-start gap-2">
                  <span>•</span>
                  <span>Click "Copy All" to export conversation</span>
                </li>
                <li className="flex items-start gap-2">
                  <span>•</span>
                  <span>Check "Request Logs" tab for analytics</span>
                </li>
              </ul>
            </div>

            <div className="border-t pt-4">
              <h3 className="font-semibold text-gray-800 mb-3">⚙️ Configuration</h3>
              <div className="text-xs text-gray-500 space-y-2">
                <div className="bg-gray-50 p-2 rounded font-mono space-y-1">
                  <div>Confidence threshold: {config?.confidence_threshold ?? 0.7}</div>
                  <div>Cache TTL: 300s</div>
                  <div>Max log rows: 5000</div>
                </div>
                <div className="bg-blue-50 border border-blue-200 p-2 rounded">
                  <p className="text-blue-800 font-semibold mb-1">💡 Tip:</p>
                  <p className="text-blue-700">
                    Difficult questions may show lower confidence. The local model will still answer even if confidence is below 70%.
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="bg-white border-t border-gray-200 py-2 px-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between text-xs text-gray-500">
          <span>Local-first AI Router v0.1.0</span>
          <span>Built with FastAPI + React + Ollama</span>
        </div>
      </div>
    </div>
  );
}

