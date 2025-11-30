import { useEffect, useState } from "react";

export default function LogsTable() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchLogs = async () => {
    try {
      const r = await fetch("/api/logs");
      const data = await r.json();
      setRows(data);
    } catch (error) {
      console.error("Failed to fetch logs:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
    // Refresh every 5 seconds
    const interval = setInterval(fetchLogs, 5000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return <div className="p-4">Loading logs...</div>;
  }

  return (
    <div className="p-4 border rounded-lg bg-white shadow-sm">
      <div className="flex justify-between items-center mb-3">
        <h2 className="text-lg font-semibold text-gray-800">Recent Requests</h2>
        <button
          onClick={fetchLogs}
          className="text-sm px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 transition-colors"
        >
          Refresh
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left p-2 font-medium text-gray-700">ID</th>
              <th className="text-left p-2 font-medium text-gray-700">Route</th>
              <th className="text-left p-2 font-medium text-gray-700">Conf</th>
              <th className="text-left p-2 font-medium text-gray-700">Latency</th>
              <th className="text-left p-2 font-medium text-gray-700">Cost</th>
              <th className="text-left p-2 font-medium text-gray-700">Saved</th>
              <th className="text-left p-2 font-medium text-gray-700">When</th>
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 ? (
              <tr>
                <td colSpan={7} className="text-center p-4 text-gray-500">
                  No requests yet
                </td>
              </tr>
            ) : (
              rows.map((r: any) => (
                <tr key={r.id} className="border-b hover:bg-gray-50">
                  <td className="p-2">{r.id}</td>
                  <td className="p-2">
                    <span className={`px-2 py-1 rounded text-xs ${r.route === 'local' ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'}`}>
                      {r.route}
                    </span>
                  </td>
                  <td className="p-2">{r.confidence?.toFixed(2)}</td>
                  <td className="p-2">{r.latency_ms} ms</td>
                  <td className="p-2">${r.estimated_cost_usd?.toFixed(4)}</td>
                  <td className="p-2 text-green-700">${r.estimated_cost_saved_usd?.toFixed(4)}</td>
                  <td className="p-2 text-gray-600">{new Date(r.created_at).toLocaleString()}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

