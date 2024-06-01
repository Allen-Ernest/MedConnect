import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route } from "react-router-dom";
import login from './pages/login';

export default function App(){
  return (
    <BrowserRouter>
    <Routes>
      <Route path='/' element={<login />}></Route>
    </Routes>
    </BrowserRouter>
  );
}
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
