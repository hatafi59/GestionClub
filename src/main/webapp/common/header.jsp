<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="metier.entities.Utilisateur" %>
<%@ page import="metier.entities.RoleClub" %>

<%
    String ctx = request.getContextPath();
    Utilisateur userHeader = (Utilisateur) session.getAttribute("user");
    Boolean isAdminHeader = (Boolean) session.getAttribute("isAdmin");
    if (isAdminHeader == null) isAdminHeader = false;
    RoleClub presidentHeader = (RoleClub) session.getAttribute("president");
%>

<nav class="navbar">
    <% if (userHeader == null) { %>
    <a href="<%= ctx %>/" class="navbar-brand">
        <h2>ENSA Agadir</h2>
    </a>
    <% } else { %>
    <a href="<%= ctx %>/etudiant?action=home" class="navbar-brand">
        <h2>ENSA Agadir</h2>
    </a>
    <% } %>

    <div class="nav-actions">
        <%-- CAS 1: L'utilisateur N'EST PAS connecté --%>
        <% if (userHeader == null) { %>
        <a href="javascript:void(0)" onclick="openLoginModal()" class="btn-nav">Se connecter</a>
        <a href="javascript:void(0)" onclick="openRegisterModal()" class="btn-nav">S'inscrire</a>

        <%-- CAS 2: L'utilisateur EST connecté --%>
        <% } else { %>
        <div class="nav-link">
            <a href="<%= ctx %>/etudiant?action=home" >Home</a>
        </div>
        <div class="nav-link">
            <a href="<%= ctx %>/etudiant?action=monEspace">Mon Espace</a>
        </div>

        <% if (isAdminHeader) { %>
        <div class="nav-link">
            <a href="<%= ctx %>/admin">Admin Panel</a>
        </div>
        <%} else if (presidentHeader != null) { %>
        <div class="nav-link">
            <a href="<%= ctx %>/president">Mon Bureau</a>
        </div>
        <% } %>
        <a href="<%= ctx %>/auth?action=logout" class="btn-nav btn-logout">Déconnexion</a>
        <% } %>
    </div>
</nav>

<style>
    /* ... (Même style CSS que dans votre fichier précédent) ... */
    :root {
        --primary: #095bca;
        --secondary: #2172ac;
        --accent: #ff6b6b;
        --text-dark: #2d3436;
        --bg-light: #f9f9f9;
        --white: #ffffff;
        --shadow: 0 10px 20px rgba(0,0,0,0.08);
        --radius: 16px;
    }
    .navbar {
        background: #ffffff;
        padding: 15px 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        border-bottom: 4px solid var(--accent);
        margin-bottom: 20px;
        position: relative;
        z-index: 10;
    }
    .navbar-brand { text-decoration: none; color: var(--text-dark); }
    .navbar-brand h2 { margin: 0; font-size: 1.5rem; }
    .nav-actions { display: flex; align-items: center; gap: 15px; }
    .btn-nav {
        padding: 8px 15px;
        background-color: var(--secondary, var(--primary));
        color: white;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 600;
        font-size: 0.9rem;
        transition: opacity 0.3s;
        cursor: pointer;
    }
    .btn-nav:hover { opacity: 0.9; }
    .btn-logout { background-color: #6c757d; }
    .btn-logout:hover { background-color: #5a6268; }
    .nav-link {
        position: relative; display: inline-block; padding: 0;
        border: 2px solid var(--secondary); border-radius: 4px;
        background: transparent; cursor: pointer; overflow: hidden;
        font-weight: 700; margin: 0 5px;
    }
    .nav-link a {
        display: block; padding: 0.2em 0.8em; text-decoration: none;
        color: var(--secondary); font-size: 18px; position: relative; z-index: 2;
        transition: color 0.4s;
    }
    .nav-link::before {
        content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
        background: var(--primary); z-index: 1;
        transform: translate(-100%, 0) skew(-20deg); transform-origin: left;
        transition: all 0.4s ease; width: 150%; left: -25%;
    }
    .nav-link:hover::before { transform: translate(0, 0) skew(-20deg); }
    .nav-link:hover a { color: white; }
    .nav-link:active::before { background: linear-gradient(135deg, var(--primary), var(--secondary)); }
</style>