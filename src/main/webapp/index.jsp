<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Récupération des données depuis la REQUÊTE (transmises par IndexServlet)
    List<Evenement> listeEvents = (List<Evenement>) request.getAttribute("tousEvents");
    List<Club> listeClubs = (List<Club>) request.getAttribute("tousClubs");

    // Sécurisation des listes
    if (listeEvents == null) listeEvents = new ArrayList<>();
    if (listeClubs == null) listeClubs = new ArrayList<>();

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy à HH:mm");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - ENSA Clubs</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* --- CHARTE GRAPHIQUE (Même que l'espace étudiant) --- */
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

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.6;
        }

        /* --- HERO SECTION (Bannière d'accueil) --- */
        .hero {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: var(--white);
            padding: 20px 10px;
            text-align: center;
            border-radius: 0 0 40px 40px;
            box-shadow: var(--shadow);
            margin-bottom: 5px;
        }

        .hero h1 {
            font-size: 2rem;
            margin-bottom: 10px;
            font-weight: 600;
        }

        .hero p {
            font-size: 1rem;
            opacity: 0.9;
            max-width: 600px;
            margin: 0 auto 30px auto;
        }



        /* --- CONTENEUR --- */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px 60px 20px;
        }

        /* --- TITRES --- */
        .section-title {
            position: relative;
            margin-bottom: 40px;
            margin-top: 20px;
        }
        .section-title h3 {
            font-size: 2rem;
            color: var(--text-dark);
            display: inline-block;
        }
        .section-title h3::after {
            content: '';
            display: block;
            width: 60px;
            height: 4px;
            background: var(--accent);
            margin-top: 8px;
            border-radius: 2px;
        }

        /* --- GRID SYSTEM --- */
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 30px;
        }

        /* --- STYLE DES CARTES --- */
        .card {
            background: var(--white);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex;
            flex-direction: column;
            border: 1px solid rgba(0,0,0,0.03);
        }

        .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(78, 84, 200, 0.15);
        }

        /* En-tête de la carte (Icone) */
        .card-header {
            height: 120px;
            background: linear-gradient(45deg, #f3f4f6, #ffffff);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .card-icon {
            font-size: 40px;
            width: 70px;
            height: 70px;
            background: var(--white);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            position: absolute;
            bottom: -35px;
            fill: var(--primary);
        }

        /* Corps de la carte */
        .card-body {
            padding: 35px 25px 15px; /* Padding top laisse place à l'icone */
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            text-align: center;
        }

        .card-title {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 10px;
            color: var(--primary);
            text-align: center;
        }



        .card-desc {
            font-size: 0.95rem;
            color: var(--text-light);
            line-height: 1.5;
            margin-bottom: 5px;
            flex-grow: 1;
            max-height: 80px; /* Limite hauteur */
            overflow-y: auto;
        }

        .event-date {
            display: block;
            text-align: center;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--accent);
            background: rgba(255, 107, 107, 0.1);
            padding: 5px 10px;
            border-radius: 20px;
            margin-bottom: 15px;
        }

        /* Pied de carte (Action) */
        .card-footer {
            padding-top: 5px;
            border-top: 1px solid #eee;
            margin-top: auto;
            text-align: center;
        }

        /* --- BADGE "VOUS DEVEZ ADHÉRER" --- */
        .badge-locked {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background-color: #f1f2f6;
            color: #636e72;
            border-radius: 50px;
            font-size: 0.9rem;
            font-weight: 600;
            border: 1px solid #dfe4ea;
            cursor: not-allowed; /* Indique qu'on ne peut pas cliquer */
        }

        .badge-locked svg {
            width: 16px;
            height: 16px;
            fill: #636e72;
        }


        /* --- Styles des Onglets (Tabs) --- */
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

        /* État actif de l'onglet */
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
        /* Pour cacher/afficher les sections */
        .content-section {
            display: none; /* Caché par défaut */
            animation: fadeIn 0.5s ease;
        }

        .content-section.active-section {
            display: block; /* Affiché si actif */
        }
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .card { animation: fadeIn 0.6s ease-out forwards; }

        /* Stagger animation delays */
        .card:nth-child(1) { animation-delay: 0.1s; }
        .card:nth-child(2) { animation-delay: 0.2s; }
        .card:nth-child(3) { animation-delay: 0.3s; }


        /* Animation d'apparition */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .card { animation: fadeInUp 0.6s ease-out forwards; }

    </style>
