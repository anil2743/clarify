<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link href="https://cdn.tailwindcss.com" rel="stylesheet">
    <style>
        .container { max-width: 400px; margin: 0 auto; padding: 40px 20px; min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #e0e7ff, #f3e8ff); }
        .card { background: white; border-radius: 12px; box-shadow: 0 10px 20px rgba(0,0,0,0.15); padding: 32px; transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 12px 24px rgba(0,0,0,0.2); }
        .input { width: 100%; padding: 12px; margin-bottom: 16px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 16px; transition: border-color 0.3s ease, box-shadow 0.3s ease; }
        .input:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2); }
        .btn { width: 100%; padding: 12px; border-radius: 8px; background: #2563eb; color: white; font-weight: 600; font-size: 16px; transition: background 0.3s ease, transform 0.2s ease; }
        .btn:hover { background: #1d4ed8; transform: translateY(-2px); }
        .btn:active { transform: translateY(0); }
        .error { animation: fadeIn 0.5s ease-in; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>
<div class="container">
    <div class="card">
        <h1 class="text-3xl font-bold text-gray-900 mb-6 text-center">Welcome Back</h1>
        <form action="<%= request.getContextPath() %>/api/login" method="post">
            <input type="email" name="email" class="input" placeholder="Email" required>
            <input type="password" name="password" class="input" placeholder="Password" required>
            <button type="submit" class="btn">Login</button>
        </form>
        <% String error = (String) session.getAttribute("error"); %>
        <% if (error != null) { %>
            <p class="text-red-500 mt-4 text-center font-medium error"><%= error %></p>
            <% session.removeAttribute("error"); %>
        <% } %>
        <p class="text-gray-600 text-sm mt-4 text-center">Don't have an account? <a href="/signup" class="text-blue-600 hover:underline">Sign up</a></p>
    </div>
</div>
</body>
</html>