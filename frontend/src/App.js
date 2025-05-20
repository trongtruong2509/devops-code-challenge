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
        setSuccessMessage((await resp.json()).id)
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
      {failureMessage ? failureMessage : null}
      {successMessage ? successMessage : null}
    </div>
  );
}

export default App;
