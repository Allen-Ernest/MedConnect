import React from 'react';
import ReactDOM from 'react-dom/client';
import './styles.css';

function login(){
    return <div className = 'container'>
        <form method='post' action='192.168.43.107/admin-login'>
            <div className='avatar'>
                <span className='material-symbols-outlined'>person</span>
            </div>
            <div className='form-input-container'>
                <input type='text' placeholder='User Name' required></input>
                <input type='password' placeholder='Password' required></input>
            </div>
            <button type='submit'>Login</button>
            <p>Have no Account? <a href='#'>Register</a></p>
        </form>
    </div>
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<login />);