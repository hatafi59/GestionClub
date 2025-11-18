<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer les messages (plus robuste que ${error})
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - ENSA Clubs</title>
    <style>
        /* --- Variables (Cohérence avec les autres pages) --- */
        :root {
            --primary-color: #007bff;
            --success-color: #28a745;  /* Votre vert d'origine */
            --success-hover: #218838; /* Votre vert d'origine (hover) */
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
            /* Centre le conteneur */
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        /* --- Carte d'Inscription --- */
        .register-container {
            background: #ffffff;
            width: 100%;
            max-width: 420px; /* Un peu plus large pour les champs */
            padding: 30px;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            text-align: center;

            /* Pour l'animation JS */
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.5s ease-out, transform 0.5s ease-out;
        }

        .register-container h2 {
            color: var(--dark-text); /* Titre sobre */
            margin-bottom: 25px;
            font-size: 1.8rem;
        }

        /* --- Messages d'Erreur ou Succès --- */
        .message-box {
            padding: 12px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            font-size: 0.9rem;
            text-align: left;
            border: 1px solid;
        }

        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }

        .success-message {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }

        /* --- Champs de Formulaire --- */
        .form-control {
            width: 100%;
            padding: 12px;
            font-size: 1rem;
            border: 1px solid #ccc;
            border-radius: var(--border-radius);
            margin-bottom: 15px;
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
            width: 100%;
            padding: 12px 15px;
            /* CORRECTION: Utilisation de la variable de succès pour le vert */
            background-color: var(--primary-color); /* Bouton vert */
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
            /* CORRECTION: Utilisation de la variable hover */
            background-color: var(--primary-color);
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

<div class="register-container">
    <h2>Inscription</h2>

    <div id="js-error-message" class="message-box error-message" style="display: none;"></div>

    <%
        // Affiche le bloc d'erreur OU de succès venant du SERVEUR
        if (error != null && !error.isEmpty()) {
    %>
    <p class="message-box error-message"><%= error %></p>
    <%
    } else if (message != null && !message.isEmpty()) {
    %>
    <p class="message-box success-message"><%= message %></p>
    <%
        }
    %>

    <form action="auth?action=register" method="post" id="register-form">
        <input type="hidden" name="action" value="register">

        <input type="text" id="username" name="username" placeholder="Nom d'utilisateur" required class="form-control">
        <input type="email" id="email" name="email" placeholder="Email" required class="form-control">
        <input type="password" id="password" name="password" placeholder="Mot de passe" required class="form-control">
        <!-- confirmer le passwword-->
        <input type="password" id="passwordConfirm" name="passwordConfirm" placeholder="Confirmer le mot de passe" required class="form-control">
        <input type="text" id="niveauEtude" name="niveauEtude" placeholder="Niveau d'étude (CP1,CP2,CI1,CI2,CI3)" required class="form-control">

        <button type="submit" class="btn">S'inscrire</button>
    </form>

    <a href="<%= request.getContextPath() %>/" class="link">Retour à l'accueil</a>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {

        // --- 1. Animation d'apparition de la carte ---
        const registerCard = document.querySelector('.register-container');
        if(registerCard) {
            registerCard.getBoundingClientRect();
            registerCard.style.opacity = '1';
            registerCard.style.transform = 'translateY(0)';
        }

        // --- 2. Logique de validation du formulaire ---

        // Récupération des éléments du DOM
        const form = document.getElementById('register-form');
        const jsErrorBox = document.getElementById('js-error-message');
        const button = form.querySelector('button[type="submit"]');

        // Votre fonction de vérification de mot de passe (modifiée pour retourner un résultat)
        const levels = { 1: "Très Faible", 2: "Faible", 3: "Moyen", 4: "Fort" };
        function checkPasswordStrength(pwd) {
            if (pwd.length < 8) {
                return { valid: false, message: "Mot de passe trop court (8 caractères minimum)." };
            }
            if (pwd.length > 20) { // Ajoutons une limite max pour être raisonnable
                return { valid: false, message: "Mot de passe trop long (20 caractères maximum)." };
            }

            const checks = [
                /[a-z]/,        // Miniscule
                /[A-Z]/,        // Majuscule
                /\d/,           // Chiffre
                /[@.#$!%^&*.?]/ // Caractère spécial
            ];
            let score = checks.reduce((acc, rgx) => acc + rgx.test(pwd), 0);

            // On exige un score minimum (ex: 3)
            if (score < 3) {
                return { valid: false, message: `Mot de passe ${levels[score]}. Doit contenir au moins 3 types (minuscule, majuscule, chiffre, spécial).` };
            }
            return { valid: true, message: `Force: ${levels[score]}` };
        }

        // Fonction pour afficher les erreurs JS
        function showError(message) {
            jsErrorBox.textContent = message;
            jsErrorBox.style.display = 'block';

            // Masquer les erreurs du serveur s'il y en a
            const serverError = document.querySelector('.error-message:not(#js-error-message)');            if (serverError) serverError.style.display = 'none';
        }

        // Fonction pour cacher les erreurs JS
        function hideError() {
            jsErrorBox.style.display = 'none';
        }

        // Écouteur d'événement sur la soumission du formulaire
        form.addEventListener('submit', function(event) {

            // 1. Récupérer les valeurs
            const username = document.getElementById('username').value.trim();
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value.trim();
            const confirmPassword = document.getElementById('passwordConfirm').value.trim();
            const niveauEtude = document.getElementById('niveauEtude').value.trim();

            // Cacher l'erreur précédente
            hideError();

            // 2. Validation: champs vides (équivalent de estVide())
            if (!username || !email || !password || !niveauEtude || !confirmPassword) {
                event.preventDefault(); // Stoppe l'envoi du formulaire
                showError("Tous les champs sont obligatoires.");
                return; // Arrête la fonction
            }

            // 3. Validation: Format Email (RegEx JS)
            const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
            if (!emailPattern.test(email)) {
                event.preventDefault();
                showError("Format d'email invalide.");
                return;
            }
            if(password !== confirmPassword){
                event.preventDefault();
                showError("Les mots de passe ne correspondent pas.");
                return;
            }

            // 4. Validation: Niveau d'étude
            const niveauxValides = ["CP1", "CP2", "CI1", "CI2", "CI3"];
            if (!niveauxValides.includes(niveauEtude)) {
                event.preventDefault();
                showError("Le niveau d'étude doit être : CP1, CP2, CI1, CI2, ou CI3.");
                return;
            }

            // 5. Validation: Force du mot de passe
            const passwordCheck = checkPasswordStrength(password);
            if (!passwordCheck.valid) {
                event.preventDefault();
                showError(passwordCheck.message);
                return;
            }

            // --- Si tout est OK (côté client) ---
            // On ne fait PAS event.preventDefault()
            // Le formulaire va s'envoyer

            // On active le feedback visuel
            button.disabled = true;
            button.textContent = 'Inscription...';
            // Le serveur prend le relais pour la validation finale (email existe ?)
        });

    });
</script>

</body>
</html>