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
    <a href="<%= ctx %>/index" class="navbar-brand">
        <h2>Gestion Clubs ENSA</h2>
    </a>

    <div class="nav-actions">

        <%-- CAS 1: L'utilisateur N'EST PAS connecté --%>
        <% if (userHeader == null) { %>
        <a href="<%= ctx %>/login.jsp" class="btn-nav">Se connecter</a>
            <a href="<%=ctx%>/register.jsp" class="btn-nav"> s'inscrire</a>
        <%-- CAS 2: L'utilisateur EST connecté --%>
        <% } else { %>

        <span class="nav-welcome">Bonjour, <%= userHeader.getNomUtilisateur() %></span>

        <a href="<%= ctx %>/etudiant" class="nav-link">Mon Espace</a>

        <% if (isAdminHeader) { %>
        <a href="<%= ctx %>/admin" class="admin-link">[Admin]</a>
        <%} else if (presidentHeader != null) { %>
        <a href="<%= ctx %>/president" class="nav-link">Mon Bureau</a>
        <% } %>
        <a href="<%= ctx %>/auth?action=logout" class="btn-nav btn-logout">Déconnexion</a>
        <% } %>
    </div>
</nav>

<style>
    /* Styles spécifiques au Header */
    .navbar {
        background: #ffffff;
        padding: 15px 30px;
        display: flex;
        justify-content: space-between; /* Logo à gauche, boutons à droite */
        align-items: center;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        border-bottom: 3px solid var(--primary-color, #007bff); /* Fallback color si var non définie */
        margin-bottom: 20px;
    }

    .navbar-brand {
        text-decoration: none;
        color: var(--primary-color, #007bff);
    }

    .navbar-brand h2 {
        margin: 0;
        font-size: 1.5rem;
    }

    .nav-actions {
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .nav-link {
        text-decoration: none;
        color: #333;
        font-weight: 500;
        transition: color 0.3s;
    }
    .nav-link:hover {
        color: var(--primary-color, #007bff);
    }

    .admin-link {
        color: #dc3545; /* Rouge danger */
        font-weight: bold;
        text-decoration: none;
    }

    .nav-welcome {
        font-weight: bold;
        color: #555;
        margin-right: 10px;
        border-right: 1px solid #ddd;
        padding-right: 15px;
    }

    /* Boutons spécifiques au header pour ne pas casser les boutons des cartes */
    .btn-nav {
        padding: 8px 15px;
        background-color: var(--primary-color, #007bff);
        color: white;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 600;
        font-size: 0.9rem;
        transition: opacity 0.3s;
    }
    .btn-nav:hover {
        opacity: 0.9;
    }
    .btn-logout {
        background-color: #6c757d; /* Gris pour logout */
    }
    .btn-logout:hover {
        background-color: #5a6268;
    }
</style>