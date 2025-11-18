<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.util.ArrayList" %>

<%
    // Récupération des objets de la session et de la requête
    Utilisateur user = (Utilisateur) session.getAttribute("user");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    // On s'assure que les listes ne sont pas nulles pour éviter les erreurs
    List<Evenement> listeEvents = (List<Evenement>) session.getAttribute("tousEvents");
    List<Club> listeClubs = (List<Club>) session.getAttribute("tousClubs");
    List<Evenement> mesEvents = (List<Evenement>) session.getAttribute("mesEvents");
    List<MembreClub> mesClubs = (List<MembreClub>) session.getAttribute("mesClubs");
    if (listeEvents == null) {
        listeEvents = new ArrayList<>();
    }
    if (listeClubs == null) {
        listeClubs = new ArrayList<>();
    }
    if (mesEvents == null) {
        mesEvents = new ArrayList<>();
    }
    if (mesClubs == null) {
        mesClubs = new ArrayList<>();
    }
    // Sécurité pour éviter le NullPointerException
    if (isAdmin == null) {
        isAdmin = false;
    }
    RoleClub president = (RoleClub) session.getAttribute("president");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ENSA Clubs</title>
    <style>
        /* --- Réinitialisation et Typographie --- */
        :root {
            --primary-color: #007bff;
            --primary-hover: #0056b3;
            --danger-color: #dc3545;
            --danger-hover: #c82333;
            --light-bg: #f8f9fa;
            --dark-text: #333;
            --border-radius: 8px;
            --shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            --shadow-hover: 0 6px 16px rgba(0, 0, 0, 0.1);
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
        }

        /* --- Barre de Navigation --- */
        .navbar {
            background: #ffffff;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow);
            border-bottom: 3px solid var(--primary-color);
        }

        .navbar h2 {
            color: var(--primary-color);
            margin: 0;
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .nav-actions span {
            font-weight: 500;
        }

        /* --- Conteneur Principal --- */
        .container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }

        /* --- Titres de Section --- */
        h3 {
            font-size: 1.8rem;
            color: var(--dark-text);
            margin-top: 30px;
            margin-bottom: 20px;
            padding-bottom: 5px;
            border-bottom: 2px solid var(--primary-color);
            display: inline-block;
        }

        /* --- Grille pour les Cartes --- */
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }


        /* --- Style des Cartes --- */
        /* From Uiverse.io by gharsh11032000 */
        .card {
            position: relative;
            width: 350px;
            height: 250px;
            background-color: #f2f2f2;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            perspective: 1000px;
            box-shadow: 0 0 0 5px #ffffff80;
            transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        .card svg {
            width: 48px;
            fill: #333;
            transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        .card:hover {
            transform: scale(1.05);
            box-shadow: 0 8px 16px rgba(255, 255, 255, 0.2);
        }

        .card__content {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            padding: 20px;
            box-sizing: border-box;
            background-color: #f2f2f2;
            transform: rotateX(-90deg);
            transform-origin: bottom;
            transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        .card:hover .card__content {
            transform: rotateX(0deg);
        }

        .card__title {
            margin: 0;
            font-size: 24px;
            color: #333;
            font-weight: 700;
        }

        .card:hover svg {
            scale: 0;
        }

        .card__description {
            margin: 10px 0 0;
            font-size: 14px;
            color: #777;
            line-height: 1.4;
        }


        /* --- Boutons --- */
        .btn {
            display: inline-block;
            padding: 10px 15px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }

        .btn:hover {
            background-color: var(--primary-hover);
            transform: scale(1.03);
        }

        .btn:disabled {
            background-color: #aaa;
            cursor: not-allowed;
        }

        /* Cibler le bouton déconnexion sans changer le HTML */
        .btn[href*="logout"] {
            background-color: var(--danger-color);
        }
        .btn[href*="logout"]:hover {
            background-color: var(--danger-hover);
        }



        /* Style pour le panel Admin */
        .admin-link {
            color: var(--danger-color);
            font-weight: bold;
            text-decoration: none;
            margin: 0 5px;
            transition: color 0.3s;
        }
        .admin-link:hover {
            color: var(--danger-hover);
        }

    </style>
</head>
<body>
<%@include file="header.jsp"%>
<div class="container">

    <h3> Événements à venir</h3>
    <div class="grid-container">
        <%
            if (listeEvents != null && !listeEvents.isEmpty()) {
                for (Evenement evt : listeEvents) {
        %>
        <div class="card">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20 5H4V19L13.2923 9.70649C13.6828 9.31595 14.3159 9.31591 14.7065 9.70641L20 15.0104V5ZM2 3.9934C2 3.44476 2.45531 3 2.9918 3H21.0082C21.556 3 22 3.44495 22 3.9934V20.0066C22 20.5552 21.5447 21 21.0082 21H2.9918C2.44405 21 2 20.5551 2 20.0066V3.9934ZM8 11C6.89543 11 6 10.1046 6 9C6 7.89543 6.89543 7 8 7C9.10457 7 10 7.89543 10 9C10 10.1046 9.10457 11 8 11Z"></path></svg>
            <div class="card__content">
                <p class="card__title"><%= evt.getTitre() %> <small>(<%= evt.getDateEvenement() %>)</small></p>
                <p class="card__description"><%= evt.getDescription() %></p>
                <p>Organisé par : <b><%= evt.getClub().getNom() %></b></p>
            </div>

            <%
                if (user != null) {
            %>
            <form action="etudiant" method="post" class="action-form">
                <input type="hidden" name="action" value="participerEvent">
                <input type="hidden" name="eventId" value="<%= evt.getEvenementID() %>">
                <button type="submit" class="btn">Je participe</button>
            </form>
            <%
                }
            %>
        </div>
        <%
            } // Fin boucle for
        } else {
        %>
        <p>Aucun événement prévu.</p>
        <%
            }
        %>
    </div>

    <h3>Nos Clubs</h3>
    <div class="grid-container">
        <%
            if (listeClubs != null && !listeClubs.isEmpty()) {
                for (Club club : listeClubs) {
        %>
        <div class="card">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20 5H4V19L13.2923 9.70649C13.6828 9.31595 14.3159 9.31591 14.7065 9.70641L20 15.0104V5ZM2 3.9934C2 3.44476 2.45531 3 2.9918 3H21.0082C21.556 3 22 3.44495 22 3.9934V20.0066C22 20.5552 21.5447 21 21.0082 21H2.9918C2.44405 21 2 20.5551 2 20.0066V3.9934ZM8 11C6.89543 11 6 10.1046 6 9C6 7.89543 6.89543 7 8 7C9.10457 7 10 7.89543 10 9C10 10.1046 9.10457 11 8 11Z"></path></svg>
            <div class="card__content">
                <p class="card__title"><%= club.getNom() %></p>
                <p class="card__description"><%= club.getDescription() %></p>
                <form action="etudiant" method="post" class="action-form">
                    <input type="hidden" name="action" value="rejoindreClub">
                    <input type="hidden" name="clubId" value="<%= club.getClubID() %>">
                    <button type="submit" class="btn">Adhérer au club</button>
                </form>
            </div>
        </div>
        <%
                } // Fin boucle for
            }
        %>
    </div>

</div> <script>
    document.addEventListener('DOMContentLoaded', () => {

        // --- 1. Feedback instantané sur les boutons ---
        // Donne à l'utilisateur un retour visuel immédiat que son clic a été pris en compte
        // pendant que le serveur traite la requête.
        const forms = document.querySelectorAll('.action-form');
        forms.forEach(form => {
            form.addEventListener('submit', function() {
                const button = this.querySelector('button[type="submit"]');
                if (button) {
                    button.disabled = true;
                    button.textContent = 'Traitement...';
                }
            });
        });

        // --- 2. Animation d'apparition des cartes ---
        // Fait apparaître les cartes en fondu avec un léger décalage
        // pour un effet plus dynamique au chargement.
        const cards = document.querySelectorAll('.card');
        cards.forEach((card, index) => {
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
                // Applique la transition APRES avoir défini l'état initial
                card.style.transition = 'opacity 0.5s ease-out, transform 0.5s ease-out';
            }, index * 100); // Décale l'animation de 100ms pour chaque carte
        });

    });
</script>

</body>
</html>