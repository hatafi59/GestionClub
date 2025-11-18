<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    List<Evenement> listeEvents = (List<Evenement>) request.getAttribute("tousEvents");
    List<Club> listeClubs = (List<Club>) request.getAttribute("tousClubs");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - ENSA Clubs</title>
    <style>
        /* --- Variables Globales --- */
        :root {
            --primary-color: #007bff;
            --primary-hover: #0056b3;
            --light-bg: #f8f9fa;
            --dark-text: #333;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: system-ui, -apple-system, sans-serif;
            background-color: var(--light-bg);
            color: var(--dark-text);
        }

        /* Conteneur */
        .container {
            max-width: 1200px;
            margin: 0 auto 40px auto; /* Margin top 0 car le header a son propre margin-bottom */
            padding: 0 20px;
        }

        h3 {
            font-size: 1.8rem;
            margin: 30px 0 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid var(--primary-color);
            display: inline-block;
        }

        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            justify-items: center;
        }

        /* --- Style des Cartes --- */
        .card {
            position: relative;
            width: 320px;
            height: 250px;
            background-color: #ffffff;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        .card svg {
            width: 64px;
            fill: #333;
            transition: all 0.4s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.15);
        }

        .card__content {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            padding: 20px;
            box-sizing: border-box;
            background-color: #ffffff;
            transform: rotateX(-90deg);
            transform-origin: bottom;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .card:hover .card__content {
            transform: rotateX(0deg);
        }

        .card:hover svg { opacity: 0; transform: scale(0); }

        .card__title {
            font-size: 20px;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 5px;
        }

        .card__description {
            font-size: 14px;
            color: #666;
            flex-grow: 1;
            overflow-y: auto;
        }

        .card__info {
            font-size: 12px;
            color: #888;
            margin: 10px 0;
            font-style: italic;
        }

    </style>
</head>
<body>

<%@include file="common/header.jsp"%>

<div class="container">

    <h3>Nos Clubs</h3>
    <div class="grid-container">
        <%
            if (listeClubs != null && !listeClubs.isEmpty()) {
                for (Club club : listeClubs) {
        %>
        <div class="card">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/></svg>
            <div class="card__content">
                <div>
                    <p class="card__title"><%= club.getNom() %></p>
                    <p class="card__description"><%= club.getDescription() %></p>
                </div>
                <p style="font-size:0.8rem; text-align:center; color:#888;">
                    <i>Connectez-vous pour adhérer</i>
                </p>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <p>Aucun club disponible.</p>
        <% } %>
    </div>
    <h3>Événements à venir</h3>
    <div class="grid-container">
        <%
            if (listeEvents != null && !listeEvents.isEmpty()) {
                for (Evenement evt : listeEvents) {
        %>
        <div class="card">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20 5H4V19L13.2923 9.70649C13.6828 9.31595 14.3159 9.31591 14.7065 9.70641L20 15.0104V5ZM2 3.9934C2 3.44476 2.45531 3 2.9918 3H21.0082C21.556 3 22 3.44495 22 3.9934V20.0066C22 20.5552 21.5447 21 21.0082 21H2.9918C2.44405 21 2 20.5551 2 20.0066V3.9934ZM8 11C6.89543 11 6 10.1046 6 9C6 7.89543 6.89543 7 8 7C9.10457 7 10 7.89543 10 9C10 10.1046 9.10457 11 8 11Z"></path></svg>
            <div class="card__content">
                <div>
                    <p class="card__title"><%= evt.getTitre() %></p>
                    <p class="card__info">
                        <%= (evt.getDateEvenement() != null) ? sdf.format(evt.getDateEvenement()) : "Date à confirmer" %> <br>
                        Par : <b><%= evt.getClub().getNom() %></b>
                    </p>
                    <p class="card__description"><%= evt.getDescription() %></p>
                </div>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <p>Aucun événement prévu.</p>
        <% } %>
    </div>

</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const cards = document.querySelectorAll('.card');
        cards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
                card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                setTimeout(() => {
                    card.style.transition = 'all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
                }, 600);
            }, index * 100);
        });
    });
</script>
</body>
</html>