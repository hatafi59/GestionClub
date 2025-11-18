<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="metier.entities.Utilisateur" %>
<%@ page import="metier.entities.*" %>

<%

    String ctx = request.getContextPath();
    // Récupération des données de session
    Utilisateur userHeader = (Utilisateur) session.getAttribute("user");
    Boolean isAdminHeader = (Boolean) session.getAttribute("isAdmin");

    // Sécurité pour éviter le NullPointerException
    if (isAdminHeader == null) {
        isAdminHeader = false;
    }
    RoleClub president = (RoleClub) session.getAttribute("president");


    %>

    <nav class="navbar">

    <a href="<%= ctx %>/" class="navbar-brand">
    <h2>Gestion Clubs ENSA</h2>
    </a>

    <div class="nav-actions">

    <%-- CAS 1: L'utilisateur N'EST PAS connecté --%>
    <% if (userHeader == null) { %>

    <a href="<%= ctx %>/login.jsp" class="btn">Se connecter</a>
    <a href="<%= ctx %>/register.jsp" class="btn">S'inscrire</a>
    <%-- CAS 2: L'utilisateur EST connecté --%>
    <% } else { %>

    <span class="nav-welcome">Bonjour, <%= userHeader.getNomUtilisateur() %></span>

    <a href="<%= ctx %>/etudiant?action=monEspace" class="nav-link">Mon Espace</a>
    <a href="<%= ctx %>/etudiant?action=remainClubs" class="nav-link">clubs/evenements</a>

    <%-- CAS 2.1: L'utilisateur est un ADMIN --%>
    <% if (isAdminHeader) { // La vérification "== true" n'est pas nécessaire %>
    <a href="<%= ctx %>/admin/dashboard.jsp" class="admin-link">[Admin Panel]</a>
    <% } %>

    <%-- l'utilisateur est un president--%>
        <% if (president != null) { // La vérification "== true" n'est pas nécessaire %>
        <a href="<%= ctx %>/president?action=bureau" class="nav-link">Mon Bureau</a>
        <% } %>
    <a href="<%= ctx %>/auth?action=logout" class="btn">Déconnexion</a>

    <% } %>

    </div>
    </nav>

    <%--
      Ajoutez ces styles à votre CSS principal (ou dans la balise <style>
      de vos pages) pour que le titre cliquable et le message de
      bienvenue s'affichent correctement.
    --%>
    <style>
    .navbar-brand {
    text-decoration: none;
    color: var(--primary-color); /* Reprend votre variable de couleur */
    }
    .navbar-brand h2 {
    margin: 0;
    }
    .nav-welcome {
    font-weight: 500;
    /* Aligne le texte avec les autres boutons/liens */
    display: flex;
    align-items: center;
    }
    </style>