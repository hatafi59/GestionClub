<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer le message d'erreur (plus robuste que ${error} qui peut afficher "null")
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - ENSA Clubs</title>
    <style>
        /* --- Variables (Cohérence avec l'autre page) --- */
        :root {
            --primary-color: #007bff;
            --primary-hover: #0056b3;
            --danger-color: #dc3545;
            --light-bg: #f8f9fa;
            --dark-text: #333;
            --border-radius: 8px;
            --shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--light-bg);
            color: var(--dark-text);
            line-height: 1.6;
            /* Centre le conteneur verticalement et horizontalement */
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        /* --- Carte de Connexion --- */
        .login-container {
            background: #ffffff;
            width: 100%;
            max-width: 400px;
            margin: 20px;
            padding: 30px;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            text-align: center;

            /* Pour l'animation JS */
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.5s ease-out, transform 0.5s ease-out;
        }

        .login-container h2 {
            color: var(--primary-color);
            margin-bottom: 25px;
            font-size: 1.8rem;
        }

        /* --- Message d'Erreur --- */
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            padding: 12px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            font-size: 0.9rem;
            text-align: left;
        }

        /* --- AJOUT : Message de Succès (pour la cohérence) --- */
        .success-message {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            padding: 12px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            font-size: 0.9rem;
            text-align: left;
        }

        /* --- Champs de Formulaire --- */
        .form-control {
            width: 100%;
            padding: 12px;
            font-size: 1rem;
            border: 1px solid #ccc;
            border-radius: var(--border-radius);
            margin-bottom: 15px;
            /* transition pour le focus */
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,123,255,0.25);
        }

        /* --- Boutons --- */
        .btn {
            display: inline-block;
            width: 100%; /* Bouton pleine largeur */
            padding: 12px 15px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-weight: 600;
            font-size: 1rem;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }

        .btn:hover {
            background-color: var(--primary-hover);
            transform: scale(1.02);
        }

        .btn:disabled {
            background-color: #aaa;
            cursor: not-allowed;
        }

        /* --- Lien Retour --- */
        .back-link {
            display: block;
            margin-top: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.9rem;
        }

        .back-link:hover {
            text-decoration: underline;
        }

    </style>
</head>
<body>

<div class="login-container">
    <h2>Connexion</h2>

    <%
        // Affiche le bloc d'erreur seulement s'il y a une erreur
        if (error != null && !error.isEmpty()) {
    %>
    <p class="error-message"><%= error %></p>
    <%
        // CORRECTION : Utilisation de "else if" et de la classe "success-message"
    } else if (message != null && !message.isEmpty()) {
    %>
    <p class="success-message"><%= message %></p>
    <%
        }
    %>

    <form action="auth?action=login" method="post" id="login-form">
        <input type="hidden" name="action" value="login">
        <input type="email" name="email" placeholder="Email" required class="form-control">
        <input type="password" name="password" placeholder="Mot de passe" required class="form-control">
        <button type="submit" class="btn">Se connecter</button>
    </form>

    <a href="<%= request.getContextPath() %>/" class="back-link">Retour à l'accueil</a></div>

<script>
    document.addEventListener('DOMContentLoaded', () => {

        // --- 1. Animation d'apparition de la carte ---
        const loginCard = document.querySelector('.login-container');
        // Force un reflow pour s'assurer que la transition s'applique
        loginCard.getBoundingClientRect();
        loginCard.style.opacity = '1';
        loginCard.style.transform = 'translateY(0)';

        // --- 2. Feedback sur le bouton de soumission ---
        const form = document.getElementById('login-form');
        if (form) {
            form.addEventListener('submit', function() {
                const button = this.querySelector('button[type="submit"]');
                if (button) {
                    button.disabled = true;
                    button.textContent = 'Connexion...';
                }
            });
        }
    });
</script>

</body>
</html>