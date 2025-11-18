<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // --- LOGIQUE JAVA (Inchangée) ---
    Utilisateur user = (Utilisateur) session.getAttribute("user");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null) isAdmin = false;

    List<Evenement> listeEvents = (List<Evenement>) session.getAttribute("tousEvents");
    List<Club> listeClubs = (List<Club>) session.getAttribute("tousClubs");
    List<MembreClub> mesClubs = (List<MembreClub>) session.getAttribute("mesClubs");

    if (listeEvents == null) listeEvents = new ArrayList<>();
    if (listeClubs == null) listeClubs = new ArrayList<>();
    if (mesClubs == null) mesClubs = new ArrayList<>();

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy à HH:mm");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Espace Étudiant - ENSA Clubs</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* --- 1. VARIABLES (Mises à jour vers le BLEU) --- */
        :root {
            --primary: #095bca;      /* Bleu principal */
            --secondary: #2172ac;    /* Bleu secondaire */
            --accent: #ff6b6b;       /* Accent rouge/corail */
            --success: #00b894;      /* Vert succès */
            --text-dark: #2d3436;
            --text-light: #636e72;
            --bg-light: #f9f9f9;
            --white: #ffffff;
            --shadow: 0 10px 20px rgba(0,0,0,0.08);
            --radius: 16px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.6;
            padding-bottom: 50px;
        }

        /* --- HEADER & HERO --- */
        .main-header { margin-bottom: 0; }

        .hero {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: var(--white);
            padding: 30px 20px;
            text-align: center;
            border-radius: 0 0 40px 40px;
            box-shadow: var(--shadow);
            margin-bottom: 40px;
        }
        .hero h1 { font-size: 2.2rem; margin-bottom: 10px; font-weight: 600; }
        .hero p { font-size: 1.1rem; opacity: 0.9; }

        /* --- LAYOUT --- */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .section-title {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            margin-top: 30px;
        }
        .section-title h3 {
            font-size: 1.8rem;
            color: var(--text-dark);
            position: relative;
            padding-left: 15px;
        }
        .section-title h3::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            height: 30px;
            width: 5px;
            background-color: var(--accent);
            border-radius: 5px;
        }

        /* --- NAVIGATION DES ONGLETS (TABS) --- */
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

        /* GESTION DE L'AFFICHAGE DES SECTIONS */
        .content-section {
            display: none;
            animation: fadeIn 0.5s ease;
        }
        .content-section.active-section {
            display: block;
        }

        /* --- GRID SYSTEM --- */
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 30px;
        }

        /* --- CARDS DESIGN (Aligné sur Public) --- */
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
            box-shadow: 0 15px 30px rgba(9, 91, 202, 0.15);
        }

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

        .card-body {
            padding: 45px 25px 25px; /* Espace pour l'icône en haut */
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
        }

        .card-desc {
            font-size: 0.95rem;
            color: var(--text-light);
            line-height: 1.5;
            margin-bottom: 20px;
            flex-grow: 1;
            max-height: 100px;
            overflow-y: auto;
        }

        /* Date spécifique aux événements */
        .card-date {
            font-size: 0.85rem;
            color: var(--accent);
            font-weight: 600;
            margin-bottom: 15px;
            background: rgba(255, 107, 107, 0.1);
            padding: 5px 10px;
            border-radius: 20px;
            display: inline-block;
            align-self: center;
        }

        /* --- PIED DE CARTE & BOUTONS --- */
        .card-footer {
            padding-top: 15px;
            border-top: 1px solid #eee;
            margin-top: auto;
        }

        .btn {
            display: inline-block;
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            transition: all 0.3s ease;
            text-decoration: none;
            font-size: 1rem;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }
        .btn-primary:hover {
            background: var(--secondary);
            box-shadow: 0 5px 15px rgba(9, 91, 202, 0.3);
        }

        /* État désactivé pour le feedback JS */
        .btn:disabled {
            background-color: #b2bec3;
            cursor: not-allowed;
        }

        .badge-member {
            background-color: #dff9fb;
            color: var(--success);
            padding: 10px;
            border-radius: 10px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border: 1px solid #c7ecee;
        }

        /* --- ANIMATIONS --- */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .card { animation: fadeIn 0.6s ease-out forwards; }

        /* Décalage d'animation */
        .card:nth-child(1) { animation-delay: 0.1s; }
        .card:nth-child(2) { animation-delay: 0.2s; }
        .card:nth-child(3) { animation-delay: 0.3s; }

    </style>
</head>
<body>

<div class="main-header">
    <%@include file="header.jsp"%>
</div>

<div class="hero">
    <% if (user != null) { %>
    <h1>Bonjour, <%= user.getNomUtilisateur() %> !</h1>
    <p>Gérez vos clubs et découvrez les prochains événements.</p>
    <% } else { %>
    <h1>Espace Étudiant</h1>
    <p>Connectez-vous pour accéder à vos services.</p>
    <% } %>
</div>

