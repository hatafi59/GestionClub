<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="metier.entities.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    Club monClub = (Club) request.getAttribute("monClub");
    List<MembreClub> demandes = (List<MembreClub>) request.getAttribute("demandesEnAttente");
    List<MembreClub> membres = (List<MembreClub>) request.getAttribute("membresActifs");
    List<Evenement> events = (List<Evenement>) request.getAttribute("eventsClub");
    String searchMember = (String) request.getAttribute("searchMember");

    Utilisateur currentUser = (Utilisateur) session.getAttribute("user");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Bureau du Président - <%= monClub.getNom() %></title>
    <style>
        :root {
            --primary: #095bca;
            --secondary: #2172ac;
            --accent: #ff6b6b;
            --text-dark: #2d3436;
            --bg-light: #f9f9f9;
            --white: #ffffff;
            --success: #00b894;
            --warning: #ffc107;
        }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg-light); margin: 0; padding-bottom: 50px; }
        .hero {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white; padding: 15px; text-align: center;
            border-radius: 0 0 30px 30px; margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px; }
        .tab-nav { display: flex; justify-content: start; gap: 20px; margin-bottom: 40px; margin-top: 20px; }
        .tab-btn {
            padding: 8px 15px; background-color: white; color: var(--text-dark);
            text-decoration: none; border-radius: 4px; border: 2px solid var(--text-dark);
            cursor: pointer; font-weight: 600; font-size: 0.9rem; transition: opacity 0.3s;
        }
        .tab-btn.active {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border: 2px solid var(--primary); color: white; transform: translateY(-2px);
        }
        .section-content { display: none; animation: fadeIn 0.5s; }
        .section-content.active { display: block; }
        @keyframes fadeIn { from { opacity:0; transform: translateY(10px); } to { opacity:1; transform: translateY(0); } }
        .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #f8f9fa; color: var(--primary); }
        .form-control { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
        .btn { padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; color: white; font-size: 0.9rem; text-decoration: none;}
        .btn-success { background-color: var(--success); }
        .btn-danger { background-color: var(--accent); }
        .btn-primary { background-color: var(--primary); }
        .btn-warning { background-color: #6c757d; color: white; }
        .role-select-group { display: flex; gap: 5px; align-items: center; }
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .bg-admin { background-color: var(--warning); color: #333; }
        .bg-member { background-color: #e2e6ea; color: #333; }
    </style>
</head>
<body>

<jsp:include page="/common/header.jsp" />

<div class="hero">
    <h1>Bureau du Président</h1>
    <p><strong><%= monClub.getNom() %></strong></p>
</div>

<div class="container">

    <% if ("action_ok".equals(msg)) { %>
    <div style="padding:15px; background:#d4edda; color:#155724; border-radius:5px; margin-bottom:20px;">
        Action effectuée avec succès.
    </div>
    <% } %>

    <div class="tab-nav">
        <button class="tab-btn <%= "membres".equals(request.getAttribute("currentTab")) ? "active" : "" %>"
                onclick="openTab('membres')" id="btn-membres">Gestion Membres</button>
        <button class="tab-btn <%= "events".equals(request.getAttribute("currentTab")) ? "active" : "" %>"
                onclick="openTab('events')" id="btn-events">Gestion Événements</button>
    </div>

    <div id="membres" class="section-content <%= "membres".equals(request.getAttribute("currentTab")) ? "active" : "" %>">
        <% if (!demandes.isEmpty()) { %>
        <div class="card" style="border-left: 5px solid var(--accent);">
            <h3 style="margin-top:0; color: var(--accent);">Demandes d'adhésion : <%= demandes.size() %></h3>
            <table>
                <thead>
                <tr><th>Nom</th><th>Niveau</th><th>Date Demande</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <% for (MembreClub m : demandes) { %>
                <tr>
                    <td><%= m.getUtilisateur().getNomUtilisateur() %></td>
                    <td><%= m.getUtilisateur().getNiveauEtude() %></td>
                    <td><%= sdf.format(m.getDateDemande()) %></td>
                    <td>
                        <form action="president" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="accepterMembre">
                            <input type="hidden" name="membreId" value="<%= m.getId() %>">
                            <button class="btn btn-success">Accepter</button>
                        </form>
                        <form action="president" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="refuserMembre">
                            <input type="hidden" name="membreId" value="<%= m.getId() %>">
                            <button class="btn btn-danger">Refuser</button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>

        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h3 style="margin:0; color: var(--primary);">Membres du Club: <%= membres.size() %></h3>

                <form action="<%= request.getContextPath() %>/president" method="get" style="display: flex; gap: 10px;">
                    <input type="hidden" name="tab" value="membres">
                    <input type="text" name="searchMember" placeholder="Nom ou Email..." class="form-control"
                           value="<%= searchMember != null ? searchMember : "" %>">
                    <button type="submit" class="btn btn-primary">Rechercher</button>

                    <% if (searchMember != null && !searchMember.isEmpty()) { %>
                    <a href="<%= request.getContextPath() %>/president?tab=membres" class="btn btn-warning">Effacer</a>
                    <% } %>
                </form>
            </div>

            <table>
                <thead>
                <tr><th>Nom</th><th>Email</th><th>Rôle Actuel</th><th>Modifier Rôle</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <% if (membres.isEmpty()) { %>
                <tr><td colspan="5" style="text-align:center; color:#777;">Aucun membre trouvé.</td></tr>
                <% } %>
                <% for (MembreClub m : membres) {
                    boolean isMe = (m.getUtilisateur().getUtilisateurID() == currentUser.getUtilisateurID());
                %>
                <tr>
                    <td>
                        <%= m.getUtilisateur().getNomUtilisateur() %>
                        <% if(isMe) { %> <span style="color:#888; font-size:0.8em;">(Vous)</span> <% } %>
                    </td>
                    <td><%= m.getUtilisateur().getEmail() %></td>
                    <td>
                        <span class="badge <%= "PRESIDENT".equals(m.getRoleClub().getNomRole()) ? "bg-admin" : "bg-member" %>">
                            <%= m.getRoleClub().getNomRole() %>
                        </span>
                    </td>
                    <td>
                        <% if (!isMe) { %>
                        <form action="president" method="post" class="role-select-group">
                            <input type="hidden" name="action" value="changerRole">
                            <input type="hidden" name="userId" value="<%= m.getUtilisateur().getUtilisateurID() %>">
                            <select name="nouveauRole" class="form-control" style="padding:4px;">
                                <option value="MEMBRE" <%= "MEMBRE".equals(m.getRoleClub().getNomRole()) ? "selected" : "" %>>Membre</option>
                                <option value="TRESORIER" <%= "TRESORIER".equals(m.getRoleClub().getNomRole()) ? "selected" : "" %>>Trésorier</option>
                                <option value="SECRETAIRE" <%= "SECRETAIRE".equals(m.getRoleClub().getNomRole()) ? "selected" : "" %>>Secrétaire</option>
                                <option value="VICE_PRESIDENT" <%= "VICE_PRESIDENT".equals(m.getRoleClub().getNomRole()) ? "selected" : "" %>>Vice-Président</option>
                                <option value="RESP_COM" <%= "RESP_COM".equals(m.getRoleClub().getNomRole()) ? "selected" : "" %>>Resp. Com</option>
                            </select>
                            <button type="submit" class="btn btn-primary" title="Valider">OK</button>
                        </form>
                        <% } else { %> - <% } %>
                    </td>
                    <td>
                        <% if (!isMe) { %>
                        <form action="president" method="post" onsubmit="return confirm('Bannir ce membre ?');">
                            <input type="hidden" name="action" value="bannirMembre">
                            <input type="hidden" name="userId" value="<%= m.getUtilisateur().getUtilisateurID() %>">
                            <button class="btn btn-danger">Bannir</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div id="events" class="section-content <%= "events".equals(request.getAttribute("currentTab")) ? "active" : "" %>">        <div class="card" style="background: #f1f8ff; border: 1px solid #cce5ff;">
            <h3 style="margin-top:0; color: var(--secondary);">Créer un nouvel événement</h3>
            <form action="president" method="post" style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <input type="hidden" name="action" value="creerEvent">
                <div style="grid-column: 1 / -1;">
                    <label>Titre de l'événement :</label>
                    <input type="text" name="titre" class="form-control" style="width:100%;" required>
                </div>
                <div>
                    <label>Date et Heure :</label>
                    <input type="datetime-local" name="date" class="form-control" style="width:100%;" required>
                </div>
                <div style="grid-column: 1 / -1;">
                    <label>Description :</label>
                    <textarea name="description" class="form-control" rows="3" style="width:100%;" required></textarea>
                </div>
                <div style="grid-column: 1 / -1;">
                    <button type="submit" class="btn btn-success" style="width:100%; padding:10px;">Publier l'événement</button>
                </div>
            </form>
        </div>

        <div class="card">
            <h3>Événements du Club</h3>
            <% if (events.isEmpty()) { %>
            <p>Aucun événement programmé.</p>
            <% } else { %>
            <table>
                <thead>
                <tr><th>Date</th><th>Titre</th><th>Description</th><th>Action</th></tr>
                </thead>
                <tbody>
                <% for (Evenement e : events) { %>
                <tr>
                    <td style="white-space:nowrap;"><%= sdf.format(e.getDateEvenement()) %></td>
                    <td><strong><%= e.getTitre() %></strong></td>
                    <td><%= e.getDescription() %></td>
                    <td>
                        <form action="president" method="post" onsubmit="return confirm('Supprimer cet événement ?');">
                            <input type="hidden" name="action" value="supprimerEvent">
                            <input type="hidden" name="eventId" value="<%= e.getEvenementID() %>">
                            <button class="btn btn-danger">Clôturer / Supprimer</button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>
</div>

<script>
    function openTab(tabName) {
        document.querySelectorAll('.section-content').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));

        document.getElementById(tabName).classList.add('active');
        document.getElementById('btn-' + tabName).classList.add('active');

        // Mettre à jour l'URL sans recharger
        history.pushState(null, '', 'president?tab=' + tabName);
    }

    // Au chargement de la page, activer le bon onglet
    document.addEventListener('DOMContentLoaded', () => {
        const urlParams = new URLSearchParams(window.location.search);
        const tab = urlParams.get('tab');
        if(tab && (tab === 'membres' || tab === 'events')) {
            openTab(tab);
        }
    });
</script>
</body>
</html>