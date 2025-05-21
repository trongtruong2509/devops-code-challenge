import React, { useEffect, useState } from 'react'
import './App.css';
// Use window.API_URL if available (for Docker), otherwise use the imported URL
import configuredApiUrl from './config'

function App() {
  const [successMessage, setSuccessMessage] = useState()
  const [failureMessage, setFailureMessage] = useState()
  const API_URL = window.API_URL || configuredApiUrl;

  useEffect(() => {
    const getId = async () => {
      try {
        console.log(`Connecting to backend at: ${API_URL}`);
        const resp = await fetch(API_URL)
        const data = await resp.json();
        setSuccessMessage(data)
      }
      catch (e) {
        console.error("Error connecting to backend:", e);
        setFailureMessage(e.message)
      }
    }
    getId()
  }, [])

  return (
    <div className="App">
      {!failureMessage && !successMessage ? 'Fetching...' : null}
      {failureMessage ? <div className="error">{failureMessage}</div> : null}
      {successMessage ? (
        <div className="success">
          <h1>Backend Connection Status</h1>
          <p><strong>Status:</strong> {successMessage.message}</p>
          <p><strong>Backend ID:</strong> {successMessage.id}</p>
          <p><strong>Timestamp:</strong> {successMessage.timestamp}</p>
          {successMessage.serverInfo && (
            <div className="server-info">
              <h2>Server Information</h2>
              <p><strong>Port:</strong> {successMessage.serverInfo.port}</p>
              <p><strong>Environment:</strong> {successMessage.serverInfo.environment}</p>
            </div>
          )}
        </div>
      ) : null}
    </div>
  );
}

export default App;