</head>
<body>

<%@include file="common/header.jsp"%>

<div class="hero">
    <h1>Bienvenue sur ENSA Clubs</h1>
    <p>La plateforme centrale de la vie associative étudiante. Découvrez nos clubs, nos événements et rejoignez la communauté !</p>
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
        <div class="section-title">
            <h3>Nos Clubs</h3>
        </div>
        <div class="grid-container">
        <%
            if (listeClubs != null && !listeClubs.isEmpty()) {
                for (Club club : listeClubs) {
        %>
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
                    <div class="badge-locked" title="Connectez-vous pour adhérer">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2C9.243 2 7 4.243 7 7v3H6c-1.103 0-2 .897-2 2v8c0 1.103.897 2 2 2h12c1.103 0 2-.897 2-2v-8c0-1.103-.897-2-2-2h-1V7c0-2.757-2.243-5-5-5zm6 10 .002 8H6v-8h12zm-9-2V7c0-1.654 1.346-3 3-3s3 1.346 3 3v3H9z"></path></svg>
                        Vous devez adhérer
                    </div>
                </div>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <p style="text-align:center; color: #888; grid-column: 1/-1;">Aucun club disponible pour le moment.</p>
        <% } %>
    </div>

    </div>
    <div id="section-events" class="content-section">
        <div class="section-title">
            <h3>Événements à venir</h3>
        </div>
    <div class="grid-container">
        <%
            if (listeEvents != null && !listeEvents.isEmpty()) {
                for (Evenement evt : listeEvents) {
        %>
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
                <small style="display:block; text-align:center; color:#888; margin-top:10px;">
                    Par : <b><%= evt.getClub().getNom() %></b>
                </small>

                <div class="card-footer">
                    <div class="badge-locked">
                        Connectez-vous
                    </div>
                </div>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <p style="text-align:center; color: #888; grid-column: 1/-1;">Aucun événement prévu.</p>
        <% } %>
    </div>
    </div>

</div>

<script>

    document.addEventListener('DOMContentLoaded', () => {
        const forms = document.querySelectorAll('.action-form');
        forms.forEach(form => {
            form.addEventListener('submit', function() {
                const btn = this.querySelector('button');
                if(btn) {
                    const originalText = btn.innerText;
                    btn.disabled = true;
                    btn.innerText = 'Traitement...';
                    btn.style.opacity = '0.7';
                    // Le formulaire continue sa soumission normalement
                }
            });
        });
    });
    // Fonction pour basculer entre les onglets
    function switchTab(tabName) {
        // 1. Cacher toutes les sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active-section');
        });

        // 2. Enlever la classe 'active' de tous les boutons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // 3. Afficher la section demandée
        const sectionToShow = document.getElementById('section-' + tabName);
        if(sectionToShow) {
            sectionToShow.classList.add('active-section');
        }

        // 4. Activer le bouton cliqué (l'événement click nous donne la cible)
        // On utilise event.currentTarget pour cibler le bouton même si on clique sur l'icone SVG dedans
        event.currentTarget.classList.add('active');
    }

    // Reste du script existant (animations, feedback formulaire...)
    document.addEventListener('DOMContentLoaded', () => {
        const forms = document.querySelectorAll('.action-form');
        forms.forEach(form => {
            form.addEventListener('submit', function() {
                const btn = this.querySelector('button');
                if(btn) {
                    btn.disabled = true;
                    btn.textContent = 'Traitement...';
                }
            });
        });

        // Animation des cartes
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