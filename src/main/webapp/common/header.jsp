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
        <a href="<%= ctx %>/login.jsp" class="btn-nav">Se connecter</a>
            <a href="<%=ctx%>/register.jsp" class="btn-nav"> s'inscrire</a>
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
    :root {
        --primary: #095bca;
        --secondary: #2172ac;
        --accent: #ff6b6b;
        --text-dark: #2d3436;
        --text-light: #636e72;
        --bg-light: #f9f9f9;
        --white: #ffffff;
        --shadow: 0 10px 20px rgba(0,0,0,0.08);
        --radius: 16px;
    }
    /* Styles spécifiques au Header */
    .navbar {
        background: #ffffff;
        padding: 15px 30px;
        display: flex;
        justify-content: space-between; /* Logo à gauche, boutons à droite */
        align-items: center;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        border-bottom: 4px solid var(--accent); /* Fallback color si var non définie */
        margin-bottom: 20px;
    }

    .navbar-brand {
        text-decoration: none;
        color: var(--text-dark);
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
        background-color: var(--secondary, var(--primary));
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


    /* Container (Le DIV) : Gère la bordure et masque ce qui dépasse */
    .nav-link {
        position: relative;
        display: inline-block;
        padding: 0; /* On enlève le padding ici, c'est le <a> qui le gère */
        border: 2px solid var(--secondary); /* Bordure déplacée ici */
        border-radius: 4px;
        background: transparent;
        cursor: pointer;
        overflow: hidden; /* Important pour couper l'animation */
        font-weight: 700;
        margin: 0 5px; /* Un peu d'espace entre les boutons */
    }

    /* Le Lien (Le A) : Gère le texte et la zone de clic */
    .nav-link a {
        display: block;
        padding: 0.2em 0.8em; /* Padding pour la taille du bouton */
        text-decoration: none;
        color: var(--secondary); /* Couleur initiale */
        font-size: 18px;
        position: relative;
        z-index: 2; /* Le texte doit être AU-DESSUS de l'animation */
        transition: color 0.4s;
    }

    /* L'Animation (Le balayage de fond) */
    .nav-link::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: var(--primary); /* Couleur de fond au survol */
        z-index: 1; /* En dessous du texte */

        /* Logique de l'animation Adam Giebl (adaptée) */
        transform: translate(-100%, 0) skew(-20deg);
        transform-origin: left;
        transition: all 0.4s ease;
        width: 150%; /* Plus large pour couvrir l'effet d'inclinaison */
        left: -25%;  /* Centrer l'effet */
    }

    /* État Survol */
    .nav-link:hover::before {
        transform: translate(0, 0) skew(-20deg);
    }

    .nav-link:hover a {
        color: white; /* Changement de couleur du texte */
    }

    /* État Actif (Clic) */
    .nav-link:active::before {
        background: linear-gradient(135deg, var(--primary), var(--secondary)); /* Couleur plus foncée au clic */
    }
</style>