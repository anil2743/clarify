<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link href="https://cdn.tailwindcss.com" rel="stylesheet">
    <style>
        :root {
            --bg-light: linear-gradient(135deg, #e0e7ff, #f3e8ff);
            --bg-dark: linear-gradient(135deg, #1e293b, #3b0764);
            --card-light: rgba(255, 255, 255, 0.8);
            --card-dark: rgba(31, 41, 55, 0.8);
            --text-light: #1f2937;
            --text-dark: #e5e7eb;
        }
        [data-theme="dark"] {
            --bg: var(--bg-dark);
            --card-bg: var(--card-dark);
            --text: var(--text-dark);
        }
        [data-theme="light"] {
            --bg: var(--bg-light);
            --card-bg: var(--card-light);
            --text: var(--text-light);
        }
        body {
            background: var(--bg);
            color: var(--text);
            transition: background 0.5s ease, color 0.5s ease;
        }
        .container {
            max-width: 400px;
            margin: 0 auto;
            padding: 40px 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            padding: 40px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.3);
        }
        .input {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid rgba(209, 213, 219, 0.5);
            border-radius: 8px;
            font-size: 16px;
            background: rgba(255, 255, 255, 0.1);
            color: var(--text);
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
        }
        .btn {
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            background: linear-gradient(90deg, #2563eb, #7c3aed);
            color: white;
            font-weight: 600;
            font-size: 16px;
            position: relative;
            overflow: hidden;
            transition: transform 0.2s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
        .btn:active {
            transform: translateY(0);
        }
        .btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.6s ease, height 0.6s ease;
        }
        .btn:active::before {
            width: 200px;
            height: 200px;
        }
        .error {
            animation: fadeIn 0.5s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .theme-toggle {
            position: absolute;
            top: 16px;
            right: 16px;
            cursor: pointer;
            font-size: 20px;
        }
    </style>
</head>
<body data-theme="light">
<div class="container">
    <div class="card">
        <span class="theme-toggle" onclick="toggleTheme()">🌙</span>
        <h1 class="text-3xl font-bold mb-8 text-center">Welcome Back</h1>
        <form action="<%= request.getContextPath() %>/api/login" method="post">
            <input type="email" name="email" class="input" placeholder="Email" required aria-label="Email">
            <input type="password" name="password" class="input" placeholder="Password" required aria-label="Password">
            <button type="submit" class="btn">Login</button>
        </form>
        <% String error = (String) session.getAttribute("error"); %>
        <% if (error != null) { %>
            <p class="text-red-500 mt-4 text-center font-medium error"><%= error %></p>
            <% session.removeAttribute("error"); %>
        <% } %>
        <p class="text-sm mt-6 text-center">Don't have an account? <a href="/signup" class="text-blue-500 hover:underline">Sign up</a></p>
    </div>
</div>
<script>
    function toggleTheme() {
        const body = document.body;
        const currentTheme = body.getAttribute('data-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        body.setAttribute('data-theme', newTheme);
        document.querySelector('.theme-toggle').textContent = newTheme === 'light' ? '🌙' : '☀️';
    }
</script>
</body>
</html>