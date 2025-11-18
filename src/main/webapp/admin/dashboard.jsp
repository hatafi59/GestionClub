<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Récupération des données envoyées par le Controller
    List<MembreClub> demandes = (List<MembreClub>) request.getAttribute("demandesEnAttente");
    List<MembreClub> actifs = (List<MembreClub>) request.getAttribute("membresActifs");
    List<Evenement> events = (List<Evenement>) request.getAttribute("eventsClub");
    Club monClub = (Club) request.getAttribute("monClub");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Bureau du Président - <%= monClub.getNom() %></title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        /* --- THÈME PRÉSIDENT (Violet/Gold) --- */
        :root {
            --p-primary: #6c5ce7;
            --p-dark: #2d3436;
            --p-light: #f9f9f9;
            --p-gold: #fdcb6e;
            --p-danger: #ff7675;
            --p-success: #00b894;
        }

        body { font-family: 'Poppins', sans-serif; background: var(--p-light); margin: 0; color: var(--p-dark); }

        .hero-pres {
            background: linear-gradient(135deg, var(--p-primary), #a29bfe);
            color: white; padding: 40px 20px; text-align: center;
            border-radius: 0 0 40px 40px; margin-bottom: 40px;
        }

        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px 50px; }

        /* Alertes */
        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; background: white; border-left: 5px solid var(--p-success); box-shadow: 0 2px 10px rgba(0,0,0,0.05); }

        /* Onglets */
        .tabs { display: flex; justify-content: center; gap: 15px; margin-bottom: 30px; }
        .tab-btn {
            padding: 12px 25px; border: none; background: white; border-radius: 30px;
            font-weight: 600; cursor: pointer; transition: 0.3s;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        .tab-btn.active { background: var(--p-primary); color: white; transform: translateY(-3px); }

        .section { display: none; animation: fadeIn 0.5s; }
        .section.active { display: block; }
        @keyframes fadeIn { from{opacity:0; transform:translateY(10px)} to{opacity:1; transform:translateY(0)} }

        /* Tables */
        .admin-table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .admin-table th { background: var(--p-primary); color: white; padding: 15px; text-align: left; }
        .admin-table td { padding: 15px; border-bottom: 1px solid #eee; }

        /* Boutons Actions */
        .btn-action { padding: 6px 12px; border-radius: 5px; text-decoration: none; border: none; cursor: pointer; font-size: 0.9em; color: white; display: inline-block;}
        .btn-accept { background: var(--p-success); }
        .btn-refuse { background: var(--p-danger); }

        /* Cartes Event */
        .event-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); position: relative; border-left: 5px solid var(--p-gold); }
        .delete-icon { position: absolute; top: 15px; right: 15px; color: var(--p-danger); cursor: pointer; background: none; border: none; font-size: 1.2rem;}

        /* Formulaire Création */
        .create-box { background: white; padding: 25px; border-radius: 10px; margin-bottom: 30px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        .btn-create { background: var(--p-primary); color: white; width: 100%; padding: 12px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }

    </style>
</head>
<body>

<jsp:include page="/common/header.jsp" />

<div class="hero-pres">
    <h1>Bureau du Président</h1>
    <p>Administration du <strong><%= monClub.getNom() %></strong></p>
</div>

<div class="container">

    <% if (msg != null) { %>
    <div class="alert">Notification : Opération effectuée avec succès.</div>
    <% } %>

    <div class="tabs">
        <button class="tab-btn active" onclick="showTab('membres')">Gestion Membres</button>
        <button class="tab-btn" onclick="showTab('events')">Gestion Événements</button>
    </div>

    <div id="membres" class="section active">

        <h3 style="color: var(--p-primary);">Demandes d'adhésion (<%= demandes != null ? demandes.size() : 0 %>)</h3>
        <% if (demandes != null && !demandes.isEmpty()) { %>
        <table class="admin-table">
            <thead><tr><th>Étudiant</th><th>Date demande</th><th>Email</th><th>Actions</th></tr></thead>
            <tbody>
            <% for (MembreClub m : demandes) { %>
            <tr>
                <td><%= m.getUtilisateur().getNomUtilisateur() %></td>
                <td><%= m.getDateDemande() %></td>
                <td><%= m.getUtilisateur().getEmail() %></td>
                <td>
                    <form action="${pageContext.request.contextPath}/president" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="accepterMembre">
                        <input type="hidden" name="membreId" value="<%= m.getId() %>">
                        <button class="btn-action btn-accept">Accepter</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/president" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="refuserMembre">
                        <input type="hidden" name="membreId" value="<%= m.getId() %>">
                        <button class="btn-action btn-refuse">Refuser</button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %> <p>Aucune demande en attente.</p> <% } %>

        <h3 style="margin-top: 40px;">Membres Actifs</h3>
        <table class="admin-table">
            <thead><tr><th>Nom</th><th>Email</th><th>Rôle</th><th>Action</th></tr></thead>
            <tbody>
            <% if (actifs != null) { for (MembreClub m : actifs) { %>
            <tr>
                <td><%= m.getUtilisateur().getNomUtilisateur() %></td>
                <td><%= m.getUtilisateur().getEmail() %></td>
                <td><%= m.getRoleClub().getNomRole() %></td>
                <td>
                    <% if (!"PRESIDENT".equals(m.getRoleClub().getNomRole())) { %>
                    <form action="${pageContext.request.contextPath}/president" method="post" onsubmit="return confirm('Bannir ce membre ?');">
                        <input type="hidden" name="action" value="bannirMembre">
                        <input type="hidden" name="userId" value="<%= m.getUtilisateur().getUtilisateurID() %>">
                        <button class="btn-action btn-refuse">Radier</button>
                    </form>
                    <% } else { %>
                    <span style="color:#aaa;">(Vous)</span>
                    <% } %>
                </td>
            </tr>
            <% }} %>
            </tbody>
        </table>
    </div>

    <div id="events" class="section">

        <div class="create-box">
            <h3>📅 Créer un nouvel événement</h3>
            <form action="${pageContext.request.contextPath}/president" method="post">
                <input type="hidden" name="action" value="creerEvent">
                <div class="form-group">
                    <label>Titre de l'événement</label>
                    <input type="text" name="titre" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Date et Heure</label>
                    <input type="datetime-local" name="date" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" class="form-control" rows="3"></textarea>
                </div>
                <button type="submit" class="btn-create">Publier l'événement</button>
            </form>
        </div>

        <h3>Vos Événements planifiés</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px;">
            <% if (events != null) { for (Evenement e : events) { %>
            <div class="event-card">
                <form action="${pageContext.request.contextPath}/president" method="post" onsubmit="return confirm('Supprimer cet événement ?');">
                    <input type="hidden" name="action" value="supprimerEvent">
                    <input type="hidden" name="eventId" value="<%= e.getEvenementID() %>">
                    <button class="delete-icon">🗑</button>
                </form>
                <h4><%= e.getTitre() %></h4>
                <p style="color: var(--p-primary); font-weight: bold;"><%= (e.getDateEvenement() != null) ? sdf.format(e.getDateEvenement()) : "" %></p>
                <p><%= e.getDescription() %></p>
            </div>
            <% }} %>
        </div>
    </div>

</div>

<script>
    function showTab(id) {
        document.querySelectorAll('.section').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));

        document.getElementById(id).classList.add('active');
        event.currentTarget.classList.add('active');
    }
</script>

</body>
</html>