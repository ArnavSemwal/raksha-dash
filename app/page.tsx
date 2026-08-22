"use client";
import { useEffect, useState } from "react";

export default function Dashboard() {
  const [patients, setPatients] = useState({ vitals: [], triage_results: [] });

  // Fetch data from your deployed Render API
  const fetchData = async () => {
    try {
      // REPLACE THIS URL WITH YOUR LIVE RENDER URL
      const response = await fetch("https://raksha-api-71a6.onrender.com/patients?limit=50");
      const data = await response.json();
      setPatients(data);
    } catch (error) {
      console.error("Error fetching data:", error);
    }
  };

  // Run the fetch once when the page loads, and set an interval to auto-refresh
  useEffect(() => {
    fetchData(); // Initial fetch

    // Auto-refresh every 3 seconds to show live simulator data
    const intervalId = setInterval(fetchData, 3000);

    // Cleanup interval on unmount
    return () => clearInterval(intervalId);
  }, []);

  // Helper function to match triage data to vitals data
  const getTriageData = (patientId: string) => {
    return patients.triage_results.find((t: any) => t.patient_id === patientId);
  };

  // Helper function to apply Tailwind colors based on triage status
  const getTriageColor = (triageStatus: string) => {
    if (triageStatus === "Green") return "bg-green-200 text-green-900";
    if (triageStatus === "Yellow") return "bg-yellow-200 text-yellow-900";
    if (triageStatus === "Red") return "bg-red-200 text-red-900";
    return "bg-gray-100";
  };

  return (
    <main className="min-h-screen p-8 bg-gray-50 text-gray-900">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Raksha Live Triage Dashboard</h1>

        <div className="overflow-x-auto bg-white rounded-lg shadow">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-800 text-white">
                <th className="p-4 border-b">Patient ID</th>
                <th className="p-4 border-b">Heart Rate</th>
                <th className="p-4 border-b">SpO2 (%)</th>
                <th className="p-4 border-b">Temp (°C)</th>
                <th className="p-4 border-b">Triage Status</th>
                <th className="p-4 border-b">AI Confidence</th>
              </tr>
            </thead>
            <tbody>
              {patients.vitals.map((vital: any) => {
                const triage = getTriageData(vital.patient_id);

                return (
                  <tr key={vital.id} className="border-b hover:bg-gray-50 transition-colors">
                    <td className="p-4 font-mono font-medium">{vital.patient_id}</td>
                    <td className="p-4">{vital.ecg_hr}</td>
                    <td className="p-4">{vital.spo2_percent}</td>
                    <td className="p-4">{vital.temperature}</td>
                    {/* Color-coded triage cell */}
                    <td className={`p-4 font-bold ${getTriageColor(triage?.triage)}`}>
                      {triage?.triage || "Pending..."}
                    </td>
                    <td className="p-4">
                      {triage?.confidence ? `${(triage.confidence * 100).toFixed(1)}%` : "-"}
                    </td>
                  </tr>
                );
              })}
              {patients.vitals.length === 0 && (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-gray-500">
                    Waiting for live sensor stream...
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </main>
  );
}