<div class="container">

    <div class="tab-navigation">
        <button class="tab-btn active" onclick="switchTab('clubs')">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M16.604 11.048a5.67 5.67 0 0 0 .751-3.44c-.179-1.784-1.175-3.361-2.803-4.44l-1.105 1.666c1.119.742 1.8 1.799 1.918 2.974a3.693 3.693 0 0 1-1.072 2.986l-1.192 1.192 1.618.475C18.951 13.701 19 17.957 19 18h2c0-1.789-.956-5.285-4.396-6.952z"></path><path d="M9.5 12c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2zm1.5 7H8c-3.309 0-6 2.691-6 6v1h2v-1c0-2.206 1.794-4 4-4h3c2.206 0 4 1.794 4 4v1h2v-1c0-3.309-2.691-6-6-6z"></path></svg>
            Nos Clubs
        </button>
        <button class="tab-btn" onclick="switchTab('events')">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19 4h-2V2h-2v2H9V2H7v2H5c-1.103 0-2 .897-2 2v14c0 1.103.897 2 2 2h14c1.103 0 2-.897 2-2V6c0-1.103-.897-2-2-2zm.002 16H5V8h14l.002 12z"></path></svg>
            Événements
        </button>
    </div>

    <div id="section-clubs" class="content-section active-section">
        <div class="section-title">
            <h3>Liste des Clubs</h3>
        </div>
        <div class="grid-container">
            <%
                if (listeClubs != null && !listeClubs.isEmpty()) {
                    String status ="";
                    for (Club club : listeClubs) {
                        boolean estDejaMembre = false;
                        if (user != null && mesClubs != null) {
                            for (MembreClub mc : mesClubs) {
                                if (mc.getRoleClub().getClub().getClubID() == club.getClubID()) {
                                    estDejaMembre = true;
                                    status = mc.getStatut();
                                    break;
                                }
                            }
                        }
            %>
            <div class="card">
                <div class="card-header">
                    <div class="card-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><path d="M12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10-10-4.486-10-10 4.486-10 10-10zm0-2c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm-3.5 16c1.365 0 2.557-.805 3.146-1.992.604 1.207 1.812 2.026 3.22 1.992 1.841-.044 3.281-1.698 3.125-3.531-.133-1.565-1.386-2.757-2.953-2.757-.743 0-1.423.277-1.945.737v-3.449h-3.186v3.438c-.526-.453-1.205-.726-1.947-.726-1.568 0-2.819 1.193-2.953 2.759-.155 1.831 1.285 3.484 3.126 3.529h.367z"/></svg>
                    </div>
                </div>

                <div class="card-body">
                    <h4 class="card-title"><%= club.getNom() %></h4>
                    <p class="card-desc"><%= club.getDescription() %></p>

                    <div class="card-footer">
                        <% if (user == null) { %>
                        <div class="badge-login" style="color:#999; font-style:italic;">Connectez-vous pour adhérer</div>
                        <% } else if (estDejaMembre) { %>
                        <div class="badge-member">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" style="fill:var(--success)"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm-1.999 14.413-3.713-3.705L7.7 11.292l2.299 2.295 5.294-5.294 1.414 1.414-6.706 6.706z"/></svg>
                            Déjà Membre
                        </div>
                        <% } else if(!status.isEmpty()){ %>
                        <div class="badge-member" style="background-color:#fff3cd; color:#856404; border-color:#ffeeba;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" style="fill:#856404;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm.001 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
                            <%=status%>
                        </div>
                        <% } else { %>
                        <form action="etudiant?action=rejoindreClub" method="post" class="action-form">
                            <input type="hidden" name="action" value="rejoindreClub">
                            <input type="hidden" name="clubId" value="<%= club.getClubID() %>">
                            <button type="submit" class="btn btn-primary">Adhérer au club</button>
                        </form>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                }
            } else {
            %>
            <p style="grid-column: 1/-1; text-align: center; color: var(--text-light);">Aucun club disponible.</p>
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
                    <div class="card-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><path d="M19 4h-2V2h-2v2H9V2H7v2H5c-1.103 0-2 .897-2 2v14c0 1.103.897 2 2 2h14c1.103 0 2-.897 2-2V6c0-1.103-.897-2-2-2zm.002 16H5V8h14l.002 12z"></path><path d="M11 10h2v5h-2zm-4 0h2v5H7z"></path></svg>
                    </div>
                </div>

                <div class="card-body">
                    <h4 class="card-title"><%= evt.getTitre() %></h4>

                    <span class="card-date">
                        <%= (evt.getDateEvenement() != null) ? sdf.format(evt.getDateEvenement()) : "Date à venir" %>
                    </span>

                    <p class="card-desc"><%= evt.getDescription() %></p>

                    <div style="margin-top:10px; margin-bottom:20px; font-size:0.9rem; color:#888;">
                        Par : <b><%= evt.getClub().getNom() %></b>
                    </div>

                    <div class="card-footer">
                        <% if (user != null) { %>
                        <form action="etudiant" method="post" class="action-form">
                            <input type="hidden" name="action" value="participerEvent">
                            <input type="hidden" name="eventId" value="<%= evt.getEvenementID() %>">
                            <button type="submit" class="btn btn-primary">Je participe</button>
                        </form>
                        <% } else { %>
                        <div class="badge-login">Connectez-vous pour participer</div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                }
            } else {
            %>
            <p style="grid-column: 1/-1; text-align: center; color: var(--text-light);">Aucun événement prévu.</p>
            <% } %>
        </div>
    </div>

</div>

<script>
    function switchTab(tabName) {
        // Cacher toutes les sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active-section');
        });

        // Réinitialiser les boutons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // Afficher la bonne section
        const sectionToShow = document.getElementById('section-' + tabName);
        if(sectionToShow) {
            sectionToShow.classList.add('active-section');
        }

        // Activer le bouton cliqué
        event.currentTarget.classList.add('active');
    }

    document.addEventListener('DOMContentLoaded', () => {
        // Feedback sur les boutons lors du clic
        const forms = document.querySelectorAll('.action-form');
        forms.forEach(form => {
            form.addEventListener('submit', function() {
                const btn = this.querySelector('button');
                if(btn) {
                    btn.disabled = true;
                    btn.innerText = 'Traitement...';
                    btn.style.opacity = '0.7';
                }
            });
        });

        // Animation d'entrée des cartes
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