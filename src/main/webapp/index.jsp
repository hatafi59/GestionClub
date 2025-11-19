<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // --- 1. RÉCUPÉRATION DES DONNÉES (CLUBS & EVENTS) ---
    List<Evenement> listeEvents = (List<Evenement>) request.getAttribute("tousEvents");
    List<Club> listeClubs = (List<Club>) request.getAttribute("tousClubs");

    // Sécurisation pour éviter les NullPointerException
    if (listeEvents == null) listeEvents = new ArrayList<>();
    if (listeClubs == null) listeClubs = new ArrayList<>();

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy à HH:mm");

    // --- 2. GESTION DES MESSAGES D'ERREUR/SUCCÈS (Pour les Modals) ---
    // Ces attributs sont envoyés par AuthServlet en cas d'échec ou de succès
    String loginError = (String) request.getAttribute("loginError");       // Erreur Connexion
    String registerError = (String) request.getAttribute("registerError"); // Erreur Inscription
    String globalMessage = (String) request.getAttribute("message");       // Message Succès (ex: Compte créé)
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - ENSA Clubs</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* --- CHARTE GRAPHIQUE --- */
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
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--bg-light); color: var(--text-dark); line-height: 1.6; overflow-x: hidden; }

        /* --- GESTION DU FLOU ET DES MODALS --- */

        /* Conteneur principal qui sera flouté */
        #main-content { transition: filter 0.3s ease; }
        .blur-active { filter: blur(5px); pointer-events: none; user-select: none; }

        /* Overlay (Fond sombre derrière le modal) */
        .login-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-color: rgba(0, 0, 0, 0.6);
            display: flex; justify-content: center; align-items: center;
            z-index: 9999;
            opacity: 0; visibility: hidden;
            transition: opacity 0.3s ease, visibility 0.3s ease;
        }
        .login-overlay.active { opacity: 1; visibility: visible; }

        /* La Carte du Modal */
        .modal-card {
            background: #ffffff; width: 100%; max-width: 420px;
            padding: 30px; border-radius: var(--radius);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            text-align: center; position: relative;
            transform: translateY(-50px); transition: transform 0.3s ease;
            max-height: 90vh; overflow-y: auto;
        }
        .login-overlay.active .modal-card { transform: translateY(0); }

        /* Éléments du Modal */
        .modal-card h2 { color: var(--primary); margin-bottom: 20px; }
        .form-control { width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 8px; font-size: 1rem; }
        .form-control:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(9, 91, 202, 0.2); }

        .btn-full {
            width: 100%; padding: 12px; background-color: var(--primary); color: white; border: none;
            border-radius: 8px; font-weight: 600; font-size: 1rem; cursor: pointer; transition: background 0.3s;
        }
        .btn-full:hover { background-color: var(--secondary); transform: scale(1.02); }

        .close-btn {
            position: absolute; top: 15px; right: 20px; font-size: 28px; cursor: pointer; color: #aaa;
            background: none; border: none; line-height: 1;
        }
        .close-btn:hover { color: var(--text-dark); }

        .error-message { background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 8px; margin-bottom: 15px; text-align: left; font-size: 0.9rem; border: 1px solid #f5c6cb; }
        .success-message { background-color: #d4edda; color: #155724; padding: 10px; border-radius: 8px; margin-bottom: 15px; text-align: left; font-size: 0.9rem; border: 1px solid #c3e6cb; }
        .js-error { color: #dc3545; font-size: 0.85rem; text-align: left; margin-top: -10px; margin-bottom: 10px; display: none; }
        .link-switch { display:block; margin-top:20px; color: var(--primary); text-decoration:none; font-size: 0.9rem; }
        .link-switch:hover { text-decoration: underline; }

        /* --- STYLES GÉNÉRAUX (Héros, Cards, Tabs) --- */
        .hero { background: linear-gradient(135deg, var(--primary), var(--secondary)); color: var(--white); padding: 40px 20px; text-align: center; border-radius: 0 0 40px 40px; box-shadow: var(--shadow); margin-bottom: 30px; }
        .hero h1 { font-size: 2.5rem; margin-bottom: 10px; font-weight: 700; }
        .hero p { font-size: 1.1rem; opacity: 0.9; max-width: 600px; margin: 0 auto; }

        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px 60px 20px; }

        .tab-navigation {
            display: flex;
            justify-content: start;
            gap: 20px;
            margin-bottom: 40px;
            margin-top: 20px;
        }

        .tab-btn {
            padding: 8px 15px;
            background-color: white;
            color: var(--text-dark);
            text-decoration: none;
            border-radius: 4px;
            border: 2px solid var(--text-dark);
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: opacity 0.3s;
        }

        .tab-btn svg {
            width: 20px;
            height: 20px;
            fill: currentColor;
        }

        /* État Actif des Onglets */
        .tab-btn.active {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border: 2px solid var(--primary);
            color: white;
            transform: translateY(-2px);
        }

        .tab-btn:hover:not(.active) {
            background-color: #e9ecef;
            color: var(--primary);
        }

        .content-section { display: none; animation: fadeIn 0.5s ease; }
        .content-section.active-section { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .section-title { margin-bottom: 30px; border-left: 5px solid var(--accent); padding-left: 15px; }
        .section-title h3 { font-size: 1.8rem; color: var(--text-dark); margin: 0; }

        .grid-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }

        .card { background: var(--white); border-radius: var(--radius); overflow: hidden; box-shadow: var(--shadow); transition: transform 0.3s ease, box-shadow 0.3s ease; display: flex; flex-direction: column; border: 1px solid rgba(0,0,0,0.03); }
        .card:hover { transform: translateY(-10px); box-shadow: 0 15px 30px rgba(9, 91, 202, 0.15); }

        .card-header { height: 100px; background: linear-gradient(45deg, #f3f4f6, #ffffff); display: flex; align-items: center; justify-content: center; position: relative; margin-bottom: 40px; }
        .card-icon { width: 80px; height: 80px; background: var(--white); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 5px 15px rgba(0,0,0,0.05); position: absolute; bottom: -40px; fill: var(--primary); border: 4px solid white; }

        .card-body { padding: 0 25px 25px; flex-grow: 1; display: flex; flex-direction: column; text-align: center; }
        .card-title { font-size: 1.3rem; font-weight: 700; margin-bottom: 10px; color: var(--primary); }
        .card-desc { font-size: 0.95rem; color: var(--text-light); line-height: 1.5; margin-bottom: 15px; flex-grow: 1; max-height: 100px; overflow-y: auto; }

        .card-footer { margin-top: auto; padding-top: 15px; border-top: 1px solid #f0f0f0; }
        .badge-action { display: inline-block; padding: 10px 20px; background-color: #f1f2f6; color: #636e72; border-radius: 50px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: background 0.3s; border: 1px solid #e1e1e1; }
        .badge-action:hover { background-color: var(--primary); color: white; border-color: var(--primary); }
        .badge-action svg { width: 16px; height: 16px; fill: currentColor; vertical-align: middle; margin-right: 5px; }

        .event-date { display: inline-block; font-size: 0.85rem; font-weight: 600; color: var(--accent); background: rgba(255, 107, 107, 0.1); padding: 5px 15px; border-radius: 20px; margin-bottom: 15px; }
    </style>
</head>
<body>

<div id="main-content">

    <%@include file="common/header.jsp"%>

    <div class="hero">
        <h1>Bienvenue sur ENSA Clubs</h1>
        <p>La plateforme centrale de la vie associative étudiante.<br>Découvrez nos clubs, nos événements et rejoignez la communauté !</p>
    </div>

    <div class="container">
        <div class="tab-navigation">
            <button class="tab-btn active" onclick="switchTab('clubs')">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M16.604 11.048a5.67 5.67 0 0 0 .751-3.44c-.179-1.784-1.175-3.361-2.803-4.44l-1.105 1.666c1.119.742 1.8 1.799 1.918 2.974a3.693 3.693 0 0 1-1.072 2.986l-1.192 1.192 1.618.475C18.951 13.701 19 17.957 19 18h2c0-1.789-.956-5.285-4.396-6.952z"></path><path d="M9.5 12c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2zm1.5 7H8c-3.309 0-6 2.691-6 6v1h2v-1c0-2.206 1.794-4 4-4h3c2.206 0 4 1.794 4 4v1h2v-1c0-3.309-2.691-6-6-6z"></path></svg>
                Clubs
            </button>
            <button class="tab-btn" onclick="switchTab('events')">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19 4h-2V2h-2v2H9V2H7v2H5c-1.103 0-2 .897-2 2v14c0 1.103.897 2 2 2h14c1.103 0 2-.897 2-2V6c0-1.103-.897-2-2-2zm.002 16H5V8h14l.002 12z"></path></svg>
                Événements
            </button>
        </div>

        <div id="section-clubs" class="content-section active-section">
            <div class="section-title"><h3>Nos Clubs</h3></div>
            <div class="grid-container">
                <% if (listeClubs != null && !listeClubs.isEmpty()) {
                    for (Club club : listeClubs) { %>
                <div class="card">
                    <div class="card-header">
                        <div class="card-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><path d="M16.604 11.048a5.67 5.67 0 0 0 .751-3.44c-.179-1.784-1.175-3.361-2.803-4.44l-1.105 1.666c1.119.742 1.8 1.799 1.918 2.974a3.693 3.693 0 0 1-1.072 2.986l-1.192 1.192 1.618.475C18.951 13.701 19 17.957 19 18h2c0-1.789-.956-5.285-4.396-6.952z"></path><path d="M9.5 12c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2zm1.5 7H8c-3.309 0-6 2.691-6 6v1h2v-1c0-2.206 1.794-4 4-4h3c2.206 0 4 1.794 4 4v1h2v-1c0-3.309-2.691-6-6-6z"></path></svg>
                        </div>
                    </div>
                    <div class="card-body">
                        <h4 class="card-title"><%= club.getNom() %></h4>
                        <p class="card-desc"><%= club.getDescription() %></p>
                        <div class="card-footer">
                            <div class="badge-action" onclick="openLoginModal()" title="Connectez-vous pour adhérer">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2C9.243 2 7 4.243 7 7v3H6c-1.103 0-2 .897-2 2v8c0 1.103.897 2 2 2h12c1.103 0 2-.897 2-2v-8c0-1.103-.897-2-2-2h-1V7c0-2.757-2.243-5-5-5zm6 10 .002 8H6v-8h12zm-9-2V7c0-1.654 1.346-3 3-3s3 1.346 3 3v3H9z"></path></svg>
                                Adhérer
                            </div>
                        </div>
                    </div>
                </div>
                <% } } else { %>
                <p style="text-align:center; color: #888; grid-column: 1/-1;">Aucun club disponible.</p>
                <% } %>
            </div>
        </div>

        <div id="section-events" class="content-section">
            <div class="section-title"><h3>Événements à venir</h3></div>
            <div class="grid-container">
                <% if (listeEvents != null && !listeEvents.isEmpty()) {
                    for (Evenement evt : listeEvents) { %>
                <div class="card">
                    <div class="card-header">
                        <div class="card-icon" style="fill: var(--accent);">
                            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><path d="M19 4h-2V2h-2v2H9V2H7v2H5c-1.103 0-2 .897-2 2v14c0 1.103.897 2 2 2h14c1.103 0 2-.897 2-2V6c0-1.103-.897-2-2-2zm.002 16H5V8h14l.002 12z"></path><path d="M11 10h2v5h-2zm-4 0h2v5H7z"></path></svg>
                        </div>
                    </div>
                    <div class="card-body">
                        <h4 class="card-title" style="color:var(--text-dark)"><%= evt.getTitre() %></h4>
                        <span class="event-date">
                        <%= (evt.getDateEvenement() != null) ? sdf.format(evt.getDateEvenement()) : "Date à venir" %>
                    </span>
                        <p class="card-desc"><%= evt.getDescription() %></p>
                        <small style="display:block; text-align:center; color:#888; margin-top:10px; margin-bottom: 15px;">Par : <b><%= evt.getClub().getNom() %></b></small>
                        <div class="card-footer">
                            <div class="badge-action" onclick="openLoginModal()">
                                Participater
                            </div>
                        </div>
                    </div>
                </div>
                <% } } else { %>
                <p style="text-align:center; color: #888; grid-column: 1/-1;">Aucun événement prévu.</p>
                <% } %>
            </div>
        </div>

    </div>
</div> <div id="login-modal" class="login-overlay">
    <div class="modal-card">
        <button class="close-btn" onclick="closeModal('login-modal')">&times;</button>
        <h2>Connexion</h2>

        <% if (loginError != null && !loginError.isEmpty()) { %>
        <p class="error-message"><%= loginError %></p>
        <% } %>

        <form action="auth?action=login" method="post">
            <input type="hidden" name="action" value="login">
            <input type="email" name="email" placeholder="Email" required class="form-control">
            <input type="password" name="password" placeholder="Mot de passe" required class="form-control">
            <button type="submit" class="btn-full">Se connecter</button>
        </form>
        <a href="javascript:void(0)" onclick="switchToRegister()" class="link-switch">Pas encore de compte ? S'inscrire</a>
    </div>
</div>

<div id="register-modal" class="login-overlay">
    <div class="modal-card">
        <button class="close-btn" onclick="closeModal('register-modal')">&times;</button>
        <h2>Inscription</h2>

        <div id="js-error-message" class="js-error"></div>

        <% if (registerError != null && !registerError.isEmpty()) { %>
        <p class="error-message"><%= registerError %></p>
        <% } %>

        <% if (globalMessage != null && !globalMessage.isEmpty()) { %>
        <p class="success-message"><%= globalMessage %></p>
        <% } %>

        <form action="auth?action=register" method="post" id="register-form">
            <input type="hidden" name="action" value="register">
            <input type="text" id="username" name="username" placeholder="Nom d'utilisateur" required class="form-control">
            <input type="email" id="email" name="email" placeholder="prénom.nom@edu.uiz.ac.ma" required class="form-control">
            <input type="password" id="password" name="password" placeholder="Mot de passe (min 8 chars)" required class="form-control">
            <input type="password" id="passwordConfirm" name="passwordConfirm" placeholder="Confirmer le mot de passe" required class="form-control">
            <input type="text" id="niveauEtude" name="niveauEtude" placeholder="Niveau (CP1, CP2, CI1, CI2, CI3)" required class="form-control">
            <button type="submit" class="btn-full">S'inscrire</button>
        </form>
        <a href="javascript:void(0)" onclick="switchToLogin()" class="link-switch">Déjà un compte ? Se connecter</a>
    </div>
</div>


<script>
    // --- FONCTIONS MODALS ---
    function openModal(id) {
        // Fermer tout autre modal ouvert
        document.querySelectorAll('.login-overlay').forEach(el => el.classList.remove('active'));

        document.getElementById(id).classList.add('active');
        document.getElementById('main-content').classList.add('blur-active');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('active');
        // Retirer le flou seulement si aucun autre modal n'est actif
        setTimeout(() => {
            if (!document.querySelector('.login-overlay.active')) {
                document.getElementById('main-content').classList.remove('blur-active');
            }
        }, 200);
    }

    // Wrappers
    function openLoginModal() { openModal('login-modal'); }
    function openRegisterModal() { openModal('register-modal'); }
    function switchToRegister() { openRegisterModal(); }
    function switchToLogin() { openLoginModal(); }

    // Fermeture au clic en dehors du modal
    window.onclick = function(event) {
        if (event.target.classList.contains('login-overlay')) {
            closeModal(event.target.id);
        }
    }

    // --- AUTO-OUVERTURE EN CAS D'ERREUR (Feedback Serveur) ---
    <% if (loginError != null && !loginError.isEmpty()) { %>
    window.addEventListener('load', function() { openLoginModal(); });
    <% } else if (registerError != null && !registerError.isEmpty()) { %>
    window.addEventListener('load', function() { openRegisterModal(); });
    <% } else if (globalMessage != null && !globalMessage.isEmpty()) { %>
    // Si message global (ex: succès inscription), on ouvre le login
    window.addEventListener('load', function() { openLoginModal(); });
    <% } %>


    // --- VALIDATION JS FORMULAIRE INSCRIPTION ---
    document.addEventListener('DOMContentLoaded', () => {
        const form = document.getElementById('register-form');
        const errorBox = document.getElementById('js-error-message');

        if(form) {
            form.addEventListener('submit', function(event) {
                const email = document.getElementById('email').value.trim();
                const password = document.getElementById('password').value.trim();
                const confirm = document.getElementById('passwordConfirm').value.trim();
                const niveau = document.getElementById('niveauEtude').value.trim();
                let error = "";

                const emailPattern = /^[a-z]+\.[a-z]+@edu\.uiz\.ac\.ma$/;

                if (!emailPattern.test(email)) {
                    error = "Email invalide (format: prenom.nom@edu.uiz.ac.ma)";
                } else if (password.length < 8) {
                    error = "Le mot de passe doit faire au moins 8 caractères.";
                } else if (password !== confirm) {
                    error = "Les mots de passe ne correspondent pas.";
                } else if (!["CP1", "CP2", "CI1", "CI2", "CI3"].includes(niveau)) {
                    error = "Niveau invalide (CP1, CP2, CI1, CI2, CI3).";
                }

                if (error) {
                    event.preventDefault();
                    errorBox.textContent = error;
                    errorBox.style.display = 'block';
                } else {
                    errorBox.style.display = 'none';
                    const btn = form.querySelector('button');
                    btn.disabled = true;
                    btn.textContent = "Inscription...";
                }
            });
        }
    });


    // --- NAVIGATION ONGLETS ---
    function switchTab(tabName) {
        document.querySelectorAll('.content-section').forEach(s => s.classList.remove('active-section'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));

        document.getElementById('section-' + tabName).classList.add('active-section');
        event.currentTarget.classList.add('active');
    }

    // Animation Apparition Cartes
    document.addEventListener('DOMContentLoaded', () => {
        const cards = document.querySelectorAll('.card');
        cards.forEach((card, index) => {
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, index * 100);
        });
    });
</script>

</body>
</html